import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/services/base_url_provider.dart';
import 'package:presscue_patroller/core/services/dio/remote_data_source_impl.dart';
import 'package:presscue_patroller/core/services/socket/private_websocket_channel.dart';
import 'package:presscue_patroller/core/utils/widgets.dart/custom_message.dart';
import 'package:presscue_patroller/features/app_sidebar.dart';
import 'package:presscue_patroller/features/location/data/event_service_provider.dart';
import 'package:presscue_patroller/features/location/presentation/providers/location_provider.dart';
import 'package:presscue_patroller/features/location/presentation/pages/map.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final presenceService = PrivateWebSocketService();
  final privateService = PrivateWebSocketService();
  bool _isDisposed = false;
  late ProviderSubscription<Position?> _locationListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationListener = ref.listenManual<Position?>(
        locationNotifierProvider,
        (previous, next) {
          if (_isDisposed || next == null) return;
          _handleMovement(next);
        },
      );
    });

    presenceService.connect(
      onStatusChanged: (status) {
        if (!_isDisposed) {
          ref.read(webSocketConnectionStatusProvider.notifier).state = status;
        }
      },
      channelType: WebSocketChannelType.presence,
      onEventReceived: _handleWebSocketEvent,
    );

    privateService.connect(
      onStatusChanged: (status) {
        if (!_isDisposed) {
          ref.read(webSocketConnectionStatusProvider.notifier).state = status;
        }
      },
      channelType: WebSocketChannelType.private,
      onEventReceived: _handleWebSocketEvent,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    presenceService.disconnect();
    privateService.disconnect();

    _locationListener.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(ref, locationState),
      drawer: AppSidebar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const MapPage(),
    );
  }

  AppBar _buildAppBar(WidgetRef ref, locationState) {
    final connectionStatus = ref.watch(webSocketConnectionStatusProvider);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, size: 12),
              SizedBox(width: 3),
              AutoSizeText('Current Location', style: TextStyle(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              AutoSizeText(
                locationState != null
                    ? '${locationState.latitude},'
                    : 'Latitude',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 5),
              AutoSizeText(
                locationState != null
                    ? '${locationState.longitude}'
                    : 'Longitude',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.accent,
      elevation: 1.5,
      shadowColor: AppColors.accent,
      actions: [
        // WebSocket status indicator
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                color: connectionStatus == WebSocketConnectionStatus.connected
                    ? Colors.green
                    : Colors.grey,
                size: 12,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_outlined),
          onPressed: () {
            CustomToastMessage(message: 'Coming Soon').show(context);
          },
        ),
      ],
    );
  }

  void _handleWebSocketEvent(String eventName, dynamic data) {
    if (_isDisposed) return;
    print('Event Name: $eventName');
    return ref.read(eventServiceProvider.notifier).updateEvent(eventName, data);
  }

  Future<void> _handleMovement(Position next) async {
    final tracker = ref.read(locationTrackerProvider.notifier);
    final (hasMoved, distance) =
        await tracker.evaluateMovement(newPosition: next);

    if (hasMoved) {
      final locationData = {
        'latitude': next.latitude,
        'longitude': next.longitude,
        'distance': distance.toStringAsFixed(2),
      };

      final remoteDataSource = ref.read(remoteDataSourceProvider);
      final sectorId = boxUsers.get(1)?.sector_id ?? '';
      final url = BaseUrlProvider.buildUri('incident/$sectorId/move');

      try {
        await remoteDataSource.postRequestWithToken(url, locationData);
      } catch (e) {
        debugPrint('Failed to send location update: $e');
      }
    }
  }
}

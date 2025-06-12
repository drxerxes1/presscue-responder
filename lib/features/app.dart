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
  final wsService = PrivateWebSocketService();
  bool _hasSetUpListener = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    wsService.connect(
      onStatusChanged: (status) {
        if (!_isDisposed) {
          ref.read(webSocketConnectionStatusProvider.notifier).state = status;
        }
      },
      channelType: WebSocketChannelType.presence,
      onEventReceived: _handleWebSocketEvent,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    wsService.disconnect();
    _hasSetUpListener = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final sector_id = boxUsers.get(1)?.sector_id ?? '';

    // Set up listener ONCE
    if (!_hasSetUpListener) {
      ref.listen<Position?>(locationNotifierProvider, (previous, next) async {
        if (next == null) return;

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
          final url = BaseUrlProvider.buildUri('incident/${sector_id}/move');

          try {
            await remoteDataSource.postRequestWithToken(
              url,
              locationData,
            );
          } catch (e) {
            debugPrint('Failed to send location update: $e');
          }
        }
      });
    }

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
}

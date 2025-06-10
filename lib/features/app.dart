import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import 'package:presscue_patroller/core/services/socket/private_websocket_channel.dart';
import 'package:presscue_patroller/core/utils/widgets.dart/custom_message.dart';
import 'package:presscue_patroller/features/app_sidebar.dart';
import 'package:presscue_patroller/features/location/presentation/providers/location_provider.dart';
import 'package:presscue_patroller/features/location/presentation/pages/map.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final wsService = PrivateWebSocketService();

  @override
  void initState() {
    super.initState();

    wsService.connect(
      channelType: WebSocketChannelType.presence,
      onEventReceived: (event, data) {
        print('Received $event: $data');
      },
    );
  }

  @override
  void dispose() {
    wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(locationState),
      drawer: AppSidebar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const MapPage(),
    );
  }

  AppBar _buildAppBar(locationState) {
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
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline_outlined),
          onPressed: () {
            CustomToastMessage(
              message: 'Coming Soon',
              iconPath: AppIcons.icPresscueSOS,
              backgroundColor: AppColors.accent,
              iconBackgroundColor: AppColors.primaryColor,
            ).show(context);
          },
        ),
      ],
    );
  }
}

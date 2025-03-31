import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import 'package:presscue_patroller/core/utils/widgets.dart/custom_message.dart';
import 'package:presscue_patroller/features/app_sidebar.dart';
import 'package:presscue_patroller/features/location/presentation/providers/location_provider.dart';
import 'package:presscue_patroller/features/location/presentation/pages/map.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(locationState, context),
      drawer: AppSidebar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: MapPage(),
    );
  }

  AppBar _buildAppBar(locationState, context) {
    return AppBar(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: const [
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
          )
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

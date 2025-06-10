import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/database/user.dart';
import 'package:presscue_patroller/core/navigation/app_routes.dart';
import 'package:presscue_patroller/core/utils/widgets.dart/custom_message.dart';
import 'package:presscue_patroller/core/utils/widgets.dart/modal.dart';

import 'location/data/location_services.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final user = boxUsers.get(1);

    return Drawer(
      backgroundColor: AppColors.accent,
      child: ListView(
        padding: EdgeInsets.all(mediaQuery.size.width * 0.05),
        children: [
          // If user data exists, build profile; otherwise show default
          if (user != null)
            _buildUserProfile(mediaQuery, user)
          else
            const Center(child: Text('No user data')),

          // Sidebar options (static for now)
          _buildSidebarOption(
            iconPath: AppIcons.icTrackReports,
            label: 'Track Reports',
            onTap: () => _onOptionSelected(context),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icLocationShare,
            label: 'Location Sharing',
            onTap: () => _onOptionSelected(context),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icPrivacySecurity,
            label: 'Privacy & Security',
            onTap: () => _onOptionSelected(context),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icHelp,
            label: 'Help',
            onTap: () => _onOptionSelected(context),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icAbout,
            label: 'About',
            onTap: () => _onOptionSelected(context),
          ),

          // Spacer to push the logout option to the bottom
          SizedBox(height: mediaQuery.size.height * 0.3),

          // Logout option
          _buildSidebarOption(
            iconPath: AppIcons.icLogout,
            label: 'Logout',
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
            iconColor: AppColors.primaryColor,
            onTap: () => _showCustomModal(context, ref),
          ),
        ],
      ),
    );
  }

  // Build the user profile section dynamically using Hive User data
  Widget _buildUserProfile(MediaQueryData mediaQuery, User user) {
    return UserAccountsDrawerHeader(
      accountName: AutoSizeText(
        user.name, // Access directly from Hive User object
        style: const TextStyle(color: Colors.black),
      ),
      accountEmail: AutoSizeText(
        user.phone, // Access directly from Hive User object
        style: const TextStyle(color: Colors.black),
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        border: BorderDirectional(
          bottom: BorderSide(color: AppColors.mutedDark),
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        child: ClipOval(
          child:
              Image.asset(AppIcons.testPic), // Your user profile picture asset
        ),
      ),
    );
  }

  // Generalized method to build sidebar options
  Widget _buildSidebarOption({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    TextStyle? labelStyle,
    Color iconColor = AppColors.mutedDark,
  }) {
    return ListTile(
      // ignore: deprecated_member_use
      leading: SvgPicture.asset(iconPath, color: iconColor),
      title: AutoSizeText(
        label,
        style: labelStyle ?? AppText.subtitle1_muted,
      ),
      onTap: onTap,
    );
  }

  // Handler for when an option is tapped
  void _onOptionSelected(BuildContext context) {
    CustomToastMessage(
      message: 'Coming Soon',
      iconPath: AppIcons.icPresscueSOS,
      backgroundColor: AppColors.accent,
      iconBackgroundColor: AppColors.primaryColor,
    ).show(context);
  }

  // Logout functionality
  void _onLogout(BuildContext context, WidgetRef ref) {
    // ref.read(locationServiceProvider).stopSendingLocation();
    print('Logout Tapped');
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.onBoarding, (route) => false);
    boxUsers.delete(1);
  }

  void _showCustomModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomModal(
          title: 'Log Out?',
          content: 'Are you sure you want to log out?',
          onConfirm: () {
            _onLogout(context, ref);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

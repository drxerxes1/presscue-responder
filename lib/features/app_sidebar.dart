import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);

    return Drawer(
      backgroundColor: AppColors.accent,
      child: ListView(
        padding: EdgeInsets.all(mediaQuery.size.width * 0.05),
        children: [

          _buildUserProfile(mediaQuery),
          // Sidebar options (static for now)
          _buildSidebarOption(
            iconPath: AppIcons.icTrackReports,
            label: 'Track Reports',
            onTap: () => _onOptionSelected('Track Reports'),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icLocationShare,
            label: 'Location Sharing',
            onTap: () => _onOptionSelected('Location Sharing'),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icPrivacySecurity,
            label: 'Privacy & Security',
            onTap: () => _onOptionSelected('Privacy & Security'),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icHelp,
            label: 'Help',
            onTap: () => _onOptionSelected('Help'),
          ),
          _buildSidebarOption(
            iconPath: AppIcons.icAbout,
            label: 'About',
            onTap: () => _onOptionSelected('About'),
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
            onTap: () => _onOptionSelected('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(MediaQueryData mediaQuery) {
    return UserAccountsDrawerHeader(
      accountName: AutoSizeText(
        'Patroller Account',
        style: const TextStyle(color: Colors.black),
      ),
      accountEmail: AutoSizeText(
        'Hello World!',
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
  void _onOptionSelected(String option) {
    print('$option Tapped');
  }
}

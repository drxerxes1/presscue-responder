import 'dart:async'; // Import Completer for handling completion
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';
import 'package:presscue_patroller/core/constants/app_text.dart';

class CustomToastMessage extends StatelessWidget {
  final String message;
  final Duration duration;

  static Completer<void>? _toastCompleter; // Tracks active toast

  const CustomToastMessage({
    Key? key,
    required this.message,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);

  void show(BuildContext context) {
    if (_toastCompleter != null && !_toastCompleter!.isCompleted)
      return; // Prevent duplicate toasts

    _toastCompleter = Completer<void>(); // Mark toast as active

    DelightToastBar(
      builder: (context) {
        return ToastCard(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: 24,
            child: SvgPicture.asset(
              AppIcons.icPresscueSOS,
              width: 18,
              height: 18,
            ),
          ),
          color: AppColors.accent,
          title: Text(
            message,
            style: AppText.subtitle2,
          ),
        );
      },
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: duration,
    ).show(context);

    Future.delayed(duration, () {
      _toastCompleter?.complete(); // Reset after toast disappears
      _toastCompleter = null; // Ensure it can be shown again
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
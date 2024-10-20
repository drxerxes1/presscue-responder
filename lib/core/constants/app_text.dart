import 'package:flutter/material.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';

class AppText {
  static const TextStyle header1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
  ); 
  static const TextStyle header2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ); 
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle subtitle1_muted = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.mutedDark,
  );
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  ); 
  static const TextStyle subtitle3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle body1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
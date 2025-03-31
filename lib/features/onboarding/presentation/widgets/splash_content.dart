import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:presscue_patroller/core/constants/app_icons.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset('assets/images/splash_logo.png', height: 300),
          SvgPicture.asset(
            AppIcons.icResponderSplash,
            fit: BoxFit.fill,
          )
        ],
      ),
    );
  }
}

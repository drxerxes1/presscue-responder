import 'package:flutter/material.dart';
import 'package:presscue_patroller/features/app.dart';
import 'package:presscue_patroller/features/auth/login_phone_number_page.dart';
import 'package:presscue_patroller/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:presscue_patroller/features/onboarding/presentation/pages/splash_page.dart';

import '../utils/slide_page_route.dart';

class AppRoutes {
  static const String splash = '/';
  static const String main = '/main';
  static const String onBoarding = '/onBoarding';
  static const String loginPhoneNumber = '/login_phone_number';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return SlidePageRoute(builder: (_) => const SplashPage());
      case onBoarding:
        return SlidePageRoute(builder: (_) => const OnboardingPage());
      case loginPhoneNumber:
        return SlidePageRoute(builder: (_) => const LoginPhoneNumberPage());
      case main:
        return SlidePageRoute(builder: (_) => const MainPage());
      default:
        return SlidePageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

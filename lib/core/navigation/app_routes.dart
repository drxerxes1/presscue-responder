import 'package:flutter/material.dart';
import 'package:presscue_patroller/features/location/presentation/pages/location_page.dart';
import 'package:presscue_patroller/features/onboarding/presentation/pages/splash_page.dart';

import '../utils/slide_page_route.dart';

class AppRoutes {
  static const String splash = '/';
  static const String map = '/map';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return SlidePageRoute(builder: (_) => const SplashPage());
      case map:
        return SlidePageRoute(builder: (_) => const LocationPage());
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

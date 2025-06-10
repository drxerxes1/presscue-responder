import 'package:flutter/material.dart';

enum SlidePageTransitionType {
  slideFromRight,
  slideFromBottom, // Slide transition only
  slideFromLeft,   // New slide transition from left
}

class SlidePageRoute<T> extends MaterialPageRoute<T> {
  final SlidePageTransitionType transitionType;

  SlidePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    this.transitionType = SlidePageTransitionType.slideFromRight,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (settings.name == '/') {
      return child;
    }

    switch (transitionType) {
      case SlidePageTransitionType.slideFromBottom:
        // Slide transition from bottom
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuad;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );

      case SlidePageTransitionType.slideFromLeft:
        // New slide transition from left
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case SlidePageTransitionType.slideFromRight:
      // Default slide transition from the right
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
    }
  }
}

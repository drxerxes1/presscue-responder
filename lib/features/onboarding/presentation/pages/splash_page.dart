import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/navigation/app_routes.dart';
import 'package:presscue_patroller/features/onboarding/presentation/providers/splash_provider.dart';

import '../widgets/splash_content.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // boxUsers.put(
    //         1,
    //         User(
    //             userId: '1',
    //             name: 'Drex Omanio',
    //             role: 'role_title',
    //             roleId: 'role_id',
    //             sector: 'sector',
    //             phone: 'widget.phoneNumber',
    //             device: 'deviceModel'));
    //     print(boxUsers.get(1).toString());

    ref.read(splashProvider.notifier).initializeApp().then((_) async {
      try {
        if (boxUsers.containsKey(1)) {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.main, (route) => false);
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.onBoarding);
          }
        }
      } catch (e) {
        print('Error opening Hive box: $e');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FadeTransition(
        opacity: _animation,
        child: const SplashContent(),
      ),
    );
  }
}

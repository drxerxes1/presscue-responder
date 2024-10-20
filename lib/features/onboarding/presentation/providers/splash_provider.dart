import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/check_initialization_status.dart';

class SplashState {
  final bool isInitialized;

  SplashState({required this.isInitialized});
}

class SplashNotifier extends StateNotifier<SplashState> {
  final CheckInitializationStatus checkInitializationStatus;

  SplashNotifier(this.checkInitializationStatus)
      : super(SplashState(isInitialized: false));

  Future<void> initializeApp() async {
    final initialized = await checkInitializationStatus();
    state = SplashState(isInitialized: initialized);
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>(
    (ref) => SplashNotifier(CheckInitializationStatus()));

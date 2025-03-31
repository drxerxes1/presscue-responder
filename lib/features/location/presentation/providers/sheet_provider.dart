import 'package:flutter_riverpod/flutter_riverpod.dart';


final isResponseClickedProvider = StateProvider<bool>((ref) => false);

final hasPlayedSoundProvider = StateProvider<bool>((ref) => false);

final isLoadingProvider = StateProvider<bool>((ref) => false);

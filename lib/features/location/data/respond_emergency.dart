import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/features/location/presentation/providers/location_provider.dart';
import '../presentation/providers/sheet_provider.dart';

respondEmergency(WidgetRef ref, String url) async {
  final token = boxUsers.get(1)?.token ?? '';

  // Start loading
  ref.read(isLoadingProvider.notifier).state = true;

  print('Sending Data to: $url');

  try {
    final response = await Dio().get(
      url,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      print("Dispatched successfully: ${response.data}");
      print('Status Code: $response.statusCode');
      ref.read(serverResponseProvider.notifier).state = response.data;

      // Stop loading and update relevant state
      Future.microtask(() {
        ref.read(isLoadingProvider.notifier).state = false;
        ref.read(isResponseClickedProvider.notifier).state = true;
        ref.read(hasPlayedSoundProvider.notifier).state = false;
      });
    } else {
      print("Dispatch failed");
      print('Status Code: $response.statusCode');
      ref.read(isLoadingProvider.notifier).state = false;
    }
  } catch (e) {
    print("Error dispatching emergency: $e");
    ref.read(isLoadingProvider.notifier).state = false;
  }
}

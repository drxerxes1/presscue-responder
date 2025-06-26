import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/features/location/presentation/providers/location_provider.dart';
import '../presentation/providers/sheet_provider.dart';

Future<dynamic> respondEmergency(WidgetRef ref, String url) async {
  final token = boxUsers.get(1)?.token ?? '';

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
      ref.read(timelineDataProvider.notifier).state = response.data['data'];

      Future.microtask(() {
        ref.read(isLoadingProvider.notifier).state = false;
        ref.read(isResponseClickedProvider.notifier).state = true;
        ref.read(hasPlayedSoundProvider.notifier).state = false;
      });

      return response.data;
    } else {
      print("Dispatch failed: ${response.statusCode}");
      ref.read(isLoadingProvider.notifier).state = false;
      return null;
    }
  } catch (e) {
    print("Error dispatching emergency: $e");
    ref.read(isLoadingProvider.notifier).state = false;
    return null;
  }
}

Future<List<String>?> getKeywords(String url) async {
  final token = boxUsers.get(1)?.token ?? '';
  print('Sending Data to: $url');

  try {
    final response = await Dio().get(
      url,
      options: Options(headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      final current = response.data['current'];
      print("Get keywords response received: ${response.data}");
      if (current != null && current is List) {
        final keywords = current.map((e) => e.toString()).toList();
        print('Parsed keywords: $keywords');
        return keywords;
      }
    }
  } catch (e) {
    print("Error getting keywords: $e");
  }

  return null;
}

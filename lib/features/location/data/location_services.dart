import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/database/boxes.dart';

import '../presentation/providers/location_provider.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class LocationService {
  Timer? _timer;

  void startSendingLocation(double latitude, double longitude, String url,
      Function(Map<String, dynamic>) onResponse, WidgetRef ref) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final token = boxUsers.get(1)?.token ?? '';
      final requestData = {
        'latitude': latitude,
        'longitude': longitude,
      };

      print('Sending location data in background isolate: $requestData');

      final responseData = await compute(_sendLocationInBackground, {
        'url': url,
        'token': token,
        'requestData': requestData,
      });

      if (responseData != null) {
        print('Location sent successfully: $responseData');
        ref.read(serverResponseProvider.notifier).state = responseData;
      } else {
        ref.read(serverResponseProvider.notifier).state = {
          'message': 'Not Connected to Server'
        };
      }
    });
  }

  void stopSendingLocation() {
    _timer?.cancel();
    print('Stopped sending location.');
  }
}

Future<Map<String, dynamic>?> _sendLocationInBackground(
    Map<String, dynamic> args) async {
  final Dio dio = Dio();
  final String url = args['url'];
  final String token = args['token'];
  final Map<String, dynamic> requestData = args['requestData'];

  print('Sending Data to: $url');

  try {
    final response = await dio.post(
      url,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
      data: requestData,
    );

    print('Token: $token');
    print('Request data: $requestData');

    print('Status code: ${response.statusCode}');
    print('Response data: ${response.data}');

    if (response.statusCode == 200) {
      var responseData = response.data;
      if (responseData is String) {
        responseData = {'message': responseData, 'content': responseData};
      }

      return {
        'message': 'Emergency!!!',
        'content': responseData ?? '',
        'statusCode': response.statusCode,
      };
    } else if (response.statusCode == 204) {
      return {
        'message': 'Waiting for dispatch',
        'content': 'Everything is fine, There is no emergency',
        'statusCode': response.statusCode,
      };
    } else {
      return {
        'message': 'Not Connected to Server',
        'content': 'Please check your internet connection',
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('Error sending location in isolate: $e');
    return {
      'message': 'Not Connected to Server',
      'statusCode': 500,
    };
  }
}

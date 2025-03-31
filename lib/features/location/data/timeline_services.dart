import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/services/base_url_provider.dart';

import '../presentation/providers/incident_provider.dart';
import '../presentation/providers/location_provider.dart';
import '../presentation/providers/citizen_location_provider.dart'; // New provider for citizen location

class TimelineService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> fetchTimelineUpdates(WidgetRef ref) async {
    final locationState = ref.read(locationNotifierProvider);
    final incidentId = ref.watch(incidentProvider);
    final token = boxUsers.get(1)?.token ?? '';

    if (locationState?.latitude == null || locationState?.longitude == null) {
      print('Location not available');
      return null;
    }

    final String url = BaseUrlProvider.buildUri('incident/$incidentId/poll');
    final Map<String, dynamic> requestData = {
      "latitude": locationState?.latitude.toString(),
      "longitude": locationState?.longitude.toString(),
    };

    try {
      final response = await _dio.post(
        url,
        options: Options(headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
        data: requestData,
      );

      print("Response received: ${response.statusCode}");

      if (response.statusCode == 200) {
  final data = response.data;
  debugPrint(jsonEncode(data), wrapWidth: 1024);
  print("Data: $data");

  if (data != null &&
      data['latest_timeline']?['location']?['longitude'] != null &&
      data['latest_timeline']?['location']?['latitude'] != null) {
    double citizenLatitude = data['latest_timeline']['location']['latitude'];
    double citizenLongitude = data['latest_timeline']['location']['longitude'];

    final currentLocation = ref.read(citizenLocationProvider);

    if (currentLocation['latitude'] != citizenLatitude ||
        currentLocation['longitude'] != citizenLongitude) {
      ref
          .read(citizenLocationProvider.notifier)
          .updateLocation(citizenLatitude, citizenLongitude);
    }
  }
  return data;
}
 else {
        print("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
    return null;
  }
}

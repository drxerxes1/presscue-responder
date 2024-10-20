import 'dart:convert';
import 'package:dio/dio.dart';

class LocationDataSource {
  final Dio dio;

  LocationDataSource(this.dio);

  Future<Response> postUrgentIncident(Map<String, dynamic> data) async {
    // Retrieve token from Hive

    // Construct the URI
    const String uri = 'http://klnvszarl0.laravel-sail.site:8080/api/patroller/location/update';

    // Log the action (optional)
    print('Sending request to: $uri with data: $data');

    try {
      final response = await dio.post(
        uri,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode(data),
      );

      return response;
    } on DioException catch (dioError) {
      print('Error sending urgent incident: ${dioError.message}');
      rethrow;
    }
  }
}

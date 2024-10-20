// lib/data/datasources/base_remote_data_source.dart

import 'dart:convert';
import 'package:dio/dio.dart';

abstract class BaseRemoteDataSource {
  final Dio dio;

  BaseRemoteDataSource(this.dio);

  Future<Response> postRequest(String uri, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        uri,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status! < 500; // Only throw DioError for server errors
          },
        ),
        data: jsonEncode(data),
      );
      return response;
    } on DioException catch (dioError) {
      print('Error making POST request: ${dioError.message}');
      rethrow;
    }
  }

  String buildUri(String host, int port, String path) {
    return 'http://$host:$port$path'; // Change to https if your server supports it
  }

  void handleResponse(Response response) {
    if (response.statusCode != 200) {
      print(
          'Request failed. Status Code: ${response.statusCode}, Data: ${response.data}');
      throw Exception(
          'Request failed. Status Code: ${response.statusCode}, Data: ${response.data}');
    }
  }
}

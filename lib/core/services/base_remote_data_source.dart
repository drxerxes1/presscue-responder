// lib/data/datasources/base_remote_data_source.dart

import 'dart:convert';
import 'package:dio/dio.dart';

abstract class BaseRemoteDataSource {
  final Dio dio;

  BaseRemoteDataSource(this.dio) {
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    );
  }

  Future<Response> postRequest(String uri, Map<String, dynamic> data) async {
    try {
      print("[LOG] About to send request at: ${DateTime.now()}");
      final response = await dio.post(
        uri,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        data: jsonEncode(data),
      );
      print("[LOG] Request completed at: ${DateTime.now()}");
      print("[LOG] Response: ${response.data}");
      print("[LOG] Response: ${response.statusCode}");
      return response;
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.sendTimeout ||
          dioError.type == DioExceptionType.receiveTimeout) {
        print('Request timed out');
      } else {
        print('Error making POST request: ${dioError.message}');
      }
      rethrow;
    }
  }

  void handleResponse(Response response) {
    if (response.statusCode == 404) {
      return;
    }
    if (response.statusCode == 422) {
      return;
    }
    if (response.statusCode != 200) {
      print(
          'Request failed. Status Code: ${response.statusCode}, Data: ${response.data}');

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Request failed. Status Code: ${response.statusCode}',
      );
    }
  }
}

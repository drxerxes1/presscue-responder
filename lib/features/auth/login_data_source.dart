// lib/data/datasources/phone_number_remote_data_source.dart

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:presscue_patroller/core/services/dio/base_remote_data_source.dart';
import 'package:presscue_patroller/core/services/base_url_provider.dart';

abstract class LoginDataSource {
  Future<Response> loginUser(Map<String, dynamic> jsonData);
}

class LoginDataSourceImpl extends BaseRemoteDataSource implements LoginDataSource {
  LoginDataSourceImpl(Dio dio) : super(dio);

  @override
  Future<Response> loginUser(Map<String, dynamic> jsonData) async {
    final uri = await BaseUrlProvider.buildUri('login');
    log('Attempting to connect to: $uri');
    log('Data being submitted: $jsonData');
    print('Data being submitted: $jsonData');

    final response = await postRequest(uri, jsonData);
    handleResponse(response);
    return response;
  }
}

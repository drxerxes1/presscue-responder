import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_remote_data_source.dart';

class RemoteDataSourceImpl extends BaseRemoteDataSource {
  RemoteDataSourceImpl(Dio dio) : super(dio);
}

final dioProvider = Provider<Dio>((ref) => Dio());

final remoteDataSourceProvider = Provider<RemoteDataSourceImpl>(
  (ref) => RemoteDataSourceImpl(ref.read(dioProvider)),
);
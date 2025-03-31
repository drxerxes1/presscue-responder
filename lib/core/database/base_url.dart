import 'package:hive/hive.dart';

part 'base_url.g.dart';

@HiveType(typeId: 2)
class BaseUrlModel {
  BaseUrlModel({required this.baseUrl});

  @HiveField(0)
  String baseUrl;

  @override
  String toString() {
    return '''
User {base url: $baseUrl}
  ''';
  }
}

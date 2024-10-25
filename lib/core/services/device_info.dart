import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static final _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<Map<String, String>> getPhoneInfo() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      return {
        'manufacturer': info.manufacturer,
        'model': info.model,
      };
    } else if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;
      return {
        'name': info.name,
        'model': info.model,
      };
    } else {
      throw UnimplementedError('Unsupported platform');
    }
  }
}

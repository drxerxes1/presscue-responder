import 'package:permission_handler/permission_handler.dart';

class RequestLocationPermission {
  Future<bool> call() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
}

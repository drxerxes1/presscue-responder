import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class GetInitialCameraPosition {
  Future<CameraPosition> call() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted.');
      }
    }

    final userLocation = await location.getLocation();

    return CameraPosition(
      target: LatLng(userLocation.latitude ?? 0.0, userLocation.longitude ?? 0.0),
      zoom: 14.0,
    );
  }
}
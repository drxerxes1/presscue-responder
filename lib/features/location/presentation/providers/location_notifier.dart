import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationNotifier extends StateNotifier<Position?> {
  LocationNotifier() : super(null) {
    _startTracking();
  }

  void _startTracking() async {
    try {
      // Request permission
      await Geolocator.requestPermission();

      // Start listening to location changes
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update location every 10 meters
        ),
      ).listen(
        (Position position) {
          print('Received position: ${position.latitude}, ${position.longitude}');
          state = position; // Update the state with the new location
        },
        onError: (error) {
          print('Error receiving position stream: $error');
          state = null; // Handle the error state
        },
      );
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  // Define the method to fetch the current location
  Future<void> fetchCurrentGeoposition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      print('Fetched current position: ${position.latitude}, ${position.longitude}');
      state = position;
    } catch (e) {
      print('Error fetching current position: $e');
    }
  }
}

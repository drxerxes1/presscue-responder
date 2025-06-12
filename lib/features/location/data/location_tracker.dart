import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackerState {
  final double? lastLat;
  final double? lastLng;

  const LocationTrackerState({
    this.lastLat,
    this.lastLng,
  });

  LocationTrackerState copyWith({
    double? lastLat,
    double? lastLng,
  }) {
    return LocationTrackerState(
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
    );
  }
}

class LocationTrackerNotifier extends StateNotifier<LocationTrackerState> {
  LocationTrackerNotifier() : super(const LocationTrackerState());

  Future<(bool hasMoved, double distance)> evaluateMovement({
    required Position newPosition,
    double thresholdInMeters = 50,
    double minAccuracy = 5,
  }) async {
    final newLat = newPosition.latitude;
    final newLng = newPosition.longitude;

    print('[LocationTracker] New position: ($newLat, $newLng)');
    print('[LocationTracker] Accuracy: ${newPosition.accuracy} meters');

    if (newPosition.accuracy > minAccuracy) {
      print('[LocationTracker] Ignored due to poor accuracy.');
      return (false, 0.0);
    }

    final lastLat = state.lastLat;
    final lastLng = state.lastLng;

    if (lastLat == null || lastLng == null) {
      print('[LocationTracker] No previous location. Setting initial location.');
      state = LocationTrackerState(lastLat: newLat, lastLng: newLng);
      return (false, 0.0);
    }

    final distance = Geolocator.distanceBetween(
      lastLat,
      lastLng,
      newLat,
      newLng,
    );

    print('[LocationTracker] Last position: ($lastLat, $lastLng)');
    print('[LocationTracker] Distance moved: ${distance.toStringAsFixed(2)} meters');

    if (distance >= thresholdInMeters) {
      print('[LocationTracker] Moved significantly. Updating state.');
      state = LocationTrackerState(lastLat: newLat, lastLng: newLng);
      return (true, distance);
    }

    print('[LocationTracker] Movement not significant.');
    return (false, distance);
  }
}
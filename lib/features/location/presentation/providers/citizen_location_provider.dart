import 'package:flutter_riverpod/flutter_riverpod.dart';

class CitizenLocationNotifier extends StateNotifier<Map<String, double?>> {
  CitizenLocationNotifier() : super({"latitude": null, "longitude": null});

  void updateLocation(double latitude, double longitude) {
    state = {"latitude": latitude, "longitude": longitude};
  }
}

final citizenLocationProvider =
    StateNotifierProvider<CitizenLocationNotifier, Map<String, double?>>(
  (ref) => CitizenLocationNotifier(),
);

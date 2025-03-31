import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncidentNotifier extends StateNotifier<int?> {
  IncidentNotifier() : super(null);

  void setIncidentId(int id) {
    state = id;
  }

  void clearIncidentId() {
    state = null;
  }
}

final incidentProvider = StateNotifierProvider<IncidentNotifier, int?>(
  (ref) => IncidentNotifier(),
);

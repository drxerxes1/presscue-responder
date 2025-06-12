import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventServiceProvider {
  final String eventName;
  final dynamic data;

  EventServiceProvider({required this.eventName, required this.data});
}

class WebSocketEventNotifier extends StateNotifier<EventServiceProvider?> {
  WebSocketEventNotifier() : super(null);

  void updateEvent(String eventName, dynamic data) {
    state = EventServiceProvider(eventName: eventName, data: data);
  }

  void clearEvent() {
    state = null;
  }
}

final eventServiceProvider =
    StateNotifierProvider<WebSocketEventNotifier, EventServiceProvider?>(
  (ref) => WebSocketEventNotifier(),
);

// marker.dart
import 'dart:ui' as ui;

class MarkerData {
  final double latitude;
  final double longitude;
  final Future<ui.Image> imageProvider;

  MarkerData({
    required this.latitude,
    required this.longitude,
    required this.imageProvider,
  });
}

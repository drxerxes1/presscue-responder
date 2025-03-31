import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapMarkerService {
  final MapboxMap mapboxMapController;
  final List<Position> _addedMarkers = [];
  PointAnnotationManager? _annotationManager;
  PointAnnotation? _currentMarker; // Store reference to the marker

  MapMarkerService(this.mapboxMapController);

  Future<void> addMarker(double latitude, double longitude) async {
    final position = Position(longitude, latitude);

    // Remove existing marker before adding a new one
    await removeMarker();

    final annotationManager =
        await mapboxMapController.annotations.createPointAnnotationManager();
    _annotationManager = annotationManager;

    final Uint8List imageData = await loadMarkerImage();

    final marker = await annotationManager.create(PointAnnotationOptions(
      image: imageData,
      geometry: Point(coordinates: position),
      iconSize: 0.3,
      iconAnchor: IconAnchor.BOTTOM
    ));

    _currentMarker = marker;
    _addedMarkers.add(position);
  }

  Future<void> removeMarker() async {
    if (_currentMarker != null && _annotationManager != null) {
      await _annotationManager!.delete(_currentMarker!);
      _currentMarker = null;
    }
  }

  Future<Uint8List> loadMarkerImage() async {
    var data = await rootBundle.load('assets/images/alert.png');
    return data.buffer.asUint8List();
  }
}

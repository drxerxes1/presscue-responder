import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:presscue_patroller/features/location/data/get_route_coordinates.dart';
import '../providers/location_provider.dart';
import '../../data/marker_services.dart';
import 'sheet_provider.dart';

class MapController {
  final WidgetRef ref;
  MapboxMap? mapboxMap;
  MapMarkerService? mapMarkerService;
  bool isFollowing = true;

  MapController(this.ref);

  PolylineAnnotationManager? _polylineManager;

  void initMap(MapboxMap controller) async {
    mapboxMap = controller;
    mapMarkerService = MapMarkerService(controller);
    _polylineManager =
        await mapboxMap!.annotations.createPolylineAnnotationManager();
    _setZoomBounds();

    final position = ref.read(locationNotifierProvider);
    if (position != null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        moveCamera(position.latitude, position.longitude, zoom: 17.0);
      });

      ref.read(isResponseClickedProvider.notifier).state = false;

      mapboxMap?.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
          puckBearingEnabled: true,
        ),
      );
    }
  }

  Future<void> drawNavigationRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final coords = await getRouteCoordinatesWithDio(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
    print('fromLat: $fromLat, fromLng: $fromLng, toLat: $toLat, toLng: $toLng');

    await _polylineManager?.deleteAll();

    await _polylineManager?.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: coords),
        lineColor: 0xFF0071BC,
        lineWidth: 5.0,
        lineOpacity: 1.0,
      ),
    );
  }

  void _setZoomBounds() {
    mapboxMap?.setBounds(CameraBoundsOptions(
      minZoom: 10.0,
      maxZoom: 18.0,
      bounds: CoordinateBounds(
        southwest: Point(coordinates: Position(116.1473, 4.2158)),
        northeast: Point(coordinates: Position(126.8070, 21.3210)),
        infiniteBounds: false,
      ),
    ));
  }

  void moveCamera(double lat, double lng, {double? zoom}) async {
    final currentZoom = (await mapboxMap?.getCameraState())?.zoom ?? 17.0;

    mapboxMap?.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: zoom ?? currentZoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  void toggleFollow() {
    isFollowing = !isFollowing;
    if (isFollowing) {
      final position = ref.read(locationNotifierProvider);
      if (position != null) {
        moveCamera(position.latitude, position.longitude, zoom: 17.0);
      }
    } else {
      mapboxMap?.easeTo(
        CameraOptions(zoom: 13.0),
        MapAnimationOptions(duration: 1500),
      );
    }
  }
}

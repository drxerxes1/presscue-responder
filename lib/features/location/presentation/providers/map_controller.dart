import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../providers/location_provider.dart';
import '../../data/marker_services.dart';
import 'sheet_provider.dart';

class MapController {
  final WidgetRef ref;
  MapboxMap? mapboxMap;
  MapMarkerService? mapMarkerService;
  bool isFollowing = true;

  MapController(this.ref);

  void initMap(MapboxMap controller) async {
    mapboxMap = controller;
    mapMarkerService = MapMarkerService(controller);
    _setZoomBounds();

    final position = ref.read(locationNotifierProvider);
    if (position != null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        moveCamera(position.latitude, position.longitude, zoom: 17.0);
      });

      // final String url = await BaseUrlProvider.buildUri('location/update');
      final bool isRespond =
          ref.read(isResponseClickedProvider.notifier).state = false;

      if (!isRespond) {
        // ref.read(locationServiceProvider).startSendingLocation(
        //       position.latitude,
        //       position.longitude,
        //       url,
        //       (responseData) => print("Server Response: $responseData"),
        //       ref,
        //     );
      }

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

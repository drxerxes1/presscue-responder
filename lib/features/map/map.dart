import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:presscue_patroller/core/utils/shared_prefs.dart';

class MapPage extends ConsumerStatefulWidget {
  // Use ConsumerStatefulWidget instead of StatefulWidget
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends ConsumerState<MapPage> {
  // Use ConsumerState<Map> for access to ref
  LatLng position = getLatLngFromSharedPrefs();
  late CameraPosition _initialCameraPosition;
  late MapboxMapController controller;

  @override
  void initState() {
    super.initState();

    // Default location while waiting for location services
    _initialCameraPosition = CameraPosition(target: position, zoom: 15);
  }

  _onMapCreated(MapboxMapController mapController) async {
    this.controller = mapController;
  }

  _onStyleLoadedCallback() async {
    // Additional setup when the map style is loaded
  }

  @override
  Widget build(BuildContext context) {
    // Watch the locationNotifierProvider to get the current Position

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: MapboxMap(
                accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN'],
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                minMaxZoomPreference: const MinMaxZoomPreference(14, 17),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.animateCamera(
              CameraUpdate.newCameraPosition(_initialCameraPosition));
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart'; // Import for MapController
import 'package:latlong2/latlong.dart';
import '../providers/location_provider.dart';
import '../widgets/location_map.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage>
    with TickerProviderStateMixin {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final locationPermission = ref.watch(locationPermissionProvider);
    final liveLocation = ref.watch(locationNotifierProvider);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: locationPermission.when(
          data: (hasPermission) {
            if (!hasPermission) {
              return Center(
                child: Text(
                  'Location permission is required to use the map.\nPlease enable it in settings.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return liveLocation != null
                ? LocationMap(
                    latitude: liveLocation.latitude,
                    longitude: liveLocation.longitude,
                    mapController: _mapController,
                  )
                : Center(child: CircularProgressIndicator());
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            print('Location Permission Error: $err');
            return Center(
              child: Text(
                'Error: $err\nUnable to check location permission.',
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        // Add Floating Action Button for recentering
        floatingActionButton: liveLocation != null
            ? FloatingActionButton(
                onPressed: () {
                  // Use animatedMove to smoothly move the camera
                  final targetLocation = LatLng(
                    liveLocation.latitude,
                    liveLocation.longitude,
                  );
                  _animatedMapMove(targetLocation, 15.0);
                },
                child: Icon(Icons.my_location),
              )
            : null,
      ),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    ); // Create a tween for latitude
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    ); // Create a tween for longitude
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    ); // Create a tween for zoom level

    var controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Set duration for the animation
      vsync: this, // Use TickerProvider from the mixin
    );

    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut, // Choose a smooth curve for animation
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.forward();
  }
}

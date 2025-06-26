import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/features/location/data/offline_map_services.dart';
import 'package:presscue_patroller/features/location/presentation/providers/sheet_provider.dart';
import 'package:presscue_patroller/features/location/presentation/widgets/build_default_sheet.dart';

import '../providers/citizen_location_provider.dart';
import '../providers/location_provider.dart';
import '../providers/map_controller.dart';
import '../widgets/build_timeline_sheet.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends ConsumerState<MapPage> {
  late MapController mapController;
  late OfflineMapService offlineMapService;
  bool isMapLoaded = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController(ref);
    offlineMapService = OfflineMapService(ref);

    _initializeOfflineMap();
  }

  Future<void> _initializeOfflineMap() async {
    await offlineMapService.ensureOfflineMapAvailability();
    setState(() {
      isMapLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(locationNotifierProvider);
    final isResponseClicked = ref.watch(isResponseClickedProvider);

    ref.listen(locationNotifierProvider, (previous, next) {
      if (next != null && mapController.isFollowing) {
        mapController.moveCamera(next.latitude, next.longitude);
      }

      final citizenLocation = ref.read(citizenLocationProvider);

      if (next != null &&
          citizenLocation['latitude'] != null &&
          citizenLocation['longitude'] != null) {
        // Fire-and-forget call to drawNavigationRoute
        mapController
            .drawNavigationRoute(
          fromLat: next.latitude,
          fromLng: next.longitude,
          toLat: citizenLocation['latitude']!,
          toLng: citizenLocation['longitude']!,
        )
            .catchError((e) {
          // Optional: log or show error
          print('Error drawing navigation route: $e');
        });
      }
    });

    ref.listen(citizenLocationProvider, (previous, next) {
      if (next['latitude'] != null && next['longitude'] != null) {
        final current = ref.read(locationNotifierProvider);
        if (current != null) {
          mapController.mapMarkerService
              ?.addMarker(next['latitude']!, next['longitude']!);

          mapController.drawNavigationRoute(
            fromLat: current.latitude,
            fromLng: current.longitude,
            toLat: next['latitude']!,
            toLng: next['longitude']!,
          );
        }
      } else {
        mapController.mapMarkerService?.removeMarker();
      }
    });

    if (position == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              child: MapWidget(
                onMapCreated: (map) async {
                  mapController.initMap(map);
                  await offlineMapService.ensureOfflineMapAvailability();
                },
                styleUri: MapboxStyles.SATELLITE_STREETS,
              ),
            ),
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'navigate',
                backgroundColor: mapController.isFollowing
                    ? AppColors.primaryColor
                    : Colors.white,
                mini: true,
                shape: const CircleBorder(),
                onPressed: () {
                  setState(() {
                    mapController.toggleFollow();
                  });
                },
                child: Icon(
                  Icons.my_location,
                  color: mapController.isFollowing
                      ? Colors.white
                      : AppColors.primaryColor,
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: isResponseClicked ? 0.6 : 0.4,
              builder: (context, scrollController) {
                final isResponseClicked = ref.watch(isResponseClickedProvider);
                return Container(
                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: isResponseClicked
                      ? BuildTimelineSheet(scrollController: scrollController)
                      : BuildDefaultSheet(scrollController: scrollController),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

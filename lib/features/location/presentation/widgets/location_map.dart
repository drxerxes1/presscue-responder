import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/constants/app_constants.dart';
import 'package:presscue_patroller/core/utils/load_image.dart';
import 'package:presscue_patroller/core/utils/tile_provider_util.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_icons.dart';
import '../providers/location_provider.dart';
import '../providers/marker_provider.dart';
import 'custom_marker_painter.dart';

class LocationMap extends ConsumerWidget {
  final double latitude;
  final double longitude;

  const LocationMap({
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(locationNotifierProvider);
    final markerAsyncValue = ref.watch(markerProvider);

    if (position == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return markerAsyncValue.when(
      data: (markers) {
        // Add current location marker with custom painter
        final currentLocationMarker = Marker(
          rotate: true,
          point: LatLng(position.latitude, position.longitude),
          child: FutureBuilder<ui.Image>(
            future: loadImageFromAssets(AppIcons.testPic),
            builder: (context, snapshot) {
              return CustomPaint(
                painter: MarkerPainter(image: snapshot.data),
                child: const SizedBox(
                  width: 100,
                  height: 100,
                ),
              );
            },
          ),
        );

        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(position.latitude, position.longitude),
            initialZoom: 15,
            minZoom: 5,
            maxZoom: 25,
          ),
          children: [
            TileLayer(
              tileProvider: CachedTileProvider(),
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
              additionalOptions: {
                'accessToken': AppConstants.mapBoxAccessToken,
                'id': AppConstants.mapBoxStyleSatelliteStreetId,
              },
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(position.latitude, position.longitude),
                  radius: 25,
                  useRadiusInMeter: true,
                  color: AppColors.primaryColorLight.withOpacity(0.3),
                  borderColor: AppColors.primaryColorLight.withOpacity(0.7),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                // ...markers.map((marker) {
                //   return Marker(
                //     rotate: true,
                //     point: LatLng(marker.latitude, marker.longitude),
                //     child: FutureBuilder<ui.Image?>(
                //       future: marker.imageProvider,
                //       builder: (context, snapshot) {
                //         return CustomPaint(
                //           painter: MarkerPainter(image: snapshot.data),
                //           child: const SizedBox(
                //             width: 100,
                //             height: 100,
                //           ),
                //         );
                //       },
                //     ),
                //   );
                // }).toList(),
                currentLocationMarker, // Add the current location marker
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

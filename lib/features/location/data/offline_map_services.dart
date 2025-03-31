// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class OfflineMapService {
  final WidgetRef ref;
  TileStore? _tileStore;
  OfflineManager? _offlineManager;
  final String _tileRegionId = "polomolok-tile-region";
  final StreamController<double> _downloadProgress =
      StreamController<double>.broadcast();

  OfflineMapService(this.ref) {
    _initOfflineManager();
  }

  Future<void> _initOfflineManager() async {
    _offlineManager = await OfflineManager.create();
    _tileStore = await TileStore.createDefault();
  }

  /// Automatically download offline map when online
  Future<void> ensureOfflineMapAvailability() async {
    final isConnected = await hasInternet();
    if (!isConnected) return;

    if (_tileStore == null) {
      await _initOfflineManager();
    }

    await _downloadTileRegion();
  }

  /// Check internet connection
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Download offline tiles
  Future<void> _downloadTileRegion() async {
  if (_tileStore == null) {
    print("⚠️ TileStore is not initialized yet.");
    return;
  }

  // 🔥 Check if the region is already downloaded
  final regions = await _tileStore!.allTileRegions();
  final isAlreadyDownloaded = regions.any((region) => region.id == _tileRegionId);

  if (isAlreadyDownloaded) {
    print("✅ Offline map is already downloaded.");
    return;
  }

  print("📥 Starting offline map download...");

  final tileRegionLoadOptions = TileRegionLoadOptions(
    geometry: _getRegionGeometry(),
    descriptorsOptions: [
      TilesetDescriptorOptions(
        styleURI: MapboxStyles.SATELLITE_STREETS,
        minZoom: 12,
        maxZoom: 17,
      ),
    ],
    acceptExpired: true,
    networkRestriction: NetworkRestriction.NONE,
  );

  _tileStore!.loadTileRegion(_tileRegionId, tileRegionLoadOptions, (progress) {
    final percentage = progress.completedResourceCount / progress.requiredResourceCount;

    if (progress.completedResourceCount % 50 == 0 || percentage == 1) {
      print("Downloading offline map: ${(percentage * 100).toStringAsFixed(2)}%");
    }

    if (!_downloadProgress.isClosed) {
      _downloadProgress.sink.add(percentage);
    }
  }).then((_) {
    print("✅ Offline map download complete!");
    _downloadProgress.sink.add(1);
    _downloadProgress.sink.close();
  }).catchError((e) {
    print("❌ Error downloading offline map: $e");
  });
}


  /// Define Polomolok region using GeoJSON
  Map<String, dynamic> _getRegionGeometry() {
    return {
      "type": "Polygon",
      "coordinates": [
        [
          [124.95, 6.1], // Bottom-left
          [125.15, 6.1], // Bottom-right
          [125.15, 6.3], // Top-right
          [124.95, 6.3], // Top-left
          [124.95, 6.1], // Closing the loop
        ]
      ]
    };
  }

  /// Close the StreamController when no longer needed
  void dispose() {
    _downloadProgress.close();
  }
}

// ignore_for_file: unnecessary_null_comparison

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';

class CachedTileProvider extends TileProvider {
  final CacheManager cacheManager = CacheManager(
    Config(
      'flutter_map_tile_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    if (coordinates == null || options == null) {
      // print('Null value: coordinates or options is null');
      return const AssetImage('assets/placeholder.png'); // Return a placeholder image if null
    }
    final url = getTileUrl(coordinates, options);
    // print('Requesting tile: $url');
    return CachedNetworkImageProvider(
      url,
      cacheManager: cacheManager,
    );
  }

  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final urlTemplate = options.urlTemplate;
    if (urlTemplate == null) {
      throw ArgumentError('TileLayer urlTemplate cannot be null');
    }
    final id = options.additionalOptions['id'] ?? '';
    final accessToken = options.additionalOptions['accessToken'] ?? '';

    final url = urlTemplate
        .replaceAll('{z}', '${coordinates.z}')
        .replaceAll('{x}', '${coordinates.x}')
        .replaceAll('{y}', '${coordinates.y}')
        .replaceAll('{id}', id)
        .replaceAll('{accessToken}', accessToken);

    // print('Tile URL: $url');
    return url;
  }
}

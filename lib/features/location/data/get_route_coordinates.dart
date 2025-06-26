import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:presscue_patroller/core/constants/app_constants.dart';

final String mapboxAccessToken = AppConstants.mapBoxAccessToken;

final Dio dio = Dio();

Future<List<Position>> getRouteCoordinatesWithDio({
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
}) async {
  final url =
      'https://api.mapbox.com/directions/v5/mapbox/driving/$fromLng,$fromLat;$toLng,$toLat'
      '?geometries=polyline&overview=full&access_token=$mapboxAccessToken';

  try {
    final response = await dio.get(url);
    final data = response.data;

    // print('Response data from getting route coordinates: $data');

    final polylineEncoded = data['routes'][0]['geometry'];

    // Decode using flutter_polyline_points
    final decodedPoints = PolylinePoints().decodePolyline(polylineEncoded);

    // Convert to Mapbox `Position` list (lng, lat)
    return decodedPoints
        .map((point) => Position(point.longitude, point.latitude))
        .toList();
  } on DioException catch (e) {
    print('Dio error: ${e.message}');
    throw Exception('Failed to fetch route: ${e.message}');
  }
}

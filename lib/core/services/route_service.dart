import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:presscue_patroller/core/constants/app_constants.dart';

class RouteService {
  final Dio dio;

  RouteService(this.dio);

  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&access_token=${AppConstants.mapBoxAccessToken}';

    try {
      final response = await dio.get(url);
      print('API Response: ${response.data}'); // Log the response

      // Ensure that we have route data
      if (response.data['routes'].isNotEmpty) {
        final List coordinates =
            response.data['routes'][0]['geometry']['coordinates'];
        return coordinates
            .map<LatLng>(
                (coord) => LatLng(coord[1], coord[0])) // Convert to LatLng
            .toList();
      } else {
        print('No routes found.');
        return [];
      }
    } catch (e) {
      print('Error fetching route: $e');
      return [];
    }
  }
}

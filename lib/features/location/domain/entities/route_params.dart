import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:presscue_patroller/features/location/presentation/providers/location_provider.dart';

// Define a class for route parameters
class RouteParams {
  final LatLng start;
  final LatLng end;

  RouteParams(this.start, this.end);
}

// Define the routeProvider
final routeProvider = FutureProvider.autoDispose.family<List<LatLng>, RouteParams>((ref, params) {
  final routeService = ref.watch(routeServiceProvider);
  return routeService.getRoute(params.start, params.end);
});

import 'package:dio/dio.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:presscue_patroller/core/services/route_service.dart';
import 'package:presscue_patroller/features/location/data/location_tracker.dart';
import '../../data/location_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/check_location_services.dart';
// import '../../domain/usecases/get_initial_camera_position.dart';
import '../../domain/usecases/request_location_permission.dart';
import 'location_notifier.dart' as notifier;

// Define the LocationRepository provider
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

final serverResponseProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Define the CheckLocationServices use case provider
final checkLocationServicesProvider = Provider<CheckLocationServices>((ref) {
  return CheckLocationServices();
});

final timelineDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final keywordsDataProvider = StateProvider<List<String>?>((ref) => null);

// Define the RequestLocationPermission use case provider
final requestLocationPermissionProvider = Provider<RequestLocationPermission>((ref) {
  return RequestLocationPermission();
});

final locationTrackerProvider =
    StateNotifierProvider<LocationTrackerNotifier, LocationTrackerState>(
        (ref) => LocationTrackerNotifier());

// Define the GetInitialCameraPosition use case provider
// final getInitialCameraPositionProvider = Provider<GetInitialCameraPosition>((ref) {
//   return GetInitialCameraPosition();
// });

// Define the LocationNotifier provider
final locationNotifierProvider = StateNotifierProvider<notifier.LocationNotifier, Position?>((ref) {
  return notifier.LocationNotifier();
});

// Define the provider for checking location services
final locationServicesProvider = FutureProvider<bool>((ref) async {
  final checkLocationServices = ref.watch(checkLocationServicesProvider);
  return await checkLocationServices.call();
});

// Define the provider for requesting location permission
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final locationServicesEnabled = await ref.watch(locationServicesProvider.future);
  if (!locationServicesEnabled) {
    return false;
  }
  final requestLocationPermission = ref.watch(requestLocationPermissionProvider);
  return await requestLocationPermission.call();
});

// Define the provider for initial camera position
// final initialCameraPositionProvider = FutureProvider<CameraPosition>((ref) async {
//   final getInitialCameraPosition = ref.watch(getInitialCameraPositionProvider);
//   return await getInitialCameraPosition.call();
// });

final dioProvider = Provider<Dio>((ref) {
  return Dio(); // You can customize Dio instance here
});

final routeServiceProvider = Provider<RouteService>((ref) {
  final dio = ref.watch(dioProvider);
  return RouteService(dio);
});

// final polylinesProvider = StateProvider<List<Polyline>>((ref) {
//   return []; // Initialize with an empty list
// });
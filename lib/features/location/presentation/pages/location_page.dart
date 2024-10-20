import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../widgets/location_map.dart';

class LocationPage extends ConsumerWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      ),
    );
  }
}

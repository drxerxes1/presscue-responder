import 'package:geolocator/geolocator.dart';
import '../domain/repositories/location_repository.dart';

class LocationRepositoryImpl extends LocationRepository {
  @override
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

import 'package:location/location.dart';

class CheckLocationServices {
  Future<bool> call() async {
    var location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }
}
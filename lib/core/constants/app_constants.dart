import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {

  // Mapbox
  static String mapBoxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'].toString();
  static String urlTemplate = 'https://api.mapbox.com/styles/v1/presscue-frank/cm06f5p6y00bc01omgti88wg1/tiles/256/{z}/{x}/{y}@2x?access_token=$mapBoxAccessToken';
  static const String mapBoxStyleSatelliteId = 'mapbox/satellite-v9';
  static const String mapBoxStyleSatelliteStreetId = 'mapbox/satellite-streets-v12';
  static const String mapBoxStyleStandardSatelliteId = 'mapbox/standard-satellite';
  static const String mapBoxStyleStandardId = 'mapbox/standard';

  // Laravel Echo
  static const String appKey = '9jkxpgv9h0rfb2sxnerf';
  static const String host = '100.68.25.1';
  static const String authEndPoint = 'http://100.68.25.1:81/api/broadcasting/auth';
  static const int wsPort = 8080;
  static const String channelName = 'active.sector';
}
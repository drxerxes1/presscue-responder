class AppConstants {
  static const String mapBoxAccessToken = 'pk.eyJ1IjoicHJlc3NjdWUtZnJhbmsiLCJhIjoiY20wMXo1dDZqMDM4ZjJqcG1nMjYyNm90eiJ9.OOW0ACSZ4sCvBGqpbQ3Djg';

  static const String urlTemplate = 'https://api.mapbox.com/styles/v1/presscue-frank/cm06f5p6y00bc01omgti88wg1/tiles/256/{z}/{x}/{y}@2x?access_token=$mapBoxAccessToken';

  static const String mapBoxStyleSatelliteId = 'mapbox/satellite-v9';
  static const String mapBoxStyleSatelliteStreetId = 'mapbox/satellite-streets-v12';
  static const String mapBoxStyleStandardSatelliteId = 'mapbox/standard-satellite';
  static const String mapBoxStyleStandardId = 'mapbox/standard';
}
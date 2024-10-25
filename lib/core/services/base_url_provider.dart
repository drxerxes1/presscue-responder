class BaseUrlProvider {
  static const String baseUrl = 'http://presscue.laravel-sail.site:8080/api/citizen';

  static String buildUri(String endpoint) {
    return '$baseUrl/$endpoint';
  }
}

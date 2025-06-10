import 'package:presscue_patroller/core/database/base_url.dart';
import 'package:presscue_patroller/core/database/boxes.dart';

class BaseUrlProvider {
  static String get baseUrl {
    final storedUrl = baseUrlBox.get(1);
    return storedUrl != null && storedUrl.baseUrl.isNotEmpty
        ? storedUrl.baseUrl
        : '100.68.25.1:81';
  }

  static String buildUri(String endpoint) {
    return 'http://$baseUrl/api/patroller/$endpoint';
}

  static Future<void> updateBaseUrl(String newUrl) async {
    await baseUrlBox.put(1, BaseUrlModel(baseUrl: newUrl));
  }
}

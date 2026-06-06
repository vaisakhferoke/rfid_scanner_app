import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Base url1
  static const String defaultBaseUrl = 'http://newtest.vkcparivar.com/api/';
  static const String urlPrefKey = 'api_base_url';
  // Base url2
  //static const String defaultBaseUrl = 'http://[IP_ADDRESS]/api/';

  static const String defaultBaseUrl2 = 'http://192.168.1.14:81/api/';
  static const String urlPrefKey2 = 'api_base_url2';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString(urlPrefKey);
    if (savedUrl == null || savedUrl.trim().isEmpty) {
      return defaultBaseUrl;
    }
    return _formatUrl(savedUrl);
  }

  static Future<String> getBaseUrl2() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString(urlPrefKey2);
    if (savedUrl == null || savedUrl.trim().isEmpty) {
      return defaultBaseUrl2;
    }
    return _formatUrl(savedUrl);
  }

  static Future<void> setBaseUrl(String url, String url2) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(urlPrefKey, url.trim());
    await prefs.setString(urlPrefKey2, url2.trim());
  }

  static String _formatUrl(String url) {
    String formatted = url.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'http://$formatted';
    }
    if (!formatted.endsWith('/')) {
      formatted = '$formatted/';
    }
    return formatted;
  }
}

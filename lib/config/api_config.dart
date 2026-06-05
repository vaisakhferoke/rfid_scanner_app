import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String defaultBaseUrl = 'http://newtest.vkcparivar.com/api/';
  static const String urlPrefKey = 'api_base_url';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString(urlPrefKey);
    if (savedUrl == null || savedUrl.trim().isEmpty) {
      return defaultBaseUrl;
    }
    return _formatUrl(savedUrl);
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(urlPrefKey, url.trim());
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

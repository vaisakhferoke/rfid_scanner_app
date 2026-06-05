import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiClient {
  static const Duration _timeoutDuration = Duration(seconds: 20);

  static Future<http.Response> get(String path) async {
    final String baseUrl = await ApiConfig.getBaseUrl();
    final String fullUrl = '$baseUrl$path';
    debugPrint('ApiClient [GET] request: $fullUrl');

    return http.get(Uri.parse(fullUrl)).timeout(_timeoutDuration);
  }

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final String baseUrl = await ApiConfig.getBaseUrl();
    final String fullUrl = '$baseUrl$path';
    debugPrint(
      'ApiClient [POST] request: $fullUrl, body: ${json.encode(body)}',
    );

    return http
        .post(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        )
        .timeout(_timeoutDuration);
  }
}

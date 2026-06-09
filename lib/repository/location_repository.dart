import 'dart:convert';
import '../models/location_model.dart';
import '../api/api_client.dart';
import '../api/api_urls.dart';

class LocationRepository {
  Future<List<LocationModel>> fetchLocations() async {
    final response = await ApiClient.get(ApiUrls.viewLocation);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == true || data['status'] == 'true') {
        final List<dynamic> list = data['data'] ?? [];
        return list.map((item) => LocationModel.fromJson(item)).toList();
      } else {
        throw Exception(data['Message'] ?? 'Failed to load locations from API');
      }
    } else {
      throw Exception('Server error: HTTP ${response.statusCode}');
    }
  }

  Future<bool> addLocation({required String name, required String isCurrentLocation}) async {
    final response = await ApiClient.post(ApiUrls.location, {
      'type': 'add',
      'name': name,
      'is_current_location': isCurrentLocation,
    });
    return _parseStatusResponse(response);
  }

  Future<bool> editLocation({required String id, required String name, required String isCurrentLocation}) async {
    final response = await ApiClient.post(ApiUrls.location, {
      'type': 'edit',
      'id': id,
      'name': name,
      'is_current_location': isCurrentLocation,
    });
    return _parseStatusResponse(response);
  }

  Future<bool> deleteLocation(String id) async {
    final response = await ApiClient.post(ApiUrls.location, {
      'type': 'delete',
      'id': id,
    });
    return _parseStatusResponse(response);
  }

  bool _parseStatusResponse(dynamic httpResponse) {
    if (httpResponse.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(httpResponse.body);
      if (data['status'] == true || data['status'] == 'true') {
        return true;
      } else {
        throw Exception(data['Message'] ?? 'Operation failed');
      }
    } else {
      throw Exception('Server error: HTTP ${httpResponse.statusCode}');
    }
  }
}

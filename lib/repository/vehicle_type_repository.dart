import 'dart:convert';
import '../models/vehicle_type_model.dart';
import '../api/api_client.dart';
import '../api/api_urls.dart';

class VehicleTypeRepository {
  Future<List<VehicleTypeModel>> fetchVehicleTypes() async {
    final response = await ApiClient.get(ApiUrls.viewVehicleType);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == true || data['status'] == 'true') {
        final List<dynamic> list = data['data'] ?? [];
        return list.map((item) => VehicleTypeModel.fromJson(item)).toList();
      } else {
        throw Exception(data['Message'] ?? 'Failed to load vehicle types from API');
      }
    } else {
      throw Exception('Server error: HTTP ${response.statusCode}');
    }
  }

  Future<bool> addVehicleType({
    required String name,
  }) async {
    final response = await ApiClient.post(ApiUrls.vehicleType, {
      'type': 'add',
      'name': name,
    });
    return _parseStatusResponse(response);
  }

  Future<bool> editVehicleType({
    required String id,
    required String name,
  }) async {
    final response = await ApiClient.post(ApiUrls.vehicleType, {
      'type': 'edit',
      'id': id,
      'name': name,
    });
    return _parseStatusResponse(response);
  }

  Future<bool> deleteVehicleType(String id) async {
    final response = await ApiClient.post(ApiUrls.vehicleType, {
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

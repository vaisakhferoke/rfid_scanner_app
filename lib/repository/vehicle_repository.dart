import 'dart:convert';
import '../models/vehicle_model.dart';
import '../api/api_client.dart';
import '../api/api_urls.dart';

class VehicleRepository {
  Future<List<VehicleModel>> fetchVehicles() async {
    final response = await ApiClient.get(ApiUrls.viewVehicle);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == true || data['status'] == 'true') {
        final List<dynamic> list = data['data'] ?? [];
        return list.map((item) => VehicleModel.fromJson(item)).toList();
      } else {
        throw Exception(data['Message'] ?? 'Failed to load vehicles from API');
      }
    } else {
      throw Exception('Server error: HTTP ${response.statusCode}');
    }
  }

  Future<bool> addVehicle({
    required String name,
    required String vehicleTypeId,
    required String remark,
  }) async {
    final response = await ApiClient.post(ApiUrls.vehicle, {
      'type': 'add',
      'name': name,
      'vehicle_type_id': vehicleTypeId,
      'remark': remark,
    });
    return _parseStatusResponse(response);
  }

  Future<bool> editVehicle({
    required String id,
    required String name,
    required String vehicleTypeId,
    required String remark,
  }) async {
    final response = await ApiClient.post(ApiUrls.vehicle, {
      'type': 'edit',
      'id': id,
      'name': name,
      'vehicle_type_id': vehicleTypeId,
      'remark': remark,
    });
    return _parseStatusResponse(response);
  }

  Future<bool> deleteVehicle(String id) async {
    final response = await ApiClient.post(ApiUrls.vehicle, {
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

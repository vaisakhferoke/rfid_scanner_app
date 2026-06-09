import 'dart:convert';
import 'package:get/get.dart';
import 'package:event_rfid_app/api/api_client.dart';
import 'package:event_rfid_app/api/api_urls.dart';
import 'package:event_rfid_app/models/user_detail_model.dart';

class UserListController extends GetxController {
  final RxList<UserDetailModel> users = <UserDetailModel>[].obs;
  final RxBool isLoading = false.obs;

  late String type;
  late String locationId;
  String? vehicleId;
  String keyword = '';
  final RxnString filterVehicleId = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    type = args['type'] ?? '';
    locationId = args['location_id'] ?? '';
    vehicleId = args['vehicle_id'];
    if (vehicleId != null && vehicleId!.isNotEmpty) {
      filterVehicleId.value = vehicleId;
    }

    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> payload = {
        "type": type,
        "location_id": locationId,
        "keyword": keyword,
      };
      if (vehicleId != null) {
        payload["vehicle_id"] = vehicleId;
      }

      final response = await ApiClient.post(ApiUrls.listUserDetails, payload);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true || data['status'] == 'true') {
          final List<dynamic> list = data['data'] ?? [];
          users.assignAll(
            list.map((e) => UserDetailModel.fromJson(e)).toList(),
          );
        } else {
          users.clear();
          Get.snackbar(
            'Notice',
            data['Message'] ?? 'No data found',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void search(String val) {
    keyword = val;
    fetchUsers();
  }

  void setVehicleFilter(String? vId) {
    filterVehicleId.value = vId;
    if (vId == null || vId.isEmpty) {
      vehicleId = null;
    } else {
      vehicleId = vId;
    }
    fetchUsers();
  }
}

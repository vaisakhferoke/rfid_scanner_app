import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_client.dart';

class UpdateUserTripController extends GetxController {
  final tagController = TextEditingController();
  final RxString selectedVehicleId = ''.obs;
  final RxString selectedLocationId = ''.obs;
  final RxString selectedDay = 'day1'.obs; // Defaulting to day1 as per API spec
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    tagController.dispose();
    super.onClose();
  }

  Future<void> submitTrip() async {
    if (tagController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a Tag Number', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedVehicleId.value.isEmpty) {
      Get.snackbar('Error', 'Please select a Vehicle', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedLocationId.value.isEmpty) {
      Get.snackbar('Error', 'Please select a Location', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiClient.post('flutter/event_phuket/update_user_trip.aspx', {
        "unique_id": tagController.text,
        "vehicle_id": selectedVehicleId.value,
        "location_id": selectedLocationId.value,
        "day": selectedDay.value,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true || data['status'] == 'true') {
          tagController.clear();
          selectedVehicleId.value = '';
          selectedLocationId.value = '';
          Get.snackbar('Success', data['Message'] ?? 'Trip updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Error', data['Message'] ?? 'Failed to update trip', backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

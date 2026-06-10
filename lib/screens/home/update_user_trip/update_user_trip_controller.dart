import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_client.dart';
import '../../../controllers/location_master_controller.dart';

class UpdateUserTripController extends GetxController {
  final tagController = TextEditingController();
  final RxString selectedVehicleId = ''.obs;
  final RxString selectedLocationId = ''.obs;
  final RxString selectedDay = ''.obs; // Defaulting to day1 as per API spec
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setDefaultLocation();
    fetchEventDay();
  }

  Future<void> fetchEventDay() async {
    try {
      final response = await ApiClient.get(
        'flutter/event_phuket/view_event_settings.aspx',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          var daySetting = data.firstWhereOrNull(
            (item) =>
                item['value']?.toString().toLowerCase() == 'current day' ||
                item['key']?.toString().toLowerCase() == 'current day',
          );
          daySetting ??= data.firstWhereOrNull(
            (item) =>
                item['key']?.toString().toLowerCase().contains('day') == true ||
                item['value']?.toString().toLowerCase().contains('day') == true,
          );

          if (daySetting != null) {
            final keyStr = daySetting['key']?.toString() ?? "";
            final valStr = daySetting['value']?.toString() ?? "";

            if (valStr.toLowerCase() == "current day") {
              selectedDay.value = keyStr;
            } else {
              selectedDay.value = valStr;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching event day: $e');
    }
  }

  void _setDefaultLocation() {
    if (Get.isRegistered<LocationMasterController>()) {
      final locCtrl = Get.find<LocationMasterController>();
      final currentLoc = locCtrl.locations.firstWhereOrNull(
        (l) => l.isCurrentLocation == '1',
      );
      if (currentLoc != null) {
        selectedLocationId.value = currentLoc.id;
      }
    }
  }

  @override
  void onClose() {
    tagController.dispose();
    super.onClose();
  }

  Future<void> submitTrip() async {
    if (tagController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a Tag Number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedVehicleId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Vehicle',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedLocationId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Location',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedDay.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Day',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response =
          await ApiClient.post('flutter/event_phuket/update_user_trip.aspx', {
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
          Get.snackbar(
            'Success',
            data['Message'] ?? 'Trip updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            data['Message'] ?? 'Failed to update trip',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

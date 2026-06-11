import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models/location_wise_report_model.dart';
import '../../../../models/location_model.dart';
import '../../../../controllers/location_master_controller.dart';
import '../../../../config/api_config.dart';
import '../../../../api/api_urls.dart';

class LocationWiseReportController extends GetxController {
  // final LocationMasterController locationMasterController = Get.put(
  //   LocationMasterController(),
  // );

  var arg = Get.arguments;

  var isLoading = false.obs;
  var reportData = <LocationWiseReportModel>[].obs;

  var selectedLocation = Rxn<LocationModel>();

  @override
  void onInit() {
    super.onInit();
    if (arg != null) {
      selectedLocation.value = arg['location'];
      fetchReport();
    }
  }

  Future<void> fetchReport() async {
    final String locId = selectedLocation.value?.id ?? "";
    if (locId.isEmpty) {
      Get.snackbar(
        'Required',
        'Please select a location.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.locationDetails}';

      final Map<String, dynamic> payload = {"location_id": locId};

      debugPrint('LocationWiseReportController POST: $fullUrl');
      debugPrint('Payload: ${json.encode(payload)}');

      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          reportData.value = list
              .map((e) => LocationWiseReportModel.fromJson(e))
              .toList();
        } else {
          reportData.clear();
          Get.snackbar(
            'Notice',
            data['Message'] ?? 'No data found',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'API Error',
          'Server responded with code ${response.statusCode}.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error fetching location wise report: $e');
      Get.snackbar(
        'Network Error',
        'Could not connect to the server.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    selectedLocation.value = null;
    reportData.clear();
  }

  Future<void> deleteVehicleData(String vehicleId, String locationId) async {
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.deleteUserTrip}';

      final Map<String, dynamic> payload = {
        "vehicle_id": vehicleId,
        "location_id": locationId,
      };

      debugPrint('LocationWiseReportController DELETE: $fullUrl');
      debugPrint('Payload: ${json.encode(payload)}');

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF213AEC)),
        ),
        barrierDismissible: false,
      );

      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      Get.back(); // close loading dialog

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          Get.snackbar(
            'Success',
            data['Message'] ?? 'Successfully deleted.',
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          fetchReport(); // Refresh list after delete
        } else {
          Get.snackbar(
            'Notice',
            data['Message'] ?? 'Failed to delete.',
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'API Error',
          'Server responded with code ${response.statusCode}.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Error deleting vehicle data: $e');
      Get.snackbar(
        'Network Error',
        'Could not connect to the server.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

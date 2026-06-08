import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/bus_scanned_report_model.dart';
import '../../../../models/location_model.dart';
import '../../../../models/vehicle_model.dart';
import '../../../../controllers/location_master_controller.dart';
import '../../../../controllers/vehicle_master_controller.dart';
import '../../../../config/api_config.dart';
import '../../../../api/api_urls.dart';

class BusScannedReportController extends GetxController {
  final LocationMasterController locationMasterController = Get.put(
    LocationMasterController(),
  );
  final VehicleMasterController vehicleMasterController = Get.put(
    VehicleMasterController(),
  );

  var isLoading = false.obs;
  var reportData = <BusScannedReportModel>[].obs;

  var selectedBus = Rxn<VehicleModel>();
  var selectedFromLocation = Rxn<LocationModel>();
  var selectedToLocation = Rxn<LocationModel>();
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  Future<void> fetchReport() async {
    isLoading.value = true;
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.listUserDetails}';

      final Map<String, dynamic> payload = {
        "vehicle_id": selectedBus.value?.id ?? "",
        "from_location_id": selectedFromLocation.value?.id ?? "",
        "to_location_id": selectedToLocation.value?.id ?? "",
        "keyword": searchController.text.trim(),
      };

      debugPrint('BusScannedReportController POST: $fullUrl');
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
              .map((e) => BusScannedReportModel.fromJson(e))
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
      debugPrint('Error fetching bus scanned report: $e');
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
    selectedBus.value = null;
    selectedFromLocation.value = null;
    selectedToLocation.value = null;
    searchController.clear();
    fetchReport();
  }

  Future<void> downloadExcel() async {
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String vehicleId = selectedBus.value?.id ?? "";
      final String fromLocId = selectedFromLocation.value?.id ?? "";
      final String toLocId = selectedToLocation.value?.id ?? "";
      final String keyword = searchController.text.trim();

      final String queryParams =
          '?vehicle_id=$vehicleId&from_location_id=$fromLocId&to_location_id=$toLocId&keyword=$keyword';
      final String fullUrl =
          '$baseUrl${ApiUrls.listUserDetailsExcel}$queryParams';

      final Uri url = Uri.parse(fullUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch Excel download link.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error downloading excel: $e');
      Get.snackbar(
        'Error',
        'Could not initiate download.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

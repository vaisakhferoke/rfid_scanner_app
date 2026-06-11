import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models/location_wise_report_model.dart';
import '../../../../models/location_model.dart';
import '../../../../controllers/location_master_controller.dart';
import '../../../../config/api_config.dart';
import '../../../../api/api_urls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';

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

  Future<List<int>?> _generateExcelBytes() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        '#',
        'Location ID',
        'Location',
        'Vehicle ID',
        'Vehicle Name',
        'Scanned Count',
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (int i = 0; i < reportData.length; i++) {
        var item = reportData[i];
        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(item.locationId),
          TextCellValue(item.location),
          TextCellValue(item.vehicleId),
          TextCellValue(item.vehicleName),
          TextCellValue(item.scannedCount),
        ];
        sheetObject.appendRow(row);
      }

      return excel.encode();
    } catch (e) {
      debugPrint('Error generating excel: $e');
      return null;
    }
  }

  Future<void> downloadExcel() async {
    if (reportData.isEmpty) {
      Get.snackbar(
        'Notice',
        'No data to export.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF213AEC)),
        ),
        barrierDismissible: false,
      );

      final bytes = await _generateExcelBytes();

      Get.back(); // close loading dialog

      if (bytes != null) {
        final String locName = selectedLocation.value?.name ?? 'Location';
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/location_wise_report _${locName.replaceAll(" ", "")}_${DateTime.now().millisecond}.xlsx',
        );
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Location Wise Report');
      } else {
        Get.snackbar(
          'Error',
          'Failed to generate Excel file.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Error sharing excel: $e');
      Get.snackbar(
        'Error',
        'Could not share file.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

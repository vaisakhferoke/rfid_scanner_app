import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../models/location_based_user_details_model.dart';
import '../../../../../config/api_config.dart';
import '../../../../../api/api_urls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class LocationBasedUserDetailsController extends GetxController {
  var isLoading = false.obs;
  var userDetails = <LocationBasedUserDetailsModel>[].obs;

  final String locationId;
  final String vehicleId;

  LocationBasedUserDetailsController({
    required this.locationId,
    required this.vehicleId,
  });

  @override
  void onInit() {
    super.onInit();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    isLoading.value = true;
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.locationBasedUserDetails}';

      final Map<String, dynamic> payload = {
        "location_id": locationId,
        "vehicle_id": vehicleId,
      };

      debugPrint('LocationBasedUserDetailsController POST: $fullUrl');
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
          userDetails.value = list
              .map((e) => LocationBasedUserDetailsModel.fromJson(e))
              .toList();
        } else {
          userDetails.clear();
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
      debugPrint('Error fetching location based user details: $e');
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

  Future<void> deleteUser(String userId) async {
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.deleteTrip}';

      final Map<String, dynamic> payload = {
        "vehicle_id": vehicleId,
        "location_id": locationId,
        "user_id": userId,
      };

      debugPrint('LocationBasedUserDetailsController DELETE: $fullUrl');
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
            data['Message'] ?? 'Successfully deleted user.',
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          fetchUserDetails(); // Refresh list after delete
        } else {
          Get.snackbar(
            'Notice',
            data['Message'] ?? 'Failed to delete user.',
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
      debugPrint('Error deleting user: $e');
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
        'Name',
        'Code',
        'Type',
        'State',
        'Given Name',
        'Surname',
        'UID',
        'Date',
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (int i = 0; i < userDetails.length; i++) {
        var user = userDetails[i];
        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(user.name),
          TextCellValue(user.code),
          TextCellValue(user.type),
          TextCellValue(user.state),
          TextCellValue(user.givenname),
          TextCellValue(user.surname),
          TextCellValue(user.uniqId),
          TextCellValue(user.date),
        ];
        sheetObject.appendRow(row);
      }

      return excel.encode();
    } catch (e) {
      debugPrint('Error generating excel: $e');
      return null;
    }
  }

  Future<void> downloadExcel(String locationName) async {
    await shareExcel(
      locationName,
    ); // On mobile, downloading typically involves sharing or saving to files app.
  }

  Future<void> shareExcel(String locationName) async {
    if (userDetails.isEmpty) {
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
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/location_report_${locationName.replaceAll(" ", "")}_${DateTime.now().millisecond}.xlsx',
        );
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Location Based User Report');
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

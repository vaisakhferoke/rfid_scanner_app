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

  Future<void> downloadExcel() async {
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String queryParams =
          '?location_id=$locationId&vehicle_id=$vehicleId';
      final String fullUrl =
          '$baseUrl${ApiUrls.locationBasedUserDetailsExcel}$queryParams';

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

  Future<void> shareExcel() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF213AEC)),
        ),
        barrierDismissible: false,
      );

      final String baseUrl = await ApiConfig.getBaseUrl();
      final String queryParams =
          '?location_id=$locationId&vehicle_id=$vehicleId';
      final String fullUrl =
          '$baseUrl${ApiUrls.locationBasedUserDetailsExcel}$queryParams';

      final response = await http.get(Uri.parse(fullUrl)).timeout(const Duration(seconds: 30));

      Get.back(); // close loading dialog

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/location_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)], text: 'Location Based User Report');
      } else {
        Get.snackbar(
          'Error',
          'Failed to download file for sharing.',
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../models/location_based_user_details_model.dart';
import '../../../../../config/api_config.dart';
import '../../../../../api/api_urls.dart';

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
}

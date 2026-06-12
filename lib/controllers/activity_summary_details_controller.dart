import 'dart:convert';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:event_rfid_app/models/activity_summary_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ActivitySummaryDetailsController extends GetxController {
  var isLoading = false.obs;
  var usersList = <ActivitySummaryDetailModel>[].obs;
  var type = ''.obs;

  @override
  void onInit() {
    super.onInit();
    type.value = Get.arguments['type'] ?? '';
    if (type.value.isNotEmpty) {
      fetchDetails();
    }
  }

  Future<void> fetchDetails() async {
    isLoading(true);
    usersList.clear();
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.post(
        Uri.parse('${baseUrl}flutter/event_phuket/activity_summary_details.aspx'),
        body: {'type': type.value},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          usersList.value = (data['data'] as List)
              .map((e) => ActivitySummaryDetailModel.fromJson(e))
              .toList();
        } else {
          Get.snackbar(
            'Notice',
            data['Message'] ?? 'No data found.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error fetching activity details: $e');
      Get.snackbar(
        'Error',
        'An error occurred while fetching details.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}

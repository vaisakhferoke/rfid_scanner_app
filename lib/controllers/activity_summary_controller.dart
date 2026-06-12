import 'dart:convert';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:event_rfid_app/models/activity_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ActivitySummaryController extends GetxController {
  var isLoading = false.obs;
  var summary = Rxn<ActivitySummaryModel>();

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    isLoading(true);
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.post(
        Uri.parse('${baseUrl}flutter/event_phuket/activity_summary.aspx'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          summary.value = ActivitySummaryModel.fromJson(data);
        } else {
          Get.snackbar(
            'Error',
            data['Message'] ?? 'Failed to fetch summary.',
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
      debugPrint('Error fetching activity summary: $e');
      Get.snackbar(
        'Error',
        'An error occurred while fetching summary.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}

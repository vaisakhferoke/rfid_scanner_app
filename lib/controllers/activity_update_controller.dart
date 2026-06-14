import 'dart:convert';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:event_rfid_app/models/id_card_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ActivityUpdateController extends GetxController {
  late IdCardUser user;

  var isLoading = false.obs;

  var parasailing = ''.obs;
  var snorkeling = ''.obs;
  var bananaBoat = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user = Get.arguments as IdCardUser;

    parasailing.value = user.parasailing ?? '';
    snorkeling.value = user.snorkeling ?? '';
    bananaBoat.value = user.bananaBoat ?? '';
  }

  void updateActivity(String type, String value) {
    if (type == 'parasailing') parasailing.value = value;
    if (type == 'snorkeling') snorkeling.value = value;
    if (type == 'bananaBoat') bananaBoat.value = value;
  }

  Future<void> saveActivities() async {
    isLoading(true);
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      print("URL: $baseUrl${'flutter/event_phuket/update_activity.aspx'}");
      var body = {
        'unique_id': user.uniqueId ?? '',
        'parasailing': parasailing.value,
        'snorkeling': snorkeling.value,
        'banana_boat': bananaBoat.value,
      };
      print("body :$body");
      final response = await http.post(
        Uri.parse('${baseUrl}flutter/event_phuket/update_activity.aspx'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          Get.back(result: true); // Return true to refresh list
          Get.snackbar(
            'Success',
            data['Message'] ?? 'Activities updated successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            data['Message'] ?? 'Failed to update activities.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to connect to the server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}

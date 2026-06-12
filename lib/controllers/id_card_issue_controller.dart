import 'dart:convert';
import 'package:event_rfid_app/models/id_card_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class IdCardIssueController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  
  var isLoading = false.obs;
  var usersList = <IdCardUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchUsers('');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> searchUsers(String keyword) async {
    isLoading(true);
    try {
      final response = await http.post(
        Uri.parse('http://newtest.vkcparivar.com/api/flutter/event_phuket/list_users.aspx'),
        body: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          usersList.value = (data['data'] as List)
              .map((e) => IdCardUser.fromJson(e))
              .toList();
        } else {
          usersList.clear();
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch users.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching users.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> issueIdCard(String type, String uniqueId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await http.post(
        Uri.parse('http://newtest.vkcparivar.com/api/flutter/event_phuket/update_id_card.aspx'),
        body: {
          'type': type,
          'unique_id': uniqueId,
        },
      );

      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          Get.snackbar(
            'Success',
            data['Message'] ?? 'ID Card issued successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Refresh the list
          searchUsers(searchController.text);
        } else {
          Get.snackbar(
            'Error',
            data['Message'] ?? 'Failed to issue ID card.',
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
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

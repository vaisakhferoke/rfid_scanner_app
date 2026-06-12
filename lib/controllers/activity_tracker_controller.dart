import 'dart:async';
import 'dart:convert';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:event_rfid_app/models/id_card_user_model.dart';
import 'package:event_rfid_app/models/rfid_tag.dart';
import 'package:event_rfid_app/services/rfid_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ActivityTrackerController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  var isLoading = false.obs;
  var isScanning = false.obs;
  var usersList = <IdCardUser>[].obs;

  final RfidService _rfidService = RfidService();
  StreamSubscription? _tagStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    searchUsers('');
  }

  @override
  void onClose() {
    stopFinding();
    searchController.dispose();
    super.onClose();
  }

  void performSearch() {
    searchUsers(searchController.text);
  }

  Future<void> stopFinding() async {
    await _tagStreamSubscription?.cancel();
    _tagStreamSubscription = null;
    await _rfidService.stopInventory();
    isScanning(false);
  }

  Future<void> findRfid() async {
    if (isScanning.value) return;

    isScanning(true);

    try {
      bool connected = await _rfidService.checkConnectionStatus();
      if (!connected) {
        connected = await _rfidService.initializeReader();
      }

      if (!connected) {
        Get.snackbar(
          'Error',
          'Failed to connect to RFID reader',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isScanning(false);
        return;
      }

      await _rfidService.startInventory();

      _tagStreamSubscription = _rfidService.tagStream.listen((event) async {
        if (!isScanning.value) return; // Prevent multiple triggers

        final epc = event['epc'] as String?;
        final rssi = event['rssi'] as int?;
        if (epc != null && epc.isNotEmpty) {
          isScanning(false); // Synchronously set to false to block further events

          final rfidTag = RfidTag(
            epc: epc,
            rssi: rssi ?? 0,
            readTime: DateTime.now(),
            count: 1,
          );

          await stopFinding();

          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          searchController.text = rfidTag.displayName;
          searchUsers(rfidTag.displayName);

          Get.snackbar(
            'Tag Found',
            'Successfully read tag data.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      });
    } catch (e) {
      isScanning(false);
      Get.snackbar(
        'Error',
        'Error scanning RFID: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> searchUsers(String keyword) async {
    isLoading(true);
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.post(
        Uri.parse('${baseUrl}flutter/event_phuket/list_users.aspx'),
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
        Get.snackbar(
          'Error',
          'Failed to fetch users.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while fetching users.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}

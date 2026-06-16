import 'dart:async';
import 'dart:convert';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:event_rfid_app/models/id_card_user_model.dart';
import 'package:event_rfid_app/models/rfid_tag.dart';
import 'package:event_rfid_app/services/rfid_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class IdCardIssueController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  var isLoading = false.obs;
  var usersList = <IdCardUser>[].obs;

  var totalCount = '0'.obs;
  var issuedCount = '0'.obs;
  var pendingCount = '0'.obs;
  String type = '';

  var isScanning = false.obs;
  final RfidService _rfidService = RfidService();
  StreamSubscription? _tagStreamSubscription;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    type = Get.arguments['type'] ?? '';
    searchUsers('');
    fetchSummary();
  }

  @override
  void onClose() {
    stopFinding();
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
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
          isScanning(
            false,
          ); // Synchronously set to false to block further events

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

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      searchUsers(query);
    });
  }

  Future<void> fetchSummary() async {
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.post(
        Uri.parse('${baseUrl}flutter/event_phuket/lssue_summary.aspx'),
        body: {'type': type},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          totalCount.value = data['total_count']?.toString() ?? '0';
          issuedCount.value = data['issued_count']?.toString() ?? '0';
          pendingCount.value = data['not_issued_count']?.toString() ?? '0';
        }
      }
    } catch (e) {
      debugPrint('Error fetching summary: $e');
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

  Future<void> issueIdCard(String type, String uniqueId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final String baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.post(
        Uri.parse('${baseUrl}flutter/event_phuket/update_id_card.aspx'),
        body: {'type': type, 'unique_id': uniqueId},
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
          // Refresh the list and summary
          searchUsers(searchController.text);
          fetchSummary();
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models/user_scan_model.dart';
import '../../../../config/api_config.dart';

class UserScanReportController extends GetxController {
  var isLoading = false.obs;
  var reportData = <UserScanModel>[].obs;
  var filteredData = <UserScanModel>[].obs;

  var selectedType = 'evententry'.obs;
  var selectedScanType = 'scanned'.obs;
  var scannedCount = 0.obs;
  var notScannedCount = 0.obs;
  final TextEditingController searchController = TextEditingController();

  final List<String> types = [
    'evententry',
    'award',
    'photobooth',
    'specialaward',
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_filterData);
    fetchReport();
    fetchCounts();
  }

  void _filterData() {
    final keyword = searchController.text.toLowerCase();
    if (keyword.isEmpty) {
      filteredData.value = reportData;
    } else {
      filteredData.value = reportData.where((item) {
        return item.name.toLowerCase().contains(keyword) ||
            item.uniqueId.toLowerCase().contains(keyword) ||
            item.state.toLowerCase().contains(keyword) ||
            item.code.toLowerCase().contains(keyword) ||
            item.givenname.toLowerCase().contains(keyword) ||
            item.surname.toLowerCase().contains(keyword);
      }).toList();
    }
  }

  void setType(String type) {
    selectedType.value = type;
    fetchReport();
    fetchCounts();
  }

  void setScanType(String scanType) {
    selectedScanType.value = scanType;
    fetchReport();
  }

  Future<void> fetchCounts() async {
    try {
      final String baseUrl = await ApiConfig.getBaseUrl2();
      final scannedUrl =
          '${baseUrl}users_list.aspx?type=${selectedType.value}&scan_type=scanned';
      final notScannedUrl =
          '${baseUrl}users_list.aspx?type=${selectedType.value}&scan_type=notscanned';

      final responses = await Future.wait([
        http.get(Uri.parse(scannedUrl)),
        http.get(Uri.parse(notScannedUrl)),
      ]);

      if (responses[0].statusCode == 200) {
        final decoded = json.decode(responses[0].body);
        if (decoded is List) {
          scannedCount.value = decoded.length;
        } else if (decoded is Map && decoded['status'] == true) {
          scannedCount.value = (decoded['data'] as List?)?.length ?? 0;
        }
      }

      if (responses[1].statusCode == 200) {
        final decoded = json.decode(responses[1].body);
        if (decoded is List) {
          notScannedCount.value = decoded.length;
        } else if (decoded is Map && decoded['status'] == true) {
          notScannedCount.value = (decoded['data'] as List?)?.length ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching counts: $e');
    }
  }

  Future<void> fetchReport() async {
    isLoading.value = true;
    try {
      final String baseUrl = await ApiConfig.getBaseUrl2();
      final String fullUrl =
          '${baseUrl}users_list.aspx?type=${selectedType.value}&scan_type=${selectedScanType.value}';

      debugPrint('UserScanReportController GET: $fullUrl');

      final response = await http
          .get(Uri.parse(fullUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        List<dynamic> list = [];
        if (decodedBody is List) {
          list = decodedBody;
        } else if (decodedBody is Map) {
          if (decodedBody['status'] == true) {
            list = decodedBody['data'] ?? [];
          } else {
            Get.snackbar(
              'Notice',
              decodedBody['Message'] ?? 'No data found',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }

        reportData.value = list.map((e) => UserScanModel.fromJson(e)).toList();
        _filterData();

        // Also update the respective count
        if (selectedScanType.value == 'scanned') {
          scannedCount.value = reportData.length;
        } else {
          notScannedCount.value = reportData.length;
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
      debugPrint('Error fetching user scan report: $e');
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

  Future<void> updateUserScan(String uniqueId) async {
    try {
      final String baseUrl = await ApiConfig.getBaseUrl2();
      final String fullUrl =
          '${baseUrl}event_entry?id=$uniqueId&type=${selectedType.value}';

      debugPrint('UserScanReportController UPDATE: $fullUrl');

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF213AEC)),
        ),
        barrierDismissible: false,
      );

      final response = await http
          .get(Uri.parse(fullUrl))
          .timeout(const Duration(seconds: 15));

      Get.back(); // close dialog

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Successfully updated scan status',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchReport(); // refresh the list
        fetchCounts(); // refresh the counts
      } else {
        Get.snackbar(
          'Error',
          'Failed to update. Server responded with code ${response.statusCode}.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Error updating user scan: $e');
      Get.snackbar(
        'Network Error',
        'Could not connect to the server.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

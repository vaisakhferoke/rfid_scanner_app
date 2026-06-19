import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models/user_scan_model.dart';
import '../../../../config/api_config.dart';

class UserScanReportController extends GetxController {
  var isLoading = false.obs;
  var reportData = <UserScanModel>[].obs;
  var filteredData = <UserScanModel>[].obs;

  var selectedType = 'evententry'.obs;
  var selectedScanType = 'notscanned'.obs;
  var scannedCount = 0.obs;
  var notScannedCount = 0.obs;
  final TextEditingController searchController = TextEditingController();

  var awardTypes = <String>['All'].obs;
  var selectedAwardType = 'All'.obs;

  final List<String> types = [
    'evententry',
    'award',
    'photobooth',
    'specialaward',
    'specialphotobooth',
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
    var filtered = reportData.toList();

    if (selectedAwardType.value != 'All') {
      filtered = filtered
          .where((item) => item.awardType == selectedAwardType.value)
          .toList();
    }

    if (keyword.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(keyword) ||
            item.uniqueId.toLowerCase().contains(keyword) ||
            item.state.toLowerCase().contains(keyword) ||
            item.code.toLowerCase().contains(keyword) ||
            item.givenname.toLowerCase().contains(keyword) ||
            item.surname.toLowerCase().contains(keyword);
      }).toList();
    }
    filteredData.value = filtered;
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

  void setAwardType(String type) {
    selectedAwardType.value = type;
    _filterData();
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

        final distinctAwards = reportData
            .map((e) => e.awardType)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();
        distinctAwards.insert(0, 'All');
        awardTypes.value = distinctAwards;
        if (!awardTypes.contains(selectedAwardType.value)) {
          selectedAwardType.value = 'All';
        }

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
        // Get.snackbar(
        //   'Success',
        //   'Successfully updated scan status',
        //   backgroundColor: const Color(0xFF10B981),
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        // flutter toast
        Fluttertoast.showToast(
          msg: 'Successfully updated scan status',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        fetchReport(); // refresh the list
        fetchCounts(); // refresh the counts
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to update.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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

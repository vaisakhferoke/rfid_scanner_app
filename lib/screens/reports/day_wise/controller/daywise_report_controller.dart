import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models/daywise_report_model.dart';
import '../../../../config/api_config.dart';
import '../../../../api/api_urls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class DaywiseReportController extends GetxController {
  var isDaysLoading = false.obs;
  var days = <DistinctDayModel>[].obs;

  var isLoading = false.obs;
  var reportData = <DaywiseReportModel>[].obs;

  var selectedDay = Rxn<DistinctDayModel>();

  @override
  void onInit() {
    super.onInit();
    fetchDays();
  }

  Future<void> fetchDays() async {
    isDaysLoading.value = true;
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.distinctDayCount}';

      final response = await http
          .get(Uri.parse(fullUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          days.value = list.map((e) => DistinctDayModel.fromJson(e)).toList();
          if (days.isNotEmpty) {
            selectedDay.value = days.last;
            fetchReport();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching days: $e');
    } finally {
      isDaysLoading.value = false;
    }
  }

  Future<void> fetchReport() async {
    final String dayVal = selectedDay.value?.day ?? "";
    if (dayVal.isEmpty) {
      Get.snackbar(
        'Required',
        'Please select a day.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.dayBasedUserList}';

      final Map<String, dynamic> payload = {"day": dayVal};

      debugPrint('DaywiseReportController POST: $fullUrl');
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
          reportData.value = list
              .map((e) => DaywiseReportModel.fromJson(e))
              .toList();
        } else {
          reportData.clear();
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
      debugPrint('Error fetching day wise report: $e');
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

  void clearFilters() {
    selectedDay.value = null;
    reportData.clear();
  }

  Future<List<int>?> _generateExcelBytes() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        '#',
        'Location ID',
        'Location',
        'User Count',
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (int i = 0; i < reportData.length; i++) {
        var item = reportData[i];
        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(item.locationId),
          TextCellValue(item.location),
          TextCellValue(item.userCount),
        ];
        sheetObject.appendRow(row);
      }

      return excel.encode();
    } catch (e) {
      debugPrint('Error generating excel: $e');
      return null;
    }
  }

  Future<void> downloadExcel() async {
    if (reportData.isEmpty) {
      Get.snackbar(
        'Notice',
        'No data to export.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF213AEC)),
        ),
        barrierDismissible: false,
      );

      final bytes = await _generateExcelBytes();

      Get.back(); // close loading dialog

      if (bytes != null) {
        final String dayName = selectedDay.value?.day ?? 'Day';
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/daywise_report_${dayName.replaceAll(" ", "")}_${DateTime.now().millisecond}.xlsx',
        );
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Daywise Report');
      } else {
        Get.snackbar(
          'Error',
          'Failed to generate Excel file.',
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

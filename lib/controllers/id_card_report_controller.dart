import 'dart:convert';
import 'dart:io';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:event_rfid_app/models/id_card_user_model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class IdCardReportController extends GetxController {
  var isLoading = false.obs;
  var usersList = <IdCardUser>[].obs;

  var totalCount = '0'.obs;
  var issuedCount = '0'.obs;
  var pendingCount = '0'.obs;

  String type = '';
  var selectedTab = '1'.obs; // '1' for Issued, '0' for Pending

  @override
  void onInit() {
    super.onInit();
    type = Get.arguments['type'] ?? '';
    fetchSummary();
    fetchReportList();
  }

  void setTab(String tab) {
    if (selectedTab.value != tab) {
      selectedTab.value = tab;
      fetchReportList();
    }
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

  Future<void> fetchReportList() async {
    isLoading(true);
    usersList.clear();
    try {
      final String baseUrl = await ApiConfig.getBaseUrl();
      final response = await http.post(
        Uri.parse('${baseUrl}flutter/event_phuket/id_card_report.aspx'),
        body: {'type': type, 'status': selectedTab.value},
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
          'Failed to fetch report.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while fetching report.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<List<int>?> _generateExcelBytes() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        '#',
        'Unique ID',
        'Name',
        'Code',
        'Type',
        'State',
        'Status',
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (int i = 0; i < usersList.length; i++) {
        var item = usersList[i];
        bool isIssued = type == 'travel_id_card'
            ? item.travelIdCard == '1'
            : item.eventIdCard == '1';

        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(item.uniqueId ?? ''),
          TextCellValue(item.name ?? ''),
          TextCellValue(item.code ?? ''),
          TextCellValue(item.type ?? ''),
          TextCellValue(item.state ?? ''),
          TextCellValue(isIssued ? 'Issued' : 'Pending'),
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
    if (usersList.isEmpty) {
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
          child: CircularProgressIndicator(color: Color(0xFF0043A4)),
        ),
        barrierDismissible: false,
      );

      final bytes = await _generateExcelBytes();

      Get.back(); // close loading dialog

      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final statusStr = selectedTab.value == '1' ? 'Issued' : 'Pending';
        final file = File(
          '${tempDir.path}/${type}_${statusStr}_${DateTime.now().millisecond}.xlsx',
        );
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)], text: 'ID Card Report');
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

import 'dart:convert';
import 'dart:io';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:event_rfid_app/models/activity_summary_detail_model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<List<int>?> _generateExcelBytes() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        '#',
        'Unique ID',
        'Name',
        'Code',
        'State',
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (int i = 0; i < usersList.length; i++) {
        var item = usersList[i];
        String displayName = item.name.isNotEmpty ? item.name : item.givenname;

        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(item.uniqueId),
          TextCellValue(displayName),
          TextCellValue(item.code),
          TextCellValue(item.state),
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

      if (Get.isDialogOpen ?? false) Get.back(); // close loading dialog

      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/${type.value}_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        );
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)], text: 'Activity Summary Details');
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

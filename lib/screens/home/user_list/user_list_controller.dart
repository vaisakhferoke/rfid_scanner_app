import 'dart:convert';
import 'package:get/get.dart';
import 'package:event_rfid_app/api/api_client.dart';
import 'package:event_rfid_app/api/api_urls.dart';
import 'package:event_rfid_app/models/user_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class UserListController extends GetxController {
  final RxList<UserDetailModel> allUsers = <UserDetailModel>[].obs;
  final RxList<UserDetailModel> users = <UserDetailModel>[].obs;
  final RxBool isLoading = false.obs;

  late String type;
  late String locationId;
  String? vehicleId;
  String keyword = '';
  final RxnString filterVehicleId = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    type = args['type'] ?? '';
    locationId = args['location_id'] ?? '';
    vehicleId = args['vehicle_id'];
    if (vehicleId != null && vehicleId!.isNotEmpty) {
      filterVehicleId.value = vehicleId;
    }

    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> payload = {
        "type": type,
        "location_id": locationId,
        "keyword": "", // Fetch all to support local search
      };
      if (vehicleId != null) {
        payload["vehicle_id"] = vehicleId;
      }

      final response = await ApiClient.post(ApiUrls.listUserDetails, payload);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true || data['status'] == 'true') {
          final List<dynamic> list = data['data'] ?? [];
          allUsers.assignAll(
            list.map((e) => UserDetailModel.fromJson(e)).toList(),
          );
          _applyLocalFilter();
        } else {
          allUsers.clear();
          users.clear();
          Get.snackbar(
            'Notice',
            data['Message'] ?? 'No data found',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _applyLocalFilter() {
    if (keyword.isEmpty) {
      users.assignAll(allUsers);
    } else {
      final query = keyword.toLowerCase();
      users.assignAll(
        allUsers.where((user) {
          return user.user.toLowerCase().contains(query) ||
              user.uniqueId.toLowerCase().contains(query) ||
              user.state.toLowerCase().contains(query) ||
              user.vehicleName.toLowerCase().contains(query);
        }).toList(),
      );
    }
  }

  void search(String val) {
    keyword = val;
    _applyLocalFilter();
  }

  void setVehicleFilter(String? vId) {
    filterVehicleId.value = vId;
    if (vId == null || vId.isEmpty) {
      vehicleId = null;
    } else {
      vehicleId = vId;
    }
    fetchUsers();
  }

  Future<List<int>?> _generateExcelBytes() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        '#',
        'User Name',
        'Unique ID',
        'State',
        'Vehicle Name',
        'Dealer Name',
        'Type',
      ];
      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      // We export the filtered list (users)
      for (int i = 0; i < users.length; i++) {
        var user = users[i];
        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(user.user),
          TextCellValue(user.uniqueId),
          TextCellValue(user.state),
          TextCellValue(user.vehicleName),
          TextCellValue(user.name),
          TextCellValue(user.type),
        ];
        sheetObject.appendRow(row);
      }

      return excel.encode();
    } catch (e) {
      debugPrint('Error generating excel: $e');
      return null;
    }
  }

  Future<void> downloadExcel(String title) async {
    if (users.isEmpty) {
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
        final file = File(
          '${tempDir.path}/user_list_${title.replaceAll(" ", "")}_${DateTime.now().millisecond}.xlsx',
        );
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)], text: 'User List Export');
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

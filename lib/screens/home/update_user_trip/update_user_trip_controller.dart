import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_client.dart';
import '../../../controllers/location_master_controller.dart';
import 'dart:async';
import '../../../services/rfid_service.dart';
import '../../../models/rfid_tag.dart';

class UpdateUserTripController extends GetxController {
  final tagController = TextEditingController();
  final RxString selectedVehicleId = ''.obs;
  final RxString selectedLocationId = ''.obs;
  final RxString selectedDay = ''.obs; // Defaulting to day1 as per API spec
  final RxBool isLoading = false.obs;
  final RxBool isUpdateMode = false.obs;
  final RxString warningMessage = ''.obs;

  final RfidService _rfidService = RfidService();
  StreamSubscription? _tagStreamSubscription;
  final RxBool isFinding = false.obs;
  bool _isRfidInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initRfid();
    _setDefaultLocation();
    fetchEventDay();
    tagController.addListener(() {
      if (isUpdateMode.value) {
        isUpdateMode.value = false;
        warningMessage.value = '';
      }
    });
  }

  Future<void> _initRfid() async {
    try {
      bool connected = await _rfidService.checkConnectionStatus();
      if (!connected) {
        connected = await _rfidService.initializeReader();
      }
      _isRfidInitialized = connected;
    } catch (e) {
      debugPrint('RFID Init Error: $e');
    }
  }

  Future<void> fetchEventDay() async {
    try {
      final response = await ApiClient.get(
        'flutter/event_phuket/view_event_settings.aspx',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          var daySetting = data.firstWhereOrNull(
            (item) =>
                item['value']?.toString().toLowerCase() == 'current day' ||
                item['key']?.toString().toLowerCase() == 'current day',
          );
          daySetting ??= data.firstWhereOrNull(
            (item) =>
                item['key']?.toString().toLowerCase().contains('day') == true ||
                item['value']?.toString().toLowerCase().contains('day') == true,
          );

          if (daySetting != null) {
            final keyStr = daySetting['key']?.toString() ?? "";
            final valStr = daySetting['value']?.toString() ?? "";

            if (valStr.toLowerCase() == "current day") {
              selectedDay.value = keyStr;
            } else {
              selectedDay.value = valStr;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching event day: $e');
    }
  }

  void _setDefaultLocation() {
    if (Get.isRegistered<LocationMasterController>()) {
      final locCtrl = Get.find<LocationMasterController>();
      final currentLoc = locCtrl.locations.firstWhereOrNull(
        (l) => l.isCurrentLocation == '1',
      );
      if (currentLoc != null) {
        selectedLocationId.value = currentLoc.id;
      }
    }
  }

  @override
  void onClose() {
    stopFinding();
    tagController.dispose();
    super.onClose();
  }

  Future<void> stopFinding() async {
    await _tagStreamSubscription?.cancel();
    _tagStreamSubscription = null;
    await _rfidService.stopInventory();
    isFinding.value = false;
  }

  void findSingleTag() async {
    if (isFinding.value) return;

    if (!_isRfidInitialized) {
      await _initRfid();
    }

    isFinding.value = true;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Finding Tag...',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0043A4)),
            ),
            SizedBox(height: 16),
            Text(
              'Bring a tag near the scanner.',
              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              stopFinding();
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF0043A4)),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    await _rfidService.startInventory();

    _tagStreamSubscription = _rfidService.tagStream.listen((event) async {
      final epc = event['epc'] as String?;
      final rssi = event['rssi'] as int?;
      if (epc != null && epc.isNotEmpty) {
        final rfidTag = RfidTag(
          epc: epc,
          rssi: rssi ?? 0,
          readTime: DateTime.now(),
          count: 1,
        );
        debugPrint('Tag Found: ${rfidTag.displayName}');

        await stopFinding();
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        tagController.text = rfidTag.displayName;

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
  }

  Future<void> submitTrip() async {
    if (tagController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a Tag Number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedVehicleId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Vehicle',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedLocationId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Location',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedDay.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a Day',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    warningMessage.value = '';
    try {
      final Map<String, dynamic> payload = {
        "unique_id": tagController.text,
        "vehicle_id": selectedVehicleId.value,
        "location_id": selectedLocationId.value,
        "day": selectedDay.value,
      };

      if (isUpdateMode.value) {
        payload["type"] = "update";
      }

      final response = await ApiClient.post(
        'flutter/event_phuket/update_user_trip.aspx',
        payload,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true || data['status'] == 'true') {
          tagController.clear();
          selectedVehicleId.value = '';
          selectedLocationId.value = '';
          isUpdateMode.value = false;
          Get.snackbar(
            'Success',
            data['Message'] ?? 'Trip updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          if (data['Message'] == 'Passenger already added.' &&
              !isUpdateMode.value) {
            String vehicleName = data['vehicle'] ?? '';
            warningMessage.value =
                'Passenger already added${vehicleName.isNotEmpty ? ' in $vehicleName' : ''}.';
            isUpdateMode.value = true;
          } else {
            Get.snackbar(
              'Error',
              data['Message'] ?? 'Failed to update trip',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

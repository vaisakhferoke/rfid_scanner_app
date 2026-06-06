import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models/rfid_tag.dart';
import '../../../../models/location_model.dart';
import '../../../../models/vehicle_model.dart';
import '../../../../services/rfid_service.dart';
import '../../../../controllers/location_master_controller.dart';
import '../../../../controllers/vehicle_master_controller.dart';
import '../../../../config/api_config.dart';
import '../../../../api/api_urls.dart';
import '../scan_details_screen.dart';

class BusScanController extends GetxController with WidgetsBindingObserver {
  final RfidService _rfidService = RfidService();

  // Master controllers
  final LocationMasterController locationMasterController = Get.put(
    LocationMasterController(),
  );
  final VehicleMasterController vehicleMasterController = Get.put(
    VehicleMasterController(),
  );

  // Connection and Scanning States
  var isConnected = false.obs;
  var isScanning = false.obs;

  // Selected Locations & Bus
  var selectedFromLocation = Rxn<LocationModel>();
  var selectedToLocation = Rxn<LocationModel>();
  var selectedBus = Rxn<VehicleModel>();

  // Scanned Tags
  var scannedTags = <RfidTag>[].obs;

  StreamSubscription? _tagSubscription;
  bool _showResumeWarning = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _initializeReader();
    _rfidService.registerPhysicalTriggerCallback(_handlePhysicalTrigger);
  }

  bool setFromLocation(LocationModel location) {
    if (selectedToLocation.value != null &&
        selectedToLocation.value!.id == location.id) {
      Get.snackbar(
        'Validation Error',
        'From Location cannot be the same as To Location.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    selectedFromLocation.value = location;
    return true;
  }

  bool setToLocation(LocationModel location) {
    if (selectedFromLocation.value != null &&
        selectedFromLocation.value!.id == location.id) {
      Get.snackbar(
        'Validation Error',
        'To Location cannot be the same as From Location.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    selectedToLocation.value = location;
    return true;
  }

  Future<void> _initializeReader() async {
    bool connected = await _rfidService.initializeReader();
    isConnected.value = connected;
  }

  Future<void> retryConnection() async {
    bool connected = await _rfidService.initializeReader();
    isConnected.value = connected;
  }

  void _handlePhysicalTrigger() {
    if (isScanning.value) {
      stopScan();
    } else {
      startScan();
    }
  }

  Future<void> startScan() async {
    if (selectedFromLocation.value == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a From Location.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedToLocation.value == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a To Location.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedBus.value == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a Bus.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedFromLocation.value!.id == selectedToLocation.value!.id) {
      Get.snackbar(
        'Validation Error',
        'From Location and To Location cannot be the same.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    bool success = await _rfidService.startInventory();
    if (success) {
      isScanning.value = true;
      isConnected.value = true;
      _tagSubscription = _rfidService.tagStream.listen((event) {
        _handleTagEvent(event);
      });
    } else {
      isConnected.value = false;
      Get.snackbar(
        'Connection Error',
        'Could not communicate with the RFID reader module. Please ensure the reader is turned on and fully powered.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> stopScan() async {
    bool success = await _rfidService.stopInventory();
    if (success) {
      isScanning.value = false;
      _tagSubscription?.cancel();
      await updateConnectionStatus();
    }
  }

  Future<void> updateConnectionStatus() async {
    bool connected = await _rfidService.checkConnectionStatus();
    isConnected.value = connected;
  }

  void clearData() {
    scannedTags.clear();
  }

  void _handleTagEvent(Map<String, dynamic> event) {
    String epc = event['epc'];
    int rssi = event['rssi'];
    DateTime readTime = DateTime.now();
    String cleanEpc = epc.trim().toLowerCase();

    // Check if tag is already in scanned list
    int index = scannedTags.indexWhere(
      (t) => t.epc.trim().toLowerCase() == cleanEpc,
    );

    if (index == -1) {
      scannedTags.insert(
        0,
        RfidTag(epc: epc, rssi: rssi, readTime: readTime, count: 1),
      );
    } else {
      var existing = scannedTags[index];
      scannedTags[index] = RfidTag(
        epc: existing.epc,
        rssi: rssi,
        readTime: readTime,
        count: existing.count + 1,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (isScanning.value) {
        stopScan();
        _showResumeWarning = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_showResumeWarning) {
        _showResumeWarning = false;
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Warning'),
              ],
            ),
            content: const Text(
              'RFID scanning was automatically stopped because the app went to the background.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> checkStatus() async {
    if (selectedBus.value == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a Bus first.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (scannedTags.isEmpty) {
      Get.snackbar(
        'No Scans Found',
        'Please scan at least one RFID tag before checking status.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF213AEC))),
      barrierDismissible: false,
    );

    try {
      final String vehicleId = selectedBus.value!.id;
      final List<Map<String, String>> payload = scannedTags.map((tag) {
        return {"vehicle_id": vehicleId, "uniq_id": tag.epc, "day": "1"};
      }).toList();

      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.checkStatus}';
      debugPrint('BusScanController POST Request: $fullUrl');
      debugPrint('Payload: ${json.encode(payload)}');

      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        Get.to(
          () => ScanDetailsScreen(
            scanDetails: data,
            fromLocation: selectedFromLocation.value?.name ?? 'Airport',
            toLocation: selectedToLocation.value?.name ?? 'Hotel',
            busName: selectedBus.value?.name ?? '03',
          ),
        );
      } else {
        Get.snackbar(
          'API Error',
          'Failed to check status. Server responded with code ${response.statusCode}.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint('Error checking status: $e');
      Get.snackbar(
        'Network Error',
        'Could not connect to the server. Please check your network connection and try again.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> submitTrip() async {
    if (selectedBus.value == null ||
        selectedFromLocation.value == null ||
        selectedToLocation.value == null) {
      Get.snackbar(
        'Validation Error',
        'Incomplete route or bus selection.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (scannedTags.isEmpty) {
      Get.snackbar(
        'No Scans Found',
        'Please scan at least one RFID tag before submitting.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF213AEC),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final String vehicleId = selectedBus.value!.id;
      final String fromLocId = selectedFromLocation.value!.id;
      final String toLocId = selectedToLocation.value!.id;

      final List<Map<String, String>> payload = scannedTags.map((tag) {
        return {
          "vehicle_id": vehicleId,
          "uniq_id": tag.epc,
          "from_location_id": fromLocId,
          "to_location_id": toLocId,
          "day": "1"
        };
      }).toList();

      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.submitTrip}';
      debugPrint('BusScanController submitTrip POST: $fullUrl');
      debugPrint('Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 15));

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        Get.snackbar(
          'API Error',
          'Failed to submit data. Server responded with code ${response.statusCode}.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint('Error submitting trip: $e');
      Get.snackbar(
        'Network Error',
        'Could not connect to the server. Please check your network connection.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _tagSubscription?.cancel();
    _rfidService.stopInventory();
    super.onClose();
  }
}

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
import '../../../../api/api_client.dart';
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

  // Event day info

  var day = 'day1'.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _initializeReader();
    _rfidService.registerPhysicalTriggerCallback(_handlePhysicalTrigger);
    fetchEventDay();
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
        return {
          "vehicle_id": vehicleId,
          "uniq_id": tag.displayName,
          "day": day.value,
        };
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
        final bool status = data['status'] ?? false;

        if (status) {
          _showStatusTrueConfirmDialog(data);
        } else {
          Get.to(
            () => ScanDetailsScreen(
              scanDetails: data,
              fromLocation: selectedFromLocation.value?.name ?? '',
              toLocation: selectedToLocation.value?.name ?? '',
              busName: selectedBus.value?.name ?? '0',
            ),
          );
        }
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

  void _showStatusTrueConfirmDialog(Map<String, dynamic> data) {
    final String busName = selectedBus.value?.name ?? 'Unknown';
    final String fromLocation = selectedFromLocation.value?.name ?? 'Unknown';
    final String toLocation = selectedToLocation.value?.name ?? 'Unknown';
    final int passengerCount = data['totalpassengers'] ?? scannedTags.length;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.assignment_outlined, color: Color(0xFF213AEC)),
            SizedBox(width: 8),
            Text('Submit Confirmation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please review the trip summary before submitting to the server:',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('From Location:', fromLocation),
            _buildSummaryRow('To Location:', toLocation),
            _buildSummaryRow('Selected Bus:', busName),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total Passengers:',
              passengerCount.toString(),
              isBold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close summary dialog
              bool success = await submitTrip();
              if (success) {
                _showSuccessDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213AEC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: const Text(
          'Trip data submitted successfully!',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close success dialog
              Get.back(); // Pop BusScanScreen (returns to home)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213AEC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> updateUserBus(String userId) async {
    if (selectedBus.value == null) {
      Get.snackbar(
        'Validation Error',
        'No bus selected.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF213AEC))),
      barrierDismissible: false,
    );

    try {
      final String vehicleId = selectedBus.value!.id;
      final Map<String, String> payload = {
        "user_id": userId,
        "vehicle_id": vehicleId,
        "day": day.value,
      };

      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.updateUserBus}';
      debugPrint('BusScanController updateUserBus POST: $fullUrl');
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
        return true;
      } else {
        Get.snackbar(
          'API Error',
          'Failed to update bus. Server responded with code ${response.statusCode}.',
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
      debugPrint('Error updating user bus: $e');
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
      const Center(child: CircularProgressIndicator(color: Color(0xFF213AEC))),
      barrierDismissible: false,
    );

    try {
      final String vehicleId = selectedBus.value!.id;
      final String fromLocId = selectedFromLocation.value!.id;
      final String toLocId = selectedToLocation.value!.id;

      final List<Map<String, String>> payload = scannedTags.map((tag) {
        return {
          "vehicle_id": vehicleId,
          "uniq_id": tag.displayName,
          "from_location_id": fromLocId,
          "to_location_id": toLocId,
          "day": day.value,
        };
      }).toList();

      final String baseUrl = await ApiConfig.getBaseUrl();
      final String fullUrl = '$baseUrl${ApiUrls.submitTrip}';
      debugPrint('BusScanController submitTrip POST: $fullUrl');
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
              day.value = keyStr;
            } else {
              day.value = valStr;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching event day: $e');
    }
  }

  bool manuallyAddTag(String tagCode) {
    final String cleanCode = tagCode.trim();
    if (cleanCode.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid code.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final String cleanEpc = cleanCode.toLowerCase();
    int index = scannedTags.indexWhere(
      (t) => t.epc.trim().toLowerCase() == cleanEpc,
    );

    if (index == -1) {
      scannedTags.insert(
        0,
        RfidTag(epc: cleanCode, rssi: 0, readTime: DateTime.now(), count: 1),
      );
    } else {
      var existing = scannedTags[index];
      scannedTags[index] = RfidTag(
        epc: existing.epc,
        rssi: existing.rssi,
        readTime: DateTime.now(),
        count: existing.count + 1,
      );
    }
    return true;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _tagSubscription?.cancel();
    _rfidService.stopInventory();
    super.onClose();
  }
}

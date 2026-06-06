import 'dart:async';
import 'package:event_rfid_app/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models/rfid_tag.dart';
import '../../../../services/rfid_service.dart';

class EventEntryScannController extends GetxController
    with WidgetsBindingObserver {
  final RfidService _rfidService = RfidService();
  final String type = Get.arguments['type'] ?? '';

  var isConnected = false.obs;
  var isScanning = false.obs;

  // Tab index: 0 for Pending, 1 for Scanned
  var selectedTab = 0.obs;

  // Track pending and scanned tags
  var pendingTags = <RfidTag>[].obs;
  var scannedTags = <RfidTag>[].obs;

  // Backwards compatibility list
  var tags = <RfidTag>[].obs;
  var totalTagsCount = 0.obs;

  StreamSubscription? _tagSubscription;
  Timer? _apiSyncTimer;
  bool _isSyncing = false;
  bool _showResumeWarning = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeReader();
    _startApiSyncTimer();
    _rfidService.registerPhysicalTriggerCallback(_handlePhysicalTrigger);
  }

  void _startApiSyncTimer() {
    _apiSyncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _processNextPendingTag();
    });
  }

  Future<void> _processNextPendingTag() async {
    if (_isSyncing) return;
    if (pendingTags.isEmpty) return;

    _isSyncing = true;
    final tag = pendingTags.first;

    try {
      // http://192.168.1.14:81/api/event_entry?id=git002,git003&type=evententry
      // print('Printing Process Starting');
      final String baseUrl = await ApiConfig.getBaseUrl2();

      // print(
      //   'Printing URL: $baseUrl/event_entry?id=${tag.displayName}&type=$type',
      // );
      final response = await http
          .get(
            Uri.parse('$baseUrl/event_entry?id=${tag.displayName}&type=$type'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // print('Printing Process Completed');
        pendingTags.removeAt(0);

        // Check if tag already exists in scannedTags
        int existingIndex = scannedTags.indexWhere(
          (t) => t.epc.trim().toLowerCase() == tag.epc.trim().toLowerCase(),
        );

        if (existingIndex != -1) {
          var existingTag = scannedTags[existingIndex];
          scannedTags[existingIndex] = RfidTag(
            epc: existingTag.epc,
            rssi: tag.rssi > 0 ? tag.rssi : existingTag.rssi,
            readTime: DateTime.now(),
            count: existingTag.count + tag.count,
          );
        } else {
          scannedTags.insert(
            0,
            RfidTag(
              epc: tag.epc,
              rssi: tag.rssi,
              readTime: DateTime.now(),
              count: tag.count,
            ),
          );
        }

        // Keep tags list and total count synchronized for compatibility
        tags.assignAll(scannedTags);
        totalTagsCount.value = scannedTags.length;
      } else {
        debugPrint('Failed to sync tag ${tag.epc}: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error syncing tag ${tag.epc}: $e');
    } finally {
      _isSyncing = false;
    }
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

  // Clear resets scanned to 0 and all to Pending
  void clearData() {
    // Move all scanned tags to pending
    for (var tag in scannedTags) {
      // Avoid duplicates in pending
      if (!pendingTags.any(
        (t) => t.epc.trim().toLowerCase() == tag.epc.trim().toLowerCase(),
      )) {
        pendingTags.add(
          RfidTag(epc: tag.epc, rssi: 0, readTime: DateTime.now(), count: 0),
        );
      }
    }
    scannedTags.clear();
    pendingTags.clear();
    tags.clear();
    totalTagsCount.value = 0;
  }

  void _handleTagEvent(Map<String, dynamic> event) {
    String epc = event['epc'];
    int rssi = event['rssi'];
    DateTime readTime = DateTime.now();
    String cleanEpc = epc.trim().toLowerCase();

    // Check if tag is already in pending list or scanned list
    bool isPending = pendingTags.any(
      (t) => t.epc.trim().toLowerCase() == cleanEpc,
    );
    bool isScanned = scannedTags.any(
      (t) => t.epc.trim().toLowerCase() == cleanEpc,
    );

    if (!isPending && !isScanned) {
      // Add to pendingTags list
      pendingTags.add(
        RfidTag(epc: epc, rssi: rssi, readTime: readTime, count: 1),
      );
    } else if (isPending) {
      // If it's already pending, increment count or update RSSI
      int index = pendingTags.indexWhere(
        (t) => t.epc.trim().toLowerCase() == cleanEpc,
      );
      if (index != -1) {
        var existing = pendingTags[index];
        pendingTags[index] = RfidTag(
          epc: existing.epc,
          rssi: rssi,
          readTime: readTime,
          count: existing.count + 1,
        );
      }
    } else if (isScanned) {
      // If it's already scanned/synced, increment its count in the scanned list
      int index = scannedTags.indexWhere(
        (t) => t.epc.trim().toLowerCase() == cleanEpc,
      );
      if (index != -1) {
        var existing = scannedTags[index];
        scannedTags[index] = RfidTag(
          epc: existing.epc,
          rssi: rssi,
          readTime: readTime,
          count: existing.count + 1,
        );
        tags.assignAll(scannedTags);
      }
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

  Future<bool> manuallyUpdateTag(String tagCode, {bool showLoading = true}) async {
    final String cleanCode = tagCode.trim();
    if (cleanCode.isEmpty) {
      if (showLoading) {
        Get.snackbar(
          'Required',
          'Please enter a valid code.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }

    if (showLoading) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF213AEC))),
        barrierDismissible: false,
      );
    }

    try {
      final String baseUrl = await ApiConfig.getBaseUrl2();
      final response = await http
          .get(
            Uri.parse('$baseUrl/event_entry?id=$cleanCode&type=$type'),
          )
          .timeout(const Duration(seconds: 5));

      if (showLoading && (Get.isDialogOpen ?? false)) {
        Get.back(); // Pop loading dialog
      }

      if (response.statusCode == 200) {
        // Add to scannedTags list (or increment count if already exists)
        String cleanEpc = cleanCode.toLowerCase();
        int existingIndex = scannedTags.indexWhere(
          (t) => t.epc.trim().toLowerCase() == cleanEpc,
        );

        if (existingIndex != -1) {
          var existingTag = scannedTags[existingIndex];
          scannedTags[existingIndex] = RfidTag(
            epc: existingTag.epc,
            rssi: existingTag.rssi,
            readTime: DateTime.now(),
            count: existingTag.count + 1,
          );
        } else {
          scannedTags.insert(
            0,
            RfidTag(
              epc: cleanCode,
              rssi: 0,
              readTime: DateTime.now(),
              count: 1,
            ),
          );
        }

        // Keep tags list and total count synchronized for compatibility
        tags.assignAll(scannedTags);
        totalTagsCount.value = scannedTags.length;
        
        return true;
      } else {
        if (showLoading) {
          Get.snackbar(
            'Sync Error',
            'Failed to update code. Server responded with code ${response.statusCode}.',
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return false;
      }
    } catch (e) {
      if (showLoading && (Get.isDialogOpen ?? false)) {
        Get.back(); // Pop loading dialog
      }
      debugPrint('Error manually syncing tag: $e');
      if (showLoading) {
        Get.snackbar(
          'Network Error',
          'Could not connect to the server. Please check your network connection.',
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
  }


  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _tagSubscription?.cancel();
    _apiSyncTimer?.cancel();
    _rfidService.stopInventory();
    super.onClose();
  }
}

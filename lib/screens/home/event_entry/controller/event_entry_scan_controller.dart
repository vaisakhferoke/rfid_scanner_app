import 'dart:async';
import 'package:get/get.dart';
import '../../../../models/rfid_tag.dart';
import '../../../../services/rfid_service.dart';

class EventEntryScannController extends GetxController {
  final RfidService _rfidService = RfidService();

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

  @override
  void onInit() {
    super.onInit();
    _initializeReader();

    _rfidService.registerPhysicalTriggerCallback(_handlePhysicalTrigger);
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
    tags.clear();
    totalTagsCount.value = 0;
  }

  void _handleTagEvent(Map<String, dynamic> event) {
    String epc = event['epc'];
    int rssi = event['rssi'];
    DateTime readTime = DateTime.now();
    String cleanEpc = epc.trim().toLowerCase();

    // Check if tag is in pending list
    int pendingIndex = pendingTags.indexWhere(
      (t) => t.epc.trim().toLowerCase() == cleanEpc,
    );

    if (pendingIndex != -1) {
      // It's in pending! Move it to scanned
      var pendingTag = pendingTags[pendingIndex];
      pendingTags.removeAt(pendingIndex);

      var newScannedTag = RfidTag(
        epc: pendingTag.epc,
        rssi: rssi,
        readTime: readTime,
        count: 1,
      );
      scannedTags.insert(0, newScannedTag); // insert at top of scanned list
    } else {
      // Check if tag already exists in scanned list
      int existingIndex = scannedTags.indexWhere(
        (tag) => tag.epc.trim().toLowerCase() == cleanEpc,
      );

      if (existingIndex != -1) {
        // Duplicate tag in scanned list: update count and rssi
        var existingTag = scannedTags[existingIndex];
        scannedTags[existingIndex] = RfidTag(
          epc: existingTag.epc,
          rssi: rssi,
          readTime: readTime,
          count: existingTag.count + 1,
        );
      } else {
        // Completely new tag not in pending: add to scanned list
        scannedTags.insert(
          0,
          RfidTag(epc: epc, rssi: rssi, readTime: readTime, count: 1),
        );
      }
    }

    // Keep tags list and total count synchronized for compatibility
    tags.assignAll(scannedTags);
    totalTagsCount.value = scannedTags.length;
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    _rfidService.stopInventory();
    super.onClose();
  }
}

import 'dart:async';
import 'package:get/get.dart';
import '../../../../models/rfid_tag.dart';
import '../../../../services/rfid_service.dart';

class EventEntryScannController extends GetxController {
  final RfidService _rfidService = RfidService();

  var isConnected = false.obs;
  var isScanning = false.obs;
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

  void clearData() {
    tags.clear();
    totalTagsCount.value = 0;
  }

  void _handleTagEvent(Map<String, dynamic> event) {
    String epc = event['epc'];
    int rssi = event['rssi'];
    // For simplicity, we just use current time for readTime
    DateTime readTime = DateTime.now();

    // Check if tag already exists in the list
    int existingIndex = tags.indexWhere((tag) => tag.epc == epc);

    if (existingIndex != -1) {
      // Duplicate tag: update count and rssi
      var existingTag = tags[existingIndex];
      existingTag.count++;
      // We'll replace the old tag object to trigger GetX reactivity nicely,
      // or we could use .refresh() on the list.
      tags[existingIndex] = RfidTag(
        epc: existingTag.epc,
        rssi: rssi, // update with latest rssi
        readTime: readTime, // update with latest readTime
        count: existingTag.count,
      );
    } else {
      // New tag
      tags.add(RfidTag(epc: epc, rssi: rssi, readTime: readTime));
    }

    // Update total read count (this counts every single scan event, or could just be tags.length for unique tags. Based on instructions: "Total Tags Count" usually means unique tags count, but sometimes total read counts. I will use tags.length for unique.)
    totalTagsCount.value = tags.length;
  }

  @override
  void onClose() {
    _tagSubscription?.cancel();
    _rfidService.stopInventory();
    super.onClose();
  }
}

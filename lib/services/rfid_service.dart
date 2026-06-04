import 'package:flutter/services.dart';

class RfidService {
  static const MethodChannel _methodChannel = MethodChannel('com.example.event_rfid_app/rfid_channel');
  static const EventChannel _eventChannel = EventChannel('com.example.event_rfid_app/rfid_events');

  // Initialize the reader
  Future<bool> initializeReader() async {
    try {
      final bool result = await _methodChannel.invokeMethod('initializeReader');
      return result;
    } on PlatformException catch (e) {
      print("Failed to initialize reader: '${e.message}'.");
      return false;
    }
  }

  // Check connection status
  Future<bool> checkConnectionStatus() async {
    try {
      final bool result = await _methodChannel.invokeMethod('checkConnectionStatus');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check connection status: '${e.message}'.");
      return false;
    }
  }

  // Start continuous inventory scanning
  Future<bool> startInventory() async {
    try {
      final bool result = await _methodChannel.invokeMethod('startInventory');
      return result;
    } on PlatformException catch (e) {
      print("Failed to start inventory: '${e.message}'.");
      return false;
    }
  }

  // Stop continuous inventory scanning
  Future<bool> stopInventory() async {
    try {
      final bool result = await _methodChannel.invokeMethod('stopInventory');
      return result;
    } on PlatformException catch (e) {
      print("Failed to stop inventory: '${e.message}'.");
      return false;
    }
  }

  // Write EPC data to target tag
  Future<bool> writeTag({
    required String hexData,
    String password = "00000000",
    int membank = 1,
    int address = 2,
    int wordCount = 3,
  }) async {
    try {
      final bool result = await _methodChannel.invokeMethod('writeTag', {
        'password': password,
        'membank': membank,
        'address': address,
        'wordCount': wordCount,
        'hexData': hexData,
      });
      return result;
    } on PlatformException catch (e) {
      print("Failed to write tag: '${e.message}'.");
      return false;
    }
  }

  // Stream of RFID tag events
  Stream<Map<String, dynamic>> get tagStream {
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      return Map<String, dynamic>.from(event);
    });
  }

  // Register callback for physical trigger button presses
  void registerPhysicalTriggerCallback(Function() callback) {
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'physicalTriggerPressed') {
        callback();
      }
    });
  }
}

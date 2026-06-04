import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:battery_plus/battery_plus.dart';

class BatteryController extends GetxController {
  final Battery _battery = Battery();

  final RxInt batteryLevel = 100.obs;
  final Rx<BatteryState> batteryState = BatteryState.unknown.obs;

  StreamSubscription<BatteryState>? _stateSubscription;
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    _fetchBatteryDetails();

    // Subscribe to state change events (charging, full, discharging)
    _stateSubscription = _battery.onBatteryStateChanged.listen((state) {
      batteryState.value = state;
      _fetchBatteryDetails();
    });

    // Fallback/regular updates every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchBatteryDetails();
    });
  }

  Future<void> _fetchBatteryDetails() async {
    try {
      final level = await _battery.batteryLevel;
      batteryLevel.value = level;
      
      final state = await _battery.batteryState;
      batteryState.value = state;
    } catch (e) {
      debugPrint('Failed to get battery details: $e');
    }
  }

  // Getters
  bool get isLowBattery => batteryLevel.value < 20;
  bool get isCharging => batteryState.value == BatteryState.charging;
  
  Color get batteryColor {
    if (isCharging) {
      return const Color(0xFF10B981); // Emerald green for charging
    }
    if (batteryLevel.value < 20) {
      return const Color(0xFFEF4444); // Critical red
    }
    if (batteryLevel.value < 35) {
      return const Color(0xFFF59E0B); // Amber warning
    }
    return const Color(0xFF10B981); // Green for healthy battery
  }

  IconData get batteryIcon {
    if (isCharging) {
      return Icons.battery_charging_full_rounded;
    }
    
    final level = batteryLevel.value;
    if (level >= 90) {
      return Icons.battery_full_rounded;
    } else if (level >= 70) {
      return Icons.battery_6_bar_rounded;
    } else if (level >= 50) {
      return Icons.battery_4_bar_rounded;
    } else if (level >= 30) {
      return Icons.battery_3_bar_rounded;
    } else if (level >= 20) {
      return Icons.battery_2_bar_rounded;
    } else {
      return Icons.battery_alert_rounded;
    }
  }

  @override
  void onClose() {
    _stateSubscription?.cancel();
    _pollingTimer?.cancel();
    super.onClose();
  }
}

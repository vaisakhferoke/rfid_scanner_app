import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rfid_service.dart';

class RangeController extends GetxController {
  final RfidService _rfidService = RfidService();
  static const String _prefKey = 'rfid_power_level';

  final RxInt powerLevel = 30.obs; // Default power level is 30 dBm
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPersistedPower();
  }

  Future<void> _loadPersistedPower() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPower = prefs.getInt(_prefKey);
      if (savedPower != null && savedPower >= 5 && savedPower <= 33) {
        powerLevel.value = savedPower;
      }
      
      // If reader is already connected, apply it
      final connected = await _rfidService.checkConnectionStatus();
      if (connected) {
        await _rfidService.setPower(powerLevel.value);
      }
    } catch (e) {
      debugPrint('Failed to load persisted range/power: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Called when reader is initialized to ensure hardware is synced with local preference
  Future<void> applyPersistedPower() async {
    try {
      final success = await _rfidService.setPower(powerLevel.value);
      if (success) {
        debugPrint('Applied persisted power level: ${powerLevel.value} dBm');
      } else {
        debugPrint('Failed to apply persisted power level to device');
      }
    } catch (e) {
      debugPrint('Error applying persisted power level: $e');
    }
  }

  Future<void> fetchCurrentPower() async {
    isLoading.value = true;
    try {
      final power = await _rfidService.getPower();
      if (power >= 5 && power <= 33) {
        powerLevel.value = power;
        // Save back in case it changed externally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefKey, power);
      }
    } catch (e) {
      debugPrint('Failed to fetch current range/power: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> setPowerLevel(int power) async {
    if (power < 5 || power > 33) return false;
    
    isLoading.value = true;
    try {
      // 1. Try to set on physical hardware
      final success = await _rfidService.setPower(power);
      
      // 2. Update local state and persist
      powerLevel.value = power;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, power);
      
      return success;
    } catch (e) {
      debugPrint('Failed to set range/power: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> incrementPower() async {
    if (powerLevel.value < 33) {
      await setPowerLevel(powerLevel.value + 1);
    }
  }

  Future<void> decrementPower() async {
    if (powerLevel.value > 5) {
      await setPowerLevel(powerLevel.value - 1);
    }
  }

  // Getters
  String get rangeLabel {
    final level = powerLevel.value;
    if (level <= 15) {
      return 'Short Range';
    } else if (level >= 25) {
      return 'Long Range';
    } else {
      return 'Medium Range';
    }
  }

  Color get rangeColor {
    final level = powerLevel.value;
    if (level <= 15) {
      return const Color(0xFFF59E0B);
    } else if (level >= 25) {
      return const Color(0xFF10B981);
    } else {
      return const Color(0xFF3B82F6);
    }
  }
}

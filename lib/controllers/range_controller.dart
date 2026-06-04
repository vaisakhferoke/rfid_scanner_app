import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/rfid_service.dart';

class RangeController extends GetxController {
  final RfidService _rfidService = RfidService();

  final RxInt powerLevel = 30.obs; // Default power level is 30 dBm
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentPower();
  }

  Future<void> fetchCurrentPower() async {
    isLoading.value = true;
    try {
      final power = await _rfidService.getPower();
      if (power >= 5 && power <= 33) {
        powerLevel.value = power;
      }
    } catch (e) {
      debugPrint('Failed to fetch initial range/power: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> setPowerLevel(int power) async {
    if (power < 5 || power > 33) return false;
    
    isLoading.value = true;
    try {
      final success = await _rfidService.setPower(power);
      if (success) {
        powerLevel.value = power;
        return true;
      }
      return false;
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
      return const Color(0xFFF59E0B); // Amber for short range
    } else if (level >= 25) {
      return const Color(0xFF10B981); // Emerald green for long range (matching screenshot)
    } else {
      return const Color(0xFF3B82F6); // Blue for medium range
    }
  }
}

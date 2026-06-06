import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_client.dart';

class EventSettingModel {
  final String id;
  final String key;
  final String value;

  EventSettingModel({required this.id, required this.key, required this.value});

  factory EventSettingModel.fromJson(Map<String, dynamic> json) {
    return EventSettingModel(
      id: json['id']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'key': key, 'value': value};
  }
}

class EventSettingsController extends GetxController {
  final RxList<EventSettingModel> settingsList = <EventSettingModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEventSettings();
  }

  Future<void> fetchEventSettings() async {
    isLoading.value = true;
    try {
      final response = await ApiClient.get(
        'flutter/event_phuket/view_event_settings.aspx',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final List<dynamic> dataList = responseData['data'] ?? [];
          settingsList.assignAll(
            dataList.map((item) => EventSettingModel.fromJson(item)).toList(),
          );
        } else {
          _showErrorSnackbar(
            responseData['Message'] ?? 'Failed to load event settings',
          );
        }
      } else {
        _showErrorSnackbar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching event settings: $e');
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEventSetting({
    required String id,
    required String key,
    required String value,
  }) async {
    isLoading.value = true;
    try {
      final response = await ApiClient.post(
        'flutter/event_phuket/update_event_settings.aspx',
        {'id': id, 'key': key, 'value': value},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true ||
            responseData['Message'] == 'Success.') {
          Get.snackbar(
            'Success',
            'Configuration updated successfully!',
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
          fetchEventSettings();
          return true;
        } else {
          _showErrorSnackbar(
            responseData['Message'] ?? 'Failed to update configuration',
          );
        }
      } else {
        _showErrorSnackbar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating event setting: $e');
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}

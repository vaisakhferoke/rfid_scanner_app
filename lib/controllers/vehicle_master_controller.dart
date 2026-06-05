import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/vehicle_model.dart';
import '../config/api_config.dart';
import '../repository/vehicle_repository.dart';

class VehicleMasterController extends GetxController {
  final VehicleRepository _vehicleRepository = VehicleRepository();

  final RxString baseUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxList<VehicleModel> filteredVehicles = <VehicleModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    loadBaseUrlAndFetch();
  }

  Future<void> loadBaseUrlAndFetch() async {
    final url = await ApiConfig.getBaseUrl();
    baseUrl.value = url;
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    isLoading.value = true;
    try {
      final list = await _vehicleRepository.fetchVehicles();
      vehicles.assignAll(list);
      filterVehicles('');
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void filterVehicles(String query) {
    if (query.isEmpty) {
      filteredVehicles.assignAll(vehicles);
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredVehicles.assignAll(
      vehicles.where((vehicle) {
        return vehicle.name.toLowerCase().contains(lowerQuery) ||
            vehicle.vehicleType.toLowerCase().contains(lowerQuery) ||
            vehicle.remark.toLowerCase().contains(lowerQuery);
      }).toList(),
    );
  }

  Future<void> saveVehicle({
    required String type, // 'add' or 'edit'
    String? id,
    required String name,
    required String vehicleType,
    required String remark,
  }) async {
    isLoading.value = true;
    try {
      bool success = false;
      if (type == 'add') {
        success = await _vehicleRepository.addVehicle(
          name: name,
          vehicleType: vehicleType,
          remark: remark,
        );
      } else if (type == 'edit' && id != null) {
        success = await _vehicleRepository.editVehicle(
          id: id,
          name: name,
          vehicleType: vehicleType,
          remark: remark,
        );
      }

      if (success) {
        Get.snackbar(
          'Success',
          'Vehicle ${type == 'add' ? 'added' : 'updated'} successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        fetchVehicles();
      }
    } catch (e) {
      debugPrint('Error saving vehicle: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVehicle(String id) async {
    isLoading.value = true;
    try {
      bool success = await _vehicleRepository.deleteVehicle(id);
      if (success) {
        Get.snackbar(
          'Success',
          'Vehicle deleted successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        fetchVehicles();
      }
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBaseUrl(String newUrl) async {
    if (newUrl.isNotEmpty) {
      await ApiConfig.setBaseUrl(newUrl);
      baseUrl.value = newUrl;
      fetchVehicles();
    }
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

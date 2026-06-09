import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/vehicle_type_model.dart';
import '../config/api_config.dart';
import '../repository/vehicle_type_repository.dart';

class VehicleTypeController extends GetxController {
  final VehicleTypeRepository _repository = VehicleTypeRepository();

  final RxString baseUrl = ''.obs;
  final RxString baseUrl2 = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<VehicleTypeModel> vehicleTypes = <VehicleTypeModel>[].obs;
  final RxList<VehicleTypeModel> filteredVehicleTypes = <VehicleTypeModel>[].obs;
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
    final url2 = await ApiConfig.getBaseUrl2();
    baseUrl.value = url;
    baseUrl2.value = url2;
    fetchVehicleTypes();
  }

  Future<void> fetchVehicleTypes() async {
    isLoading.value = true;
    try {
      final list = await _repository.fetchVehicleTypes();
      vehicleTypes.assignAll(list);
      filterVehicleTypes('');
    } catch (e) {
      debugPrint('Error fetching vehicle types: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void filterVehicleTypes(String query) {
    if (query.isEmpty) {
      filteredVehicleTypes.assignAll(vehicleTypes);
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredVehicleTypes.assignAll(
      vehicleTypes.where((item) {
        return item.name.toLowerCase().contains(lowerQuery);
      }).toList(),
    );
  }

  Future<void> saveVehicleType({
    required String type, // 'add' or 'edit'
    String? id,
    required String name,
  }) async {
    isLoading.value = true;
    try {
      bool success = false;
      if (type == 'add') {
        success = await _repository.addVehicleType(name: name);
      } else if (type == 'edit' && id != null) {
        success = await _repository.editVehicleType(id: id, name: name);
      }

      if (success) {
        Get.snackbar(
          'Success',
          'Vehicle type ${type == 'add' ? 'added' : 'updated'} successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        fetchVehicleTypes();
      }
    } catch (e) {
      debugPrint('Error saving vehicle type: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVehicleType(String id) async {
    isLoading.value = true;
    try {
      bool success = await _repository.deleteVehicleType(id);
      if (success) {
        Get.snackbar(
          'Success',
          'Vehicle type deleted successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        fetchVehicleTypes();
      }
    } catch (e) {
      debugPrint('Error deleting vehicle type: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/location_model.dart';
import '../config/api_config.dart';
import '../repository/location_repository.dart';

class LocationMasterController extends GetxController {
  final LocationRepository _locationRepository = LocationRepository();

  final RxString baseUrl = ''.obs;
  final RxString baseUrl2 = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  final RxList<LocationModel> filteredLocations = <LocationModel>[].obs;
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
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    isLoading.value = true;
    try {
      final list = await _locationRepository.fetchLocations();
      locations.assignAll(list);
      filterLocations('');
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void filterLocations(String query) {
    if (query.isEmpty) {
      filteredLocations.assignAll(locations);
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredLocations.assignAll(
      locations.where((loc) {
        return loc.name.toLowerCase().contains(lowerQuery);
      }).toList(),
    );
  }

  Future<void> saveLocation({
    required String type, // 'add' or 'edit'
    String? id,
    required String name,
    required String isCurrentLocation,
  }) async {
    if (isCurrentLocation == '1') {
      final existingCurrent = locations.firstWhereOrNull(
        (l) => l.isCurrentLocation == '1' && l.id != id,
      );
      if (existingCurrent != null) {
        _showErrorSnackbar('Only one location can be set as current.');
        return;
      }
    }

    isLoading.value = true;
    try {
      bool success = false;
      if (type == 'add') {
        success = await _locationRepository.addLocation(name: name, isCurrentLocation: isCurrentLocation);
      } else if (type == 'edit' && id != null) {
        success = await _locationRepository.editLocation(id: id, name: name, isCurrentLocation: isCurrentLocation);
      }

      if (success) {
        Get.snackbar(
          'Success',
          'Location ${type == 'add' ? 'added' : 'updated'} successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        fetchLocations();
      }
    } catch (e) {
      debugPrint('Error saving location: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLocation(String id) async {
    isLoading.value = true;
    try {
      bool success = await _locationRepository.deleteLocation(id);
      if (success) {
        Get.snackbar(
          'Success',
          'Location deleted successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        fetchLocations();
      }
    } catch (e) {
      debugPrint('Error deleting location: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBaseUrl(String newUrl, String newUrl2) async {
    if (newUrl.isNotEmpty) {
      await ApiConfig.setBaseUrl(newUrl, newUrl2);
      baseUrl.value = newUrl;
      baseUrl2.value = newUrl2;
      fetchLocations();
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

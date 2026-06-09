import 'dart:convert';
import 'package:event_rfid_app/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_client.dart';
import '../api/api_urls.dart';
import '../repository/location_repository.dart';

class HomeController extends GetxController {
  final LocationRepository _locationRepository = LocationRepository();

  RxBool isLoading = false.obs;
  RxString currentLocationName = 'No Location Set'.obs;

  RxInt totalPassengers = 0.obs;
  RxInt boardedCount = 0.obs;
  RxInt missingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  List<LocationModel> locations = [];

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      // 1. Fetch locations
      locations = await _locationRepository.fetchLocations();

      // 2. Find current location
      final currentLocation = locations.firstWhereOrNull(
        (l) => l.isCurrentLocation == '1',
      );

      if (currentLocation != null) {
        currentLocationName.value = currentLocation.name;

        // 3. Call the API
        final response = await ApiClient.post(ApiUrls.userCountBasedLocation, {
          "location_id": currentLocation.id,
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == true || data['status'] == 'true') {
            totalPassengers.value = data['total_passengers'] ?? 0;
            boardedCount.value = data['boarded_count'] ?? 0;
            missingCount.value = data['missing_count'] ?? 0;
          } else {
            debugPrint('API Error: ${data['Message']}');
          }
        }
      } else {
        currentLocationName.value = 'No Location Set';
        totalPassengers.value = 0;
        boardedCount.value = 0;
        missingCount.value = 0;
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setLocation(LocationModel location) async {
    isLoading.value = true;
    try {
      currentLocationName.value = location.name;

      final response = await ApiClient.post(ApiUrls.userCountBasedLocation, {
        "location_id": location.id,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true || data['status'] == 'true') {
          totalPassengers.value = data['total_passengers'] ?? 0;
          boardedCount.value = data['boarded_count'] ?? 0;
          missingCount.value = data['missing_count'] ?? 0;
        } else {
          debugPrint('API Error: ${data['Message']}');
        }
      }
    } catch (e) {
      debugPrint('Error setting location: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

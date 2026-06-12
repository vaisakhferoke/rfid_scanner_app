import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'update_user_trip_controller.dart';
import '../../../controllers/vehicle_master_controller.dart';
import '../../../controllers/location_master_controller.dart';
import '../../../models/vehicle_model.dart';
import '../../../models/location_model.dart';

class UpdateUserTripScreen extends StatelessWidget {
  UpdateUserTripScreen({super.key});

  final UpdateUserTripController controller = Get.put(
    UpdateUserTripController(),
  );
  final VehicleMasterController vehicleController = Get.put(
    VehicleMasterController(),
  );
  final LocationMasterController locationController = Get.put(
    LocationMasterController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Update User Trip',
              style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final day = controller.selectedDay.value.toUpperCase();
              if (day.isEmpty) return const SizedBox.shrink();
              return Text(
                day,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              );
            }),
          ],
        ),
        backgroundColor: const Color(0xFF0043A4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Tag'),
            const SizedBox(height: 8),
            _buildTextField(
              textController: controller.tagController,
              hintText: 'Enter tag no',
              icon: Icons.tag,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_rounded, color: Color(0xFF0043A4)),
                onPressed: () => controller.findSingleTag(),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Vehicle'),
            const SizedBox(height: 8),
            Obx(() {
              if (vehicleController.isLoading.value &&
                  vehicleController.vehicles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text(
                      'Select Vehicle',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    value: controller.selectedVehicleId.value.isEmpty
                        ? null
                        : controller.selectedVehicleId.value,
                    items: vehicleController.vehicles.map((
                      VehicleModel vehicle,
                    ) {
                      return DropdownMenuItem<String>(
                        value: vehicle.id,
                        child: Text(
                          '${vehicle.name} (${vehicle.vehicleType})',
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedVehicleId.value = newValue;
                      }
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            _buildSectionTitle('Location'),
            const SizedBox(height: 8),
            Obx(() {
              if (locationController.isLoading.value &&
                  locationController.locations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Auto-select the default current location
              if (controller.selectedLocationId.value.isEmpty &&
                  locationController.locations.isNotEmpty) {
                final currentLoc = locationController.locations
                    .firstWhereOrNull((l) => l.isCurrentLocation == '1');
                if (currentLoc != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.selectedLocationId.value = currentLoc.id;
                  });
                }
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text(
                      'Select Location',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    value: controller.selectedLocationId.value.isEmpty
                        ? null
                        : controller.selectedLocationId.value,
                    items: locationController.locations.map((
                      LocationModel location,
                    ) {
                      return DropdownMenuItem<String>(
                        value: location.id,
                        child: Text(
                          location.name,
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null)
                        controller.selectedLocationId.value = newValue;
                    },
                  ),
                ),
              );
            }),
            Obx(() {
              if (controller.warningMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.warningMessage.value,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox(height: 48);
            }),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.submitTrip(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isUpdateMode.value
                        ? Colors.orange.shade700
                        : const Color(0xFF0043A4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.isUpdateMode.value ? 'Update' : 'Submit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF0F172A),
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 15,
            fontFamily: 'Inter',
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

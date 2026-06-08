import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controller/bus_scanned_report_controller.dart';
import '../../../../models/location_model.dart';
import '../../../../models/vehicle_model.dart';

class BusScannedReportScreen extends StatelessWidget {
  final BusScannedReportController controller =
      Get.put(BusScannedReportController());

  BusScannedReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF213AEC),
        foregroundColor: Colors.white,
        title: const Text(
          'Bus Scanned Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFiltersSection(context),
            const Divider(height: 1),
            Expanded(
              child: _buildReportList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBusDropdown(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLocationDropdown(
                  context,
                  title: 'From Location',
                  selectedLocation: controller.selectedFromLocation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLocationDropdown(
                  context,
                  title: 'To Location',
                  selectedLocation: controller.selectedToLocation,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Keyword',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.fetchReport,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF213AEC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusDropdown(BuildContext context) {
    return Obx(() {
      final bus = controller.selectedBus.value;
      return InkWell(
        onTap: () => _showBusPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bus?.name ?? 'Select Bus',
                  style: TextStyle(
                    color: bus != null
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLocationDropdown(BuildContext context,
      {required String title,
      required Rxn<LocationModel> selectedLocation}) {
    return Obx(() {
      final location = selectedLocation.value;
      return InkWell(
        onTap: () => _showLocationPicker(context, selectedLocation),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  location?.name ?? title,
                  style: TextStyle(
                    color: location != null
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            ],
          ),
        ),
      );
    });
  }

  void _showBusPicker(BuildContext context) {
    final vehicles = controller.vehicleMasterController.vehicles;
    if (vehicles.isEmpty) {
      Get.snackbar('Notice', 'No buses available');
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return ListTile(
              title: Text(vehicle.name),
              onTap: () {
                controller.selectedBus.value = vehicle;
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showLocationPicker(
      BuildContext context, Rxn<LocationModel> selectedLocation) {
    final locations = controller.locationMasterController.locations;
    if (locations.isEmpty) {
      Get.snackbar('Notice', 'No locations available');
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return ListTile(
              title: Text(location.name),
              onTap: () {
                selectedLocation.value = location;
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReportList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.reportData.isEmpty) {
        return const Center(
          child: Text(
            'No data found.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.reportData.length,
        itemBuilder: (context, index) {
          final item = controller.reportData[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.user,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.code,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF213AEC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Unique ID: ${item.uniqueId}',
                      style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.directions_bus,
                          size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text('${item.vehicleName} (${item.busNo})',
                          style: const TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text('${item.day} | ${item.date}',
                          style: const TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(item.fromLocation,
                              style:
                                  const TextStyle(color: Color(0xFF0F172A)))),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(item.toLocation,
                              style:
                                  const TextStyle(color: Color(0xFF0F172A)))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

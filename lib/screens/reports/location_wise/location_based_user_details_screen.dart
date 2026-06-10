import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/location_based_user_details_controller.dart';

class LocationBasedUserDetailsScreen extends StatelessWidget {
  final String locationId;
  final String vehicleId;
  final String locationName;
  final String vehicleName;

  late final LocationBasedUserDetailsController controller;

  LocationBasedUserDetailsScreen({
    super.key,
    required this.locationId,
    required this.vehicleId,
    required this.locationName,
    required this.vehicleName,
  }) {
    controller = Get.put(LocationBasedUserDetailsController(
      locationId: locationId,
      vehicleId: vehicleId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF213AEC),
        foregroundColor: Colors.white,
        title: Text(
          '$locationName - $vehicleName Details',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.userDetails.isEmpty) {
            return const Center(
              child: Text(
                'No user details found.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.userDetails.length,
            itemBuilder: (context, index) {
              final user = controller.userDetails[index];
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.givenname} ${user.surname}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.code,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF213AEC),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _buildDetailRow('State', user.state),
                      _buildDetailRow('Type', user.type),
                      _buildDetailRow('Check-in Status', user.checkinStatus, isStatus: true),
                      if (user.checkinTime.isNotEmpty) _buildDetailRow('Check-in Time', user.checkinTime),
                      _buildDetailRow('Award Status', user.awardStatus, isStatus: true),
                      if (user.awardTime.isNotEmpty) _buildDetailRow('Award Time', user.awardTime),
                      _buildDetailRow('Photobooth Status', user.photoboothStatus, isStatus: true),
                      if (user.photoBoothTime.isNotEmpty) _buildDetailRow('Photobooth Time', user.photoBoothTime),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    Color valueColor = const Color(0xFF0F172A);
    if (isStatus) {
      if (value.toLowerCase().contains('pending') || value.toLowerCase().contains('not')) {
        valueColor = const Color(0xFFEF4444); // Red
      } else {
        valueColor = const Color(0xFF10B981); // Green
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
          const Text(' :  ', style: TextStyle(color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: isStatus ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

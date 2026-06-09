import 'package:event_rfid_app/widgets/common_widgets/attendee_details_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_list_controller.dart';
import '../../../../controllers/vehicle_master_controller.dart';
import '../../../../models/vehicle_model.dart';

class UserListScreen extends StatelessWidget {
  UserListScreen({super.key});

  final UserListController controller = Get.put(UserListController());
  final VehicleMasterController vehicleController = Get.put(
    VehicleMasterController(),
  );

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final title = args['title'] ?? 'Users';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
        backgroundColor: const Color(0xFF0043A4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) {
                // optionally debounce
              },
              onSubmitted: controller.search,
              decoration: InputDecoration(
                hintText: 'Search user...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0043A4)),
                ),
              ),
            ),
          ),
          if (controller.type == 'boarded')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() {
                if (vehicleController.isLoading.value &&
                    vehicleController.vehicles.isEmpty) {
                  return const LinearProgressIndicator();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text(
                        'All Vehicles',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF64748B),
                        ),
                      ),
                      value: controller.filterVehicleId.value,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'All Vehicles',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                        ...vehicleController.vehicles.map((
                          VehicleModel vehicle,
                        ) {
                          return DropdownMenuItem<String>(
                            value: vehicle.id,
                            child: Text(
                              '${vehicle.name} (${vehicle.vehicleType})',
                              style: const TextStyle(fontFamily: 'Inter'),
                            ),
                          );
                        }),
                      ],
                      onChanged: controller.setVehicleFilter,
                    ),
                  ),
                );
              }),
            ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.users.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: controller.users.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return InkWell(
                    onTap: () {
                      showAttendeeDetails(context, user.uniqueId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFEFF6FF),
                            radius: 24,
                            child: Text(
                              user.user.isNotEmpty
                                  ? user.user[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Color(0xFF0043A4),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.user,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user.uniqueId} • ${user.state}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

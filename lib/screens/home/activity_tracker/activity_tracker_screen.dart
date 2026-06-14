import 'package:event_rfid_app/controllers/activity_tracker_controller.dart';
import 'package:event_rfid_app/screens/home/activity_tracker/activity_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityTrackerScreen extends StatelessWidget {
  ActivityTrackerScreen({super.key});

  final ActivityTrackerController controller = Get.put(
    ActivityTrackerController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          children: [
            Text(
              'Activity Tracker',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              'Search and track adventure activities.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.document_scanner_outlined,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Find RFID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                'Scan RFID card to find user quickly',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (controller.isScanning.value) return;

                        Get.dialog(
                          barrierDismissible: false,
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Finding Tag...',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0043A4),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Bring a tag near the scanner.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  controller.stopFinding();
                                  Get.back();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF0043A4)),
                                ),
                              ),
                            ],
                          ),
                        );

                        controller.findRfid();
                      },
                      icon: const Icon(Icons.sensors),
                      label: const Text('Find RFID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0043A4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Search User',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onSubmitted: (value) => controller.searchUsers(value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search by name, unique ID, code, state...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF94A3B8),
                        ),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.searchController,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF94A3B8),
                              ),
                              onPressed: () {
                                controller.searchController.clear();
                                controller.performSearch();
                              },
                            );
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF64748B)),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      controller.searchUsers(controller.searchController.text);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.usersList.length} Users',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.usersList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.usersList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = controller.usersList[index];
                  return InkWell(
                    onTap: () async {
                      final result = await Get.to(
                        () => ActivityUpdateScreen(),
                        arguments: user,
                      );
                      if (result == true) {
                        // Refresh the list after update
                        controller.performSearch();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF94A3B8),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.givenname ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF0F172A),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user.name ?? ''} ${user.surname ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unique ID: ${user.uniqueId ?? 'N/A'} ',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'State: ${user.state ?? 'N/A'} ',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildActivityRow(
                                Icons.paragliding,
                                const Color(0xFF8B5CF6),
                                'Parasailing',
                                _formatActivityStatus(user.parasailing),
                              ),
                              const SizedBox(height: 8),
                              _buildActivityRow(
                                Icons.scuba_diving,
                                const Color(0xFF3B82F6),
                                'Snorkeling',
                                _formatActivityStatus(user.snorkeling),
                              ),
                              const SizedBox(height: 8),
                              _buildActivityRow(
                                Icons.sailing,
                                const Color(0xFF10B981),
                                'Banana Boat',
                                _formatActivityStatus(user.bananaBoat),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Center(
                            child: Icon(
                              Icons.chevron_right,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(
    IconData icon,
    Color color,
    String title,
    String status,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
            ),
            Text(
              status,
              style: const TextStyle(
                fontSize: 10,
                color: Color(
                  0xFF0043A4,
                ), // You can customize color based on status
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatActivityStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return 'Not Assigned';
    } else if (status.trim() == '0') {
      return 'Not Used';
    } else {
      return '$status Used';
    }
  }
}

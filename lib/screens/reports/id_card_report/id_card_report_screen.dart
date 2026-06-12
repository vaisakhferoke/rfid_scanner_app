import 'package:event_rfid_app/controllers/id_card_report_controller.dart';
import 'package:event_rfid_app/models/id_card_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IdCardReportScreen extends StatelessWidget {
  IdCardReportScreen({super.key});

  final String type = Get.arguments['type'] ?? '';

  @override
  Widget build(BuildContext context) {
    final IdCardReportController controller = Get.put(IdCardReportController());

    String title = type == 'travel_id_card'
        ? 'Travel ID Card Report'
        : 'Event ID Card Report';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Color(0xFF0F172A)),
            onPressed: () => controller.downloadExcel(),
            tooltip: 'Download & Share',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: const Color(0xFFF8FAFC), // Sleek light background
        child: Column(
          children: [
            _buildSummarySection(controller),
            const SizedBox(height: 8),
            // Users List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.usersList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: controller.usersList.length,
                  itemBuilder: (context, index) {
                    final user = controller.usersList[index];
                    return _buildUserCard(user);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(IdCardReportController controller) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Issue Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => controller.setTab('1'),
                    child: Opacity(
                      opacity: controller.selectedTab.value == '1' ? 1.0 : 0.5,
                      child: _buildSummaryItem(
                        icon: Icons.badge,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFECFDF5),
                        count: controller.issuedCount.value,
                        label: 'Issued',
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFF1F5F9)),
                Expanded(
                  child: InkWell(
                    onTap: () => controller.setTab('0'),
                    child: Opacity(
                      opacity: controller.selectedTab.value == '0' ? 1.0 : 0.5,
                      child: _buildSummaryItem(
                        icon: Icons.access_time,
                        iconColor: const Color(0xFFF59E0B),
                        iconBgColor: const Color(0xFFFFFBEB),
                        count: controller.pendingCount.value,
                        label: 'Pending',
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFF1F5F9)),
                Expanded(
                  child: Opacity(
                    opacity: 0.8,
                    child: _buildSummaryItem(
                      icon: Icons.people_alt_outlined,
                      iconColor: const Color(0xFF64748B),
                      iconBgColor: const Color(0xFFF8FAFC),
                      count: controller.totalCount.value,
                      label: 'Total Users',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String count,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(IdCardUser user) {
    bool isIssued = type == 'travel_id_card'
        ? user.travelIdCard == '1'
        : user.eventIdCard == '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  (user.givenname?.isNotEmpty == true)
                      ? user.givenname![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0043A4),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.givenname ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.name ?? ''} • ${user.state ?? ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.uniqueId ?? ''} • ${user.type ?? ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isIssued
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isIssued ? 'Issued' : 'Pending',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isIssued
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

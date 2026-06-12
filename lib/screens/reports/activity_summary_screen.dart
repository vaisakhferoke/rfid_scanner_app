import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_rfid_app/controllers/activity_summary_controller.dart';

import 'package:event_rfid_app/screens/reports/activity_summary_details_screen.dart';

class ActivitySummaryScreen extends StatelessWidget {
  final ActivitySummaryController controller = Get.put(
    ActivitySummaryController(),
  );

  ActivitySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Activity Overview',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Overview of assigned and used activities.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0043A4)),
          );
        }

        final summary = controller.summary.value;
        if (summary == null) {
          return const Center(child: Text('No data available'));
        }

        int totalAssigned =
            (int.tryParse(summary.parasailingAssignedCount) ?? 0) +
            (int.tryParse(summary.snorkelingAssignedCount) ?? 0) +
            (int.tryParse(summary.bananaBoatAssignedCount) ?? 0);

        int totalUsed =
            (int.tryParse(summary.parasailingUsedCount) ?? 0) +
            (int.tryParse(summary.snorkelingUsedCount) ?? 0) +
            (int.tryParse(summary.bananaBoatUsedCount) ?? 0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTopCard(
                      icon: Icons.assignment_outlined,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue.withOpacity(0.1),
                      title: 'Total Activity Count',
                      count: totalAssigned
                          .toString(), // Or summary.totalCount based on logic
                      subtitle: 'Total activities assigned',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTopCard(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      iconBgColor: Colors.green.withOpacity(0.1),
                      title: 'Total Used Count',
                      count: totalUsed.toString(),
                      subtitle: 'Total activities used',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Activity Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                icon: Icons.paragliding,
                iconColor: Colors.deepPurpleAccent,
                iconBgColor: Colors.deepPurpleAccent.withOpacity(0.1),
                title: 'Parasailing',
                subtitle: 'Enjoy the thrill of parasailing.',
                assignedCount: summary.parasailingAssignedCount,
                usedCount: summary.parasailingUsedCount,
                assignedType: 'parasailing_assigned_count',
                usedType: 'parasailing_used_count',
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                icon: Icons.scuba_diving,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.withOpacity(0.1),
                title: 'Snorkeling',
                subtitle: 'Explore the underwater world.',
                assignedCount: summary.snorkelingAssignedCount,
                usedCount: summary.snorkelingUsedCount,
                assignedType: 'snorkeling_assigned_count',
                usedType: 'snorkeling_used_count',
              ),
              const SizedBox(height: 12),
              _buildActivityCard(
                icon: Icons.rowing,
                iconColor: Colors.green,
                iconBgColor: Colors.green.withOpacity(0.1),
                title: 'Banana Boat',
                subtitle: 'Fun rides with friends on the banana boat.',
                assignedCount: summary.bananaBoatAssignedCount,
                usedCount: summary.bananaBoatUsedCount,
                assignedType: 'banana_boat_assigned_count',
                usedType: 'banana_boat_used_count',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About the Counts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Assigned: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      'Number of users assigned to the activity.\n',
                                ),
                                TextSpan(
                                  text: 'Used: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      'Number of users who have used the activity.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String count,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: iconColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String assignedCount,
    required String usedCount,
    required String assignedType,
    required String usedType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.people, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Get.to(() => ActivitySummaryDetailsScreen(),
                        arguments: {'type': assignedType});
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Assigned',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          assignedCount,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          int.tryParse(assignedCount) == 1 ? 'User' : 'Users',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Get.to(() => ActivitySummaryDetailsScreen(),
                        arguments: {'type': usedType});
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'Used',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          usedCount,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          int.tryParse(usedCount) == 1 ? 'User' : 'Users',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

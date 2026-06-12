// Placeholder screen for Reports
import 'package:event_rfid_app/widgets/appbar/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_scan/user_scan_report_screen.dart';
import 'location_wise/location_wise_report_screen.dart';
import 'day_wise/daywise_report_screen.dart';
import 'id_card_report/id_card_report_screen.dart';
import 'activity_summary_screen.dart';

class ReportsPlaceholderScreen extends StatelessWidget {
  const ReportsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppbar(title: 'Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('ID Card'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ReportCard(
                  title: 'Travel ID\nCard',
                  icon: Icons.card_membership,
                  onTap: () {
                    Get.to(
                      () => IdCardReportScreen(),
                      arguments: {'type': 'travel_id_card'},
                    );
                  },
                ),
                _ReportCard(
                  title: 'Event ID\nCard',
                  icon: Icons.badge,
                  onTap: () {
                    Get.to(
                      () => IdCardReportScreen(),
                      arguments: {'type': 'event_id_card'},
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Vehicle'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // _ReportCard(
                //   title: 'Scanned\nReport',
                //   icon: Icons.qr_code_scanner,
                //   onTap: () {
                //     Get.to(() => BusScannedReportScreen());
                //   },
                // ),
                // _ReportCard(
                //   title: 'Location \nWise Report',
                //   icon: Icons.location_city,
                //   onTap: () {
                //     Get.to(() => LocationWiseReportScreen());
                //   },
                // ),
                _ReportCard(
                  title: 'Daywise\nReport',
                  icon: Icons.calendar_today,
                  onTap: () {
                    Get.to(() => DaywiseReportScreen());
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Event Entry'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // _ReportCard(
                //   title: 'Check in\nReport',
                //   icon: Icons.how_to_reg,
                //   onTap: () {
                //     // TODO: Navigate to Check in Report
                //   },
                // ),
                // _ReportCard(
                //   title: 'Not checkin\nReport',
                //   icon: Icons.person_off,
                //   onTap: () {
                //     // TODO: Navigate to Not check in Report
                //   },
                // ),
                _ReportCard(
                  title: 'User Scan\nReport',
                  icon: Icons.document_scanner,
                  onTap: () {
                    Get.to(() => UserScanReportScreen());
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Activity'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ReportCard(
                  title: 'Activity\nTrack',
                  icon: Icons.local_activity,
                  onTap: () {
                    Get.to(() => ActivitySummaryScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

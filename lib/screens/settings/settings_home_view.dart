import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/range_settings_popup.dart';
import '../../widgets/appbar/home_appbar.dart';
import 'write_tag_screen.dart';
import 'vehicle_master_screen.dart';
import 'location_master_screen.dart';
import '../../controllers/vehicle_master_controller.dart';
import '../../controllers/location_master_controller.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppbar(title: 'Settings'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Container(
            color: const Color(0xFFF8FAFC), // sleek light background
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // White Header Area
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 24.0,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Configure reader options and RFID utilities',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),

                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RFID Utilities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 14),

                          // // Find Tag Card
                          // _buildMenuCard(
                          //   icon: Icons.radar_rounded,
                          //   iconColor: const Color(0xFF0043A4),
                          //   iconBgColor: const Color(0xFFEFF6FF),
                          //   title: 'Find Tag',
                          //   subtitle: 'Locate Tag',
                          //   onTap: () => Get.to(() => const FindTagScreen()),
                          // ),
                          // const SizedBox(height: 14),

                          // Write Card
                          _buildMenuCard(
                            icon: Icons.edit_note_rounded,
                            iconColor: const Color(0xFF0043A4),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Write',
                            subtitle: 'write EPC data',
                            onTap: () => Get.to(() => const WriteTagScreen()),
                          ),
                          const SizedBox(height: 14),

                          // Range Settings Card
                          _buildMenuCard(
                            icon: Icons.sensors_rounded,
                            iconColor: const Color(0xFF0043A4),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Range Settings',
                            subtitle: 'Configure RF output power',
                            onTap: () =>
                                RangeSettingsPopup.showRangeSettingsSheet(
                                  context,
                                ),
                          ),
                          const SizedBox(height: 28),

                          const Text(
                            'Master Configurations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Vehicle Master Card
                          _buildMenuCard(
                            icon: Icons.directions_bus_rounded,
                            iconColor: const Color(0xFF0043A4),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Vehicle Master',
                            subtitle: 'Manage vehicles and dropdown options',
                            onTap: () {
                              Get.put(VehicleMasterController());
                              Get.to(() => const VehicleMasterScreen());
                            },
                          ),
                          const SizedBox(height: 14),

                          // Location Master Card
                          _buildMenuCard(
                            icon: Icons.location_on_rounded,
                            iconColor: const Color(0xFF0043A4),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Location Master',
                            subtitle: 'Manage trip checkpoint locations',
                            onTap: () {
                              Get.put(LocationMasterController());
                              Get.to(() => const LocationMasterScreen());
                            },
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0F172A,
                                        ).withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/logo/git_logo.png',
                                    height: 25,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Text(
                                        'git DGTL',
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'GIT Event Management App',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF334155),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Version 1.0.0 (Build 1)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

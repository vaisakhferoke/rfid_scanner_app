import 'package:event_rfid_app/screens/home/event_entry/add_event_entry_screen.dart';
import 'package:event_rfid_app/screens/home/bus_scan/bus_scan_screen.dart';
import 'package:event_rfid_app/widgets/appbar/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF0043A4),
      appBar: HomeAppbar(title: 'Home'),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/logo/event_logo.png',
                                height: 45,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'VKC Global Confluence 2026',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Inter',
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Phuket, Thailand | June 16 - 20, 2026',
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
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Quick Actions'),
                        const SizedBox(height: 14),
                        _buildQuickActions(context),
                        const SizedBox(height: 28),
                        // _buildSectionTitle('Overview'),
                        // const SizedBox(height: 14),
                        // _buildOverviewGrid(),
                        // const SizedBox(height: 28),
                        // _buildRecentActivityHeader(),
                        // const SizedBox(height: 14),
                        // _buildRecentActivityList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final NavigationController navController = Get.find<NavigationController>();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.edit_note,
                iconColor: const Color(0xFF0043A4),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Event Entry Scan',
                subtitle: '0/200',
                onTap: () {
                  Get.to(
                    () => AddEventEntryScreen(),
                    arguments: {'type': 'evententry'},
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.card_giftcard,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFECFDF5),
                title: 'Award Entry Scan',
                subtitle: '0/80',
                onTap: () {
                  Get.to(
                    () => AddEventEntryScreen(),
                    arguments: {'type': 'award'},
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.photo,
                iconColor: const Color(0xFF0043A4),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Photo Booth Scan',
                subtitle: '0/80',
                onTap: () {
                  Get.to(
                    () => AddEventEntryScreen(),
                    arguments: {'type': 'photobooth'},
                  );
                },
              ),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.verified_user,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFECFDF5),
                title: 'Special Award Scan',
                subtitle: '0/4',
                onTap: () {
                  Get.to(
                    () => AddEventEntryScreen(),
                    arguments: {'type': 'specialaward'},
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildQuickActionCard(
          icon: Icons.directions_bus,
          iconColor: const Color(0xFF0043A4),
          iconBgColor: const Color(0xFFEFF6FF),
          title: 'Bus Scan',
          subtitle: '200/120',
          onTap: () {
            Get.to(() => BusScanScreen());
          },
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,

    bool isFullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // const SizedBox(height: 6),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Text(
                  //         subtitle,
                  //         style: const TextStyle(
                  //           fontSize: 10,
                  //           color: Color(0xFF64748B),
                  //           fontFamily: 'Inter',
                  //         ),
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.local_activity,
            iconColor: const Color(0xFF0043A4),
            iconBgColor: const Color(0xFFEFF6FF),
            value: '100',
            label: 'Event Entry)',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.directions_bus,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFECFDF5),
            value: '120',
            label: 'Bus Scan)',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.verified_user,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFFF5F3FF),
            value: '70',
            label: 'Onward Scan)',
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.2,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

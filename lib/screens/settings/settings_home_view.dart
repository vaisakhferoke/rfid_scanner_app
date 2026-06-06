import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/range_settings_popup.dart';
import '../../widgets/appbar/home_appbar.dart';
import 'write_tag_screen.dart';
import 'vehicle_master_screen.dart';
import 'location_master_screen.dart';
import 'event_settings_screen.dart';
import '../../controllers/vehicle_master_controller.dart';
import '../../controllers/location_master_controller.dart';
import '../../controllers/event_settings_controller.dart';
import '../../config/api_config.dart';

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
                          const SizedBox(height: 14),

                          // Server Settings Card
                          _buildMenuCard(
                            icon: Icons.settings_input_component_rounded,
                            iconColor: const Color(0xFF0043A4),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Server Settings',
                            subtitle: 'Configure backend API Base URLs',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => const BaseUrlConfigDialog(),
                              );
                            },
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
                          const SizedBox(height: 14),

                          // Configuration Settings Card
                          _buildMenuCard(
                            icon: Icons.settings_suggest_rounded,
                            iconColor: const Color(0xFF0043A4),
                            iconBgColor: const Color(0xFFEFF6FF),
                            title: 'Configuration Settings',
                            subtitle: 'Manage event configuration variables',
                            onTap: () {
                              Get.put(EventSettingsController());
                              Get.to(() => const EventSettingsScreen());
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

class BaseUrlConfigDialog extends StatefulWidget {
  const BaseUrlConfigDialog({super.key});

  @override
  State<BaseUrlConfigDialog> createState() => _BaseUrlConfigDialogState();
}

class _BaseUrlConfigDialogState extends State<BaseUrlConfigDialog> {
  late TextEditingController _urlController;
  late TextEditingController _url2Controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _url2Controller = TextEditingController();
    _loadUrls();
  }

  Future<void> _loadUrls() async {
    final url = await ApiConfig.getBaseUrl();
    final url2 = await ApiConfig.getBaseUrl2();
    if (mounted) {
      setState(() {
        _urlController.text = url;
        _url2Controller.text = url2;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _url2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0043A4)),
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.settings_input_component_rounded,
            color: Color(0xFF0043A4),
          ),
          SizedBox(width: 8),
          Text(
            'API Server Address',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Base URL 1:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'e.g. http://newtest.vkcparivar.com/api/',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0043A4),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'API Base URL 2:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _url2Controller,
              decoration: InputDecoration(
                hintText: 'Optional secondary server address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0043A4),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String inputUrl = _urlController.text.trim();
            String inputUrl2 = _url2Controller.text.trim();
            if (inputUrl.isNotEmpty) {
              final navigator = Navigator.of(context);
              await ApiConfig.setBaseUrl(inputUrl, inputUrl2);
              if (Get.isRegistered<LocationMasterController>()) {
                final locController = Get.find<LocationMasterController>();
                locController.baseUrl.value = inputUrl;
                locController.baseUrl2.value = inputUrl2;
                locController.fetchLocations();
              }
              if (Get.isRegistered<VehicleMasterController>()) {
                final vehController = Get.find<VehicleMasterController>();
                vehController.baseUrl.value = inputUrl;
                vehController.baseUrl2.value = inputUrl2;
                vehController.fetchVehicles();
              }
              navigator.pop();
              Get.snackbar(
                'Success',
                'API Base URLs updated successfully!',
                backgroundColor: const Color(0xFF10B981),
                colorText: Colors.white,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0043A4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Save & Reconnect',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

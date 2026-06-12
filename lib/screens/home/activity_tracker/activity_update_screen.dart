import 'package:event_rfid_app/controllers/activity_update_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityUpdateScreen extends StatelessWidget {
  ActivityUpdateScreen({super.key});

  final ActivityUpdateController controller = Get.put(
    ActivityUpdateController(),
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
              'Activity Update',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              'Update user activities and completion status.',
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
              'User Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF94A3B8),
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildUserDetailRow(
                          'Name',
                          controller.user.name ?? 'Unknown',
                        ),
                        const SizedBox(height: 8),
                        _buildUserDetailRow(
                          'Code',
                          controller.user.code ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildUserDetailRow(
                          'State',
                          controller.user.state ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildUserDetailRow(
                          'VIA Code',
                          controller.user.uniqueId ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Activities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildActivitySection(
                    'Parasailing',
                    Icons.paragliding,
                    const Color(0xFF8B5CF6),
                    const Color(0xFFF5F3FF),
                    controller.parasailing,
                    'parasailing',
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _buildActivitySection(
                    'Snorkeling',
                    Icons.scuba_diving,
                    const Color(0xFF3B82F6),
                    const Color(0xFFEFF6FF),
                    controller.snorkeling,
                    'snorkeling',
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _buildActivitySection(
                    'Banana Boat',
                    Icons.sailing,
                    const Color(0xFF10B981),
                    const Color(0xFFECFDF5),
                    controller.bananaBoat,
                    'bananaBoat',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Update Guide',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildGuideItem(
                        'Empty',
                        'Not Assigned',
                        const Color(0xFF8B5CF6),
                      ),
                      _buildGuideItem('0', 'Not Used', const Color(0xFF3B82F6)),
                      _buildGuideItem('1', '1 User', const Color(0xFF10B981)),
                      _buildGuideItem('2', '2 Users', const Color(0xFFF59E0B)),
                      _buildGuideItem('3', '3 Users', const Color(0xFFEF4444)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Confirm Update',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const Text(
                            'Are you sure you want to update these activities?',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF475569),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                controller.saveActivities();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                controller.isLoading.value
                    ? 'Updating...'
                    : 'Update Activities',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(
    String title,
    IconData icon,
    Color color,
    Color bgColor,
    RxString observableValue,
    String typeKey,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
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
                const SizedBox(height: 6),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(observableValue.value),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatActivityStatus(observableValue.value),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(observableValue.value),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildIncrementButton(Icons.remove, () {
                      int current = int.tryParse(observableValue.value) ?? 0;
                      if (observableValue.value.isEmpty) {
                        // Empty -> cannot decrement below Empty, but if they want to decrease maybe leave Empty
                      } else if (current > 0) {
                        controller.updateActivity(
                          typeKey,
                          (current - 1).toString(),
                        );
                      } else if (current == 0) {
                        controller.updateActivity(typeKey, '');
                      }
                    }),
                    const SizedBox(width: 12),
                    Obx(
                      () => Container(
                        width: 60,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          observableValue.value.isEmpty
                              ? 'Empty'
                              : observableValue.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildIncrementButton(Icons.add, () {
                      if (observableValue.value.isEmpty) {
                        controller.updateActivity(typeKey, '0');
                      } else {
                        int current = int.tryParse(observableValue.value) ?? 0;
                        controller.updateActivity(
                          typeKey,
                          (current + 1).toString(),
                        );
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Update to:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickButton(
                      'Empty',
                      '',
                      observableValue,
                      typeKey,
                      const Color(0xFF8B5CF6),
                    ),
                    _buildQuickButton(
                      '0',
                      '0',
                      observableValue,
                      typeKey,
                      const Color(0xFF3B82F6),
                    ),
                    _buildQuickButton(
                      '1',
                      '1',
                      observableValue,
                      typeKey,
                      const Color(0xFF10B981),
                    ),
                    _buildQuickButton(
                      '2',
                      '2',
                      observableValue,
                      typeKey,
                      const Color(0xFFF59E0B),
                    ),
                    _buildQuickButton(
                      '3',
                      '3',
                      observableValue,
                      typeKey,
                      const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
      ),
    );
  }

  Widget _buildQuickButton(
    String label,
    String value,
    RxString observableValue,
    String typeKey,
    Color color,
  ) {
    return Obx(() {
      final isSelected = observableValue.value == value;
      return InkWell(
        onTap: () => controller.updateActivity(typeKey, value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : const Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGuideItem(String key, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const Text(
          ' = ',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(width: 4),
        const Text('|', style: TextStyle(color: Color(0xFFCBD5E1))),
      ],
    );
  }

  String _formatActivityStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return 'Not Assigned';
    } else if (status.trim() == '0') {
      return 'Not Used';
    } else if (status.trim() == '1') {
      return '1 Used';
    } else {
      return '$status Used';
    }
  }

  Color _getStatusBgColor(String? status) {
    if (status == null || status.trim().isEmpty)
      return const Color(0xFFF5F3FF); // Purple light
    if (status.trim() == '0') return const Color(0xFFEFF6FF); // Blue light
    return const Color(0xFFECFDF5); // Green light
  }

  Color _getStatusTextColor(String? status) {
    if (status == null || status.trim().isEmpty) return const Color(0xFF8B5CF6);
    if (status.trim() == '0') return const Color(0xFF3B82F6);
    return const Color(0xFF10B981);
  }
}

import 'package:event_rfid_app/controllers/range_controller.dart';
import 'package:event_rfid_app/services/range_settings_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models/rfid_tag.dart';
import 'controller/event_entry_scan_controller.dart';

class AddEventEntryScreen extends StatelessWidget {
  final EventEntryScannController controller = Get.put(
    EventEntryScannController(),
  );
  final RangeController rangeController = Get.find<RangeController>();

  AddEventEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF213AEC), // Vibrant brand blue/indigo
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Event Entry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          _buildRangeSettingsButton(context),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildConnectionCard(context),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 12),
            _buildScanStatus(),
            const SizedBox(height: 16),
            _buildTabSelectors(),
            const SizedBox(height: 16),
            _buildListHeader(),
            const SizedBox(height: 4),
            Expanded(
              child: _buildTagList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSettingsButton(BuildContext context) {
    return Obx(() {
      final currentRange = rangeController.powerLevel.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Current Range',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '${currentRange.round()} m',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => RangeSettingsPopup.showRangeSettingsSheet(context),
            icon: const Icon(
              Icons.track_changes, // target/radar icon
              color: Colors.white,
              size: 22,
            ),
            padding: const EdgeInsets.only(right: 12.0),
            constraints: const BoxConstraints(),
          ),
        ],
      );
    });
  }

  Widget _buildConnectionCard(BuildContext context) {
    return Obx(() {
      final isConnected = controller.isConnected.value;
      final Color cardBorderColor = isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
      final Color cardBgColor = isConnected ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
      final Color textColor = isConnected ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardBorderColor,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Pulse-like status dot matching mockup (outer transparent ring, inner solid ring)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected ? const Color(0xFF22C55E).withOpacity(0.15) : const Color(0xFFEF4444).withOpacity(0.15),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'Reader Connected' : 'Reader Disconnected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      isConnected ? 'Real RFID Hardware Active' : 'Tap retry to check connection',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isConnected)
                TextButton.icon(
                  onPressed: () => controller.retryConnection(),
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: Colors.orange,
                  ),
                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Start Button
          Expanded(
            child: Obx(() {
              final isScanning = controller.isScanning.value;
              final bool isEnabled = !isScanning;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ElevatedButton.icon(
                  onPressed: isEnabled ? () => controller.startScan() : null,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text(
                    'Start',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: isEnabled ? const Color(0xFF22C55E) : const Color(0xFFBBF7D0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBBF7D0),
                    disabledForegroundColor: Colors.white.withOpacity(0.8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              );
            }),
          ),
          // Stop Button
          Expanded(
            child: Obx(() {
              final isScanning = controller.isScanning.value;
              final bool isEnabled = isScanning;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ElevatedButton.icon(
                  onPressed: isEnabled ? () => controller.stopScan() : null,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text(
                    'Stop',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: isEnabled ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5).withOpacity(0.5),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFFCA5A5).withOpacity(0.5),
                    disabledForegroundColor: Colors.white.withOpacity(0.8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              );
            }),
          ),
          // Clear Button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: ElevatedButton.icon(
                onPressed: () => controller.clearData(),
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text(
                  'Clear',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF94A3B8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanStatus() {
    return Obx(() {
      final isScanning = controller.isScanning.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_turned_in_rounded, // Checklist check icon
            color: Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Scan Status : ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            isScanning ? 'Running' : 'Stopped',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isScanning ? const Color(0xFF213AEC) : const Color(0xFF64748B),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabSelectors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() {
        final selectedIndex = controller.selectedTab.value;
        final pendingCount = controller.pendingTags.length;
        final scannedCount = controller.scannedTags.length;

        return Row(
          children: [
            // Pending Tab
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => controller.selectedTab.value = 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedIndex == 0 ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: selectedIndex == 0
                          ? null
                          : Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Pending ($pendingCount)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == 0 ? const Color(0xFF213AEC) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Scanned Tab
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () => controller.selectedTab.value = 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedIndex == 1 ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: selectedIndex == 1
                          ? null
                          : Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Scanned ($scannedCount)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == 1 ? const Color(0xFF213AEC) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'EPC',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Time',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Action',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList() {
    return Obx(() {
      final isPendingSelected = controller.selectedTab.value == 0;
      final list = isPendingSelected ? controller.pendingTags : controller.scannedTags;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPendingSelected ? Icons.assignment_turned_in : Icons.wifi_tethering_off,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                isPendingSelected ? 'All tags have been scanned!' : 'No tags scanned yet.',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final tag = list[index];
          final timeStr = isPendingSelected
              ? '--'
              : DateFormat('hh:mm a').format(tag.readTime).toLowerCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF), // light lavender background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // EPC
                  Expanded(
                    flex: 4,
                    child: Text(
                      tag.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  // Time
                  Expanded(
                    flex: 3,
                    child: Text(
                      timeStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  // Action Eye Icon
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showAttendeeDetails(context, tag, !isPendingSelected),
                        child: const Icon(
                          Icons.visibility_outlined,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showAttendeeDetails(BuildContext context, RfidTag tag, bool isScanned) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final timeString = DateFormat('yyyy-MM-dd hh:mm:ss a').format(tag.readTime);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tag Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildDetailRow('EPC:', tag.epc),
                const SizedBox(height: 8),
                _buildDetailRow('Display Name:', tag.displayName),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Status:',
                  isScanned ? 'Scanned' : 'Pending',
                  valueColor: isScanned ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Scan Count:', '${tag.count}'),
                if (isScanned) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Last Scan Time:', timeString),
                  const SizedBox(height: 8),
                  _buildDetailRow('RSSI Strength:', '${tag.rssi} dBm'),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF213AEC),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF0F172A),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

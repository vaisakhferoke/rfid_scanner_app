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
    return Obx(() {
      final isScanning = controller.isScanning.value;
      return PopScope(
        canPop: !isScanning,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _handleBackPress(context);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(
              0xFF213AEC,
            ), // Vibrant brand blue/indigo
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => _handleBackPress(context),
            ),
            title: Text(
              "${controller.type.capitalize}" + " Scan",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            actions: [_buildRangeSettingsButton(context)],
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
                Expanded(child: _buildTagList()),
              ],
            ),
          ),
        ),
      );
    });
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
      final Color cardBorderColor = isConnected
          ? const Color(0xFF22C55E)
          : const Color(0xFFEF4444);
      final Color cardBgColor = isConnected
          ? const Color(0xFFF0FDF4)
          : const Color(0xFFFEF2F2);
      final Color textColor = isConnected
          ? const Color(0xFF16A34A)
          : const Color(0xFFDC2626);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor, width: 1.5),
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
                  color: isConnected
                      ? const Color(0xFF22C55E).withOpacity(0.15)
                      : const Color(0xFFEF4444).withOpacity(0.15),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
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
                      isConnected
                          ? 'Real RFID Hardware Active'
                          : 'Tap retry to check connection',
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
                    backgroundColor: isEnabled
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFBBF7D0),
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
                    backgroundColor: isEnabled
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFFCA5A5).withOpacity(0.5),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFFFCA5A5,
                    ).withOpacity(0.5),
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
              color: isScanning
                  ? const Color(0xFF213AEC)
                  : const Color(0xFF64748B),
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
                      color: selectedIndex == 0
                          ? const Color(0xFFEEF2FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: selectedIndex == 0
                          ? null
                          : Border.all(
                              color: const Color(0xFFC7D2FE),
                              width: 1.5,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Pending ($pendingCount)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == 0
                            ? const Color(0xFF213AEC)
                            : const Color(0xFF475569),
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
                      color: selectedIndex == 1
                          ? const Color(0xFFEEF2FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: selectedIndex == 1
                          ? null
                          : Border.all(
                              color: const Color(0xFFC7D2FE),
                              width: 1.5,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Scanned ($scannedCount)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == 1
                            ? const Color(0xFF213AEC)
                            : const Color(0xFF475569),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 15,
              ),
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
      final list = isPendingSelected
          ? controller.pendingTags
          : controller.scannedTags;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPendingSelected
                    ? Icons.assignment_turned_in
                    : Icons.wifi_tethering_off,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                isPendingSelected
                    ? 'All tags have been scanned!'
                    : 'No tags scanned yet.',
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
          final timeStr = DateFormat(
            'hh:mm a',
          ).format(tag.readTime).toLowerCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF), // light lavender background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 14.0,
              ),
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
                        onTap: () => _showAttendeeDetails(
                          context,
                          tag,
                          !isPendingSelected,
                        ),
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
        // Dynamic attendee generation based on EPC
        int getIndex(String epcStr) {
          final digits = RegExp(r'\d+').firstMatch(epcStr)?.group(0);
          if (digits != null) {
            return int.tryParse(digits) ?? 0;
          }
          return epcStr.hashCode;
        }

        String stringToHex(String input) {
          StringBuffer sb = StringBuffer();
          for (int i = 0; i < input.length; i++) {
            sb.write(input.codeUnitAt(i).toRadixString(16));
          }
          String result = sb.toString();
          if (result.length < 16) {
            result = result.padRight(16, '0');
          }
          return result;
        }

        final idx = getIndex(tag.epc);
        final names = [
          'John Doe',
          'Jane Smith',
          'Alice Johnson',
          'Bob Brown',
          'Charlie Green',
          'David White',
          'Eva Black',
          'Frank Gray',
          'Grace Blue',
          'Henry Red',
          'Ivy Violet',
          'Jack Orange',
          'Kate Yellow',
        ];
        final name = names[idx % names.length];

        final ids = [
          1024,
          1025,
          1026,
          1027,
          1028,
          1029,
          1030,
          1031,
          1032,
          1033,
        ];
        final id = ids[idx % ids.length];

        final codes = [
          'QR-8829-X',
          'QR-5541-Y',
          'QR-1234-A',
          'QR-9876-B',
          'QR-4567-C',
        ];
        final code = codes[idx % codes.length];

        final companies = [
          'Precision Logistics',
          'Tech Innovations',
          'Global Trade',
          'Vanguard Services',
          'Nexus Industries',
        ];
        final company = companies[idx % companies.length];

        final awards = [
          'Gold Member',
          'Silver Member',
          'Bronze Member',
          'VIP Member',
          'Premium Member',
        ];
        final award = awards[idx % awards.length];

        final buses = ['B-42', 'B-15', 'B-08', 'B-33', 'B-24'];
        final bus = buses[idx % buses.length];

        final photoStatuses = ['Completed', 'Pending', 'In Progress'];
        final photoStatus = photoStatuses[idx % photoStatuses.length];

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Close Button
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
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(
                  height: 24,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),

                // Avatar & Name Centered
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo/avatar_john_doe.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Color(0xFF64748B),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Key-Value rows
                _buildPopupRow(
                  'ID:',
                  Text(
                    id.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Code:',
                  Text(
                    code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Company Name:',
                  Text(
                    company,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Check-in Status:',
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isScanned
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isScanned ? 'Checked In' : 'Pending',
                      style: TextStyle(
                        color: isScanned
                            ? const Color(0xFF213AEC)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Check-in Time:',
                  Text(
                    isScanned
                        ? DateFormat('hh:mm a').format(tag.readTime)
                        : '--',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Award Status:',
                  Text(
                    award,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Photobooth Status:',
                  Text(
                    photoStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Bus No:',
                  Text(
                    bus,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'IFID:',
                  Text(
                    stringToHex(tag.epc),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Close Button
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
  }

  Widget _buildPopupRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          valueWidget,
        ],
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    if (controller.isScanning.value) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text('Warning'),
              ],
            ),
            content: const Text(
              'Scanning is currently running. You want to close this screen? Please stop scanning first.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Close dialog
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  await controller.stopScan(); // Stop scanning
                  Get.back(); // Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Stop & Exit'),
              ),
            ],
          );
        },
      );
    } else {
      Get.back();
    }
  }
}

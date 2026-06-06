import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models/rfid_tag.dart';
import '../../../../controllers/range_controller.dart';
import '../../../../services/range_settings_popup.dart';
import 'controller/bus_scan_controller.dart';

class BusScanScreen extends StatelessWidget {
  final BusScanController controller = Get.put(BusScanController());
  final RangeController rangeController = Get.find<RangeController>();

  BusScanScreen({super.key});

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
            backgroundColor: const Color(0xFF213AEC), // Vibrant brand blue
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => _handleBackPress(context),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bus Scanning',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Obx(() {
                  final day = controller.day.value.toUpperCase();
                  if (day.isEmpty) return const SizedBox.shrink();
                  return Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  );
                }),
              ],
            ),
            centerTitle: true,
            actions: [_buildRangeSettingsButton(context)],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildConnectionCard(context),
                        const SizedBox(height: 16),
                        _buildLocationsSelector(context),
                        const SizedBox(height: 16),
                        _buildBusSelector(context),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        _buildScanStatus(),
                        const SizedBox(height: 24),
                        _buildListHeader(),
                        const SizedBox(height: 4),
                        _buildTagList(context),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context),
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

  Widget _buildLocationsSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // From Location
              Expanded(
                child: Obx(() {
                  final fromLoc = controller.selectedFromLocation.value;
                  return InkWell(
                    onTap: () => _showLocationPicker(context, true),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fromLoc != null
                                  ? fromLoc.name
                                  : 'Select From Location',
                              style: TextStyle(
                                fontSize: 14,
                                color: fromLoc != null
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
                                fontWeight: fromLoc != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              // To Location
              Expanded(
                child: Obx(() {
                  final toLoc = controller.selectedToLocation.value;
                  return InkWell(
                    onTap: () => _showLocationPicker(context, false),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              toLoc != null ? toLoc.name : 'Select To Location',
                              style: TextStyle(
                                fontSize: 14,
                                color: toLoc != null
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
                                fontWeight: toLoc != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Bus',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final bus = controller.selectedBus.value;
            return InkWell(
              onTap: () => _showBusPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_bus_outlined,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bus != null ? bus.name : 'Select Bus',
                        style: TextStyle(
                          fontSize: 15,
                          color: bus != null
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                          fontWeight: bus != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF0F172A),
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
            Icons.assignment_turned_in_rounded,
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

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'EPC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          Text(
            'Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList(BuildContext context) {
    return Obx(() {
      final list = controller.scannedTags;

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_tethering_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                const Text(
                  'No tags scanned yet.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final tag = list[index];

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
                  Expanded(
                    child: Text(
                      tag.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAttendeeDetails(context, tag),
                    child: const Icon(
                      Icons.visibility_outlined,
                      color: Color(0xFF64748B),
                      size: 20,
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

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Total No. Items : ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Obx(() {
                final count = controller.scannedTags.length;
                final countStr = count.toString().padLeft(2, '0');
                return Text(
                  countStr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF213AEC),
                  ),
                );
              }),
            ],
          ),
          Obx(() {
            final isScanning = controller.isScanning.value;
            return ElevatedButton(
              onPressed: isScanning ? null : () => controller.checkStatus(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isScanning
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF213AEC),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                disabledForegroundColor: Colors.white.withOpacity(0.8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Check Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context, bool isFromLocation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isFromLocation
                      ? 'Select From Location'
                      : 'Select To Location',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Divider(height: 1),
              Obx(() {
                final locs = controller.locationMasterController.locations;
                if (locs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'No locations available. Add them in settings.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: locs.length,
                    itemBuilder: (context, index) {
                      final loc = locs[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF213AEC),
                        ),
                        title: Text(
                          loc.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          bool success = false;
                          if (isFromLocation) {
                            success = controller.setFromLocation(loc);
                          } else {
                            success = controller.setToLocation(loc);
                          }
                          if (success) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showBusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Bus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Divider(height: 1),
              Obx(() {
                final vehicles = controller.vehicleMasterController.vehicles;
                if (vehicles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'No buses/vehicles available. Add them in settings.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.directions_bus,
                          color: Color(0xFF213AEC),
                        ),
                        title: Text(
                          vehicle.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(vehicle.vehicleType),
                        onTap: () {
                          controller.selectedBus.value = vehicle;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAttendeeDetails(BuildContext context, RfidTag tag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Checked In',
                      style: TextStyle(
                        color: Color(0xFF213AEC),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                _buildPopupRow(
                  'Check-in Time:',
                  Text(
                    DateFormat('hh:mm a').format(tag.readTime),
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

  void _showScanSummary(BuildContext context) {
    final fromLoc = controller.selectedFromLocation.value?.name ?? 'Not Set';
    final toLoc = controller.selectedToLocation.value?.name ?? 'Not Set';
    final busName = controller.selectedBus.value?.name ?? 'Not Selected';
    final count = controller.scannedTags.length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.directions_bus, color: Color(0xFF213AEC)),
              SizedBox(width: 8),
              Text('Bus Scan Summary'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('From Location:', fromLoc),
              _buildSummaryRow('To Location:', toLoc),
              _buildSummaryRow('Selected Bus:', busName),
              const Divider(height: 24),
              _buildSummaryRow(
                'Total Scanned Items:',
                count.toString(),
                isBold: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFF213AEC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
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
                onPressed: () => Navigator.of(context).pop(),
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
                  Navigator.of(context).pop();
                  await controller.stopScan();
                  Get.back();
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

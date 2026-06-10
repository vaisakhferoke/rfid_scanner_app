import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/range_controller.dart';
import '../../../../services/range_settings_popup.dart';
import 'controller/bus_scan_controller.dart';

class ScanDetailsScreen extends StatelessWidget {
  final String fromLocation;

  final String busName;

  ScanDetailsScreen({
    super.key,
    required this.fromLocation,

    required this.busName,
  });

  final RangeController rangeController = Get.find<RangeController>();
  final BusScanController controller = Get.find<BusScanController>();

  @override
  Widget build(BuildContext context) {
    // final response = controller.checkStatusResponse.value;
    // final int totalPassengers = response?.totalPassengers ?? 0;
    // final int boardedCount = response?.boardedCount ?? 0;
    // final int missingCount = response?.missingCount ?? 0;
    // final int wrongBusCount = response?.wrongBusCount ?? 0;
    // final int invalidUserCount = response?.invalidUserCount ?? 0;

    // final List<dynamic> boardedList =
    //     response?.boardedList.map((e) => e.toJson()).toList() ?? [];
    // final List<dynamic> invalidUserList =
    //     response?.invalidUserList.map((e) => e.toJson()).toList() ?? [];

    // final List<dynamic> missingList =
    //     response?.missingPassengers.map((e) => e.toJson()).toList() ?? [];
    // final List<dynamic> wrongBusList =
    //     response?.wrongBus.map((e) => e.toJson()).toList() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF213AEC), // Vibrant brand blue
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Scan Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [_buildRangeSettingsButton(context)],
      ),
      body: SafeArea(
        child: GetBuilder<BusScanController>(
          builder: (c) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRouteCard(),
                        const SizedBox(height: 16),
                        Obx(
                          () => _buildStatsRow(
                            controller
                                    .checkStatusResponse
                                    .value
                                    ?.totalPassengers ??
                                0,
                            controller
                                    .checkStatusResponse
                                    .value
                                    ?.boardedCount ??
                                0,
                            controller
                                    .checkStatusResponse
                                    .value
                                    ?.missingCount ??
                                0,
                            controller
                                    .checkStatusResponse
                                    .value
                                    ?.wrongBusCount ??
                                0,
                            controller
                                    .checkStatusResponse
                                    .value
                                    ?.invalidUserCount ??
                                0,
                            controller.checkStatusResponse.value?.boardedList
                                    .map((e) => e.toJson())
                                    .toList() ??
                                [],
                            controller
                                    .checkStatusResponse
                                    .value
                                    ?.invalidUserList
                                    .map((e) => e.toJson())
                                    .toList() ??
                                [],
                          ),
                        ),
                        // const SizedBox(height: 20),
                        // _buildMissingSection(
                        //   controller.checkStatusResponse.value?.missingPassengers
                        //           .map((e) => e.toJson())
                        //           .toList() ??
                        //       [],
                        // ),
                        // const SizedBox(height: 20),
                        // _buildWrongBusSection(
                        //   context,
                        //   controller.checkStatusResponse.value?.wrongBus
                        //           .map((e) => e.toJson())
                        //           .toList() ??
                        //       [],
                        // ),
                        // const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(context),
              ],
            );
          },
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
              Icons.track_changes,
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

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Route',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  fromLocation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Text(
                  'Vehicle ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.directions_bus_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  busName.padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF213AEC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    int total,
    int boarded,
    int missing,
    int wrongBus,
    int invalidUserCount,
    List<dynamic> boardedList,
    List<dynamic> invalidUserList,
  ) {
    return Column(
      children: [
        Row(
          children: [
            // Expanded(
            //   child: _buildStatCard(
            //     label: 'Total Passengers',
            //     value: total.toString().padLeft(2, '0'),
            //     icon: Icons.group_outlined,
            //     bgColor: const Color(0xFFEEF2FF),
            //     textColor: const Color(0xFF213AEC),
            //   ),
            // ),
            // const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Boarded',
                value: boarded.toString().padLeft(2, '0'),
                icon: Icons.check_circle_outline_rounded,
                bgColor: const Color(0xFFF0FDF4),
                textColor: const Color(0xFF22C55E),
                onTap: () => controller.showDetailsScreen('Boarded Passengers'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Unknown Tags',
                value: invalidUserCount.toString().padLeft(2, '0'),
                icon: Icons.help_outline_rounded,
                bgColor: const Color(0xFFF8FAFC),
                textColor: const Color(0xFF64748B),
                onTap: () => controller.showDetailsScreen('Unknown Tags'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row(
        //   children: [
        //     Expanded(
        //       child: _buildStatCard(
        //         label: 'Missing',
        //         value: missing.toString().padLeft(2, '0'),
        //         icon: Icons.error_outline_rounded,
        //         bgColor: const Color(0xFFFEF2F2),
        //         textColor: const Color(0xFFEF4444),
        //       ),
        //     ),
        //     const SizedBox(width: 10),
        //     Expanded(
        //       child: _buildStatCard(
        //         label: 'Wrong Bus',
        //         value: wrongBus.toString().padLeft(2, '0'),
        //         icon: Icons.warning_amber_rounded,
        //         bgColor: const Color(0xFFFFFBEB),
        //         textColor: const Color(0xFFF59E0B),
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 10),
        // Row(
        //   children: [
        //     Expanded(
        //       child: _buildStatCard(
        //         label: 'Unknown Tags',
        //         value: invalidUserCount.toString().padLeft(2, '0'),
        //         icon: Icons.help_outline_rounded,
        //         bgColor: const Color(0xFFF8FAFC),
        //         textColor: const Color(0xFF64748B),
        //         onTap: () => controller.showDetailsScreen(
        //           'Unknown Tags',
        //           invalidUserList,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: onTap != null
              ? Border.all(color: textColor.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingSection(List<dynamic> list) {
    final int count = list.length;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.error, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Missing Passengers (${count.toString().padLeft(2, '0')})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (count > 0)
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xFF213AEC),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (count == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No missing passengers.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count > 3 ? 3 : count, // Limit to 3 preview items
              separatorBuilder: (context, index) =>
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final passenger = list[index];
                final String name = passenger['name'] ?? 'Unknown';
                final String code =
                    passenger['uniq_id'] ?? passenger['username'] ?? '';
                final String initials = _getInitials(name);

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Color(0xFF213AEC),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF213AEC),
                      size: 20,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWrongBusSection(BuildContext context, List<dynamic> list) {
    final int count = list.length;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Wrong Bus (${count.toString().padLeft(2, '0')})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              // if (count > 0)
              //   GestureDetector(
              //     onTap: () {},
              //     child: const Text(
              //       'View all',
              //       style: TextStyle(
              //         color: Color(0xFF213AEC),
              //         fontSize: 13,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
            ],
          ),
          const SizedBox(height: 12),
          if (count == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No passengers on the wrong bus.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count > 3 ? 3 : count, // Limit to 3 preview items
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final passenger = list[index];
                final String name = passenger['name'] ?? 'Unknown';
                final String uniqId = passenger['uniq_id'] ?? '';
                final String scannedBus = passenger['scanned_bus'] ?? '';
                final String assignedBus = passenger['assigned_bus'] ?? '';
                final String scannedBusName =
                    passenger['scanned_bus_name'] ?? '';
                final String assignedBusName =
                    passenger['assigned_bus_name'] ?? '';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFE2E8F0),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF64748B),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$uniqId • RFID-$uniqId',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                // Scanned Bus Box
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFEF3C7,
                                      ), // Light yellow
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.directions_bus,
                                          color: Color(0xFFD97706),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Scanned Bus\n$scannedBusName',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              height: 1.1,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFB45309),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF213AEC),
                                    size: 14,
                                  ),
                                ),
                                // Assigned Bus Box
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFDCFCE7,
                                      ), // Light green
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFBBF7D0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.directions_bus,
                                          color: Color(0xFF15803D),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Assigned Bus\n$assignedBusName',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              height: 1.1,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF166534),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => _confirmUpdateBus(
                              context,
                              uniqId,
                              name,
                              scannedBus,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF213AEC),
                              side: const BorderSide(color: Color(0xFF213AEC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Update Bus',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showSubmitSummaryDialog(),
          icon: const Icon(Icons.save_outlined, color: Colors.white),
          label: const Text(
            'Submit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF213AEC),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  void _showSubmitSummaryDialog() {
    if (controller.checkStatusResponse.value!.invalidUserList.isNotEmpty) {
      Get.snackbar(
        'Invalid Users',
        'Some users are invalid. Please remove them before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.assignment_outlined, color: Color(0xFF213AEC)),
            SizedBox(width: 8),
            Text('Submit Confirmation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please review the trip summary before submitting to the server:',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildSummaryDetailRow('From Location:', fromLocation),

            _buildSummaryDetailRow('Selected Bus:', busName),
            const Divider(height: 24),
            _buildSummaryDetailRow(
              'Total Passengers:',
              controller.scannedTags.length.toString(),
              isBold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close summary dialog

              bool success = await controller.submitTrip();
              if (success) {
                _showSuccessDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213AEC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: const Text(
          'Trip data submitted successfully!',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close success dialog
              Get.back(); // Pop ScanDetailsScreen
              Get.back(); // Pop BusScanScreen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213AEC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSummaryDetailRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
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

  void _confirmUpdateBus(
    BuildContext context,
    String uniqId,
    String passengerName,
    String busCode,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Update Assignment'),
          content: Text(
            'Do you want to assign $passengerName to Bus $busCode?',
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
                Navigator.of(context).pop(); // Close dialog
                bool success = await controller.updateUserBus(uniqId);
                if (success) {
                  Get.back(); // Pop ScanDetailsScreen
                  // controller.checkStatus(
                  //   from: 'update',
                  // ); // Re-trigger checkStatus to refresh the screen

                  Get.snackbar(
                    'Success',
                    'Bus assignment updated for $passengerName.',
                    backgroundColor: const Color(0xFF10B981),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF213AEC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

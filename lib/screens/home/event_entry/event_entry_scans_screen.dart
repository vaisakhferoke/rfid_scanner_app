import 'package:event_rfid_app/controllers/range_controller.dart';
import 'package:event_rfid_app/services/range_settings_popup.dart';
import 'package:event_rfid_app/widgets/common_widgets/range_settings_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'controller/event_entry_scan_controller.dart';

class EventEntryScansScreen extends StatelessWidget {
  final EventEntryScannController controller = Get.put(
    EventEntryScannController(),
  );

  EventEntryScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Scanner'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Show range in text
          RangeSettingsButton(),
        ],
      ),
      body: Column(
        children: [
          _buildStatusSection(context),
          _buildActionButtons(),
          const Divider(),
          _buildListHeader(),
          Expanded(child: _buildTagList()),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context) {
    return Obx(() {
      final isConnected = controller.isConnected.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isConnected
                ? Colors.green.withOpacity(0.4)
                : Colors.red.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        color: isConnected
            ? Colors.green.withOpacity(0.05)
            : Colors.red.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Pulse-like status dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected ? Colors.green : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: isConnected
                          ? Colors.green.withOpacity(0.6)
                          : Colors.red.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isConnected
                            ? Colors.green[300]
                            : Colors.red[300],
                      ),
                    ),
                    Text(
                      isConnected
                          ? 'Real RFID Hardware Active'
                          : 'Tap retry to check connection',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildStatusSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildConnectionCard(context),
          const SizedBox(height: 8),
          Obx(() {
            final isScanning = controller.isScanning.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isScanning ? Icons.wifi_tethering : Icons.stop_screen_share,
                  color: isScanning ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isScanning
                      ? 'Scan Status: Scanning...'
                      : 'Scan Status: Stopped',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isScanning ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            return Text(
              'Total Unique Tags: ${controller.totalTagsCount.value}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() {
            bool isScanning = controller.isScanning.value;
            return ElevatedButton.icon(
              onPressed: isScanning ? null : () => controller.startScan(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            );
          }),
          Obx(() {
            bool isScanning = controller.isScanning.value;
            return ElevatedButton.icon(
              onPressed: !isScanning ? null : () => controller.stopScan(),
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => controller.clearData(),
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text('EPC', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text('RSSI', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text('Count', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Time',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList() {
    return Obx(() {
      if (controller.tags.isEmpty) {
        return const Center(
          child: Text(
            'No tags scanned yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.tags.length,
        itemBuilder: (context, index) {
          final tag = controller.tags[index];
          final timeFormat = DateFormat('hh:mm:ss a').format(tag.readTime);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tag.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (tag.isDecoded) ...[
                          const SizedBox(height: 2),
                          Text(
                            tag.epc,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${tag.rssi}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${tag.count}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      timeFormat,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
}

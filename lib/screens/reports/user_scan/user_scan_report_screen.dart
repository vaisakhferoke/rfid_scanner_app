import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/user_scan_report_controller.dart';

class UserScanReportScreen extends StatelessWidget {
  final UserScanReportController controller = Get.put(
    UserScanReportController(),
  );

  UserScanReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF213AEC),
        foregroundColor: Colors.white,
        title: const Text(
          'User Scan Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFiltersSection(context),
            const Divider(height: 1),
            _buildTabs(),
            const Divider(height: 1),
            Expanded(child: _buildReportList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(flex: 1, child: _buildTypeDropdown(context)),
              Obx(() {
                if (controller.awardTypes.length <= 1) {
                  return const SizedBox.shrink();
                }
                return Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildAwardTypeDropdown(context),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedType.value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            items: controller.types.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type.capitalizeFirst ?? type,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.setType(value);
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildAwardTypeDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedAwardType.value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          items: controller.awardTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type == 'All' ? 'All Award Types' : type,
                style: const TextStyle(color: Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.setAwardType(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Obx(() {
      final scanType = controller.selectedScanType.value;
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => controller.setScanType('notscanned'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: scanType == 'notscanned'
                          ? const Color(0xFF213AEC)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Not Scanned (${controller.notScannedCount.value})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scanType == 'notscanned'
                          ? const Color(0xFF213AEC)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => controller.setScanType('scanned'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: scanType == 'scanned'
                          ? const Color(0xFF213AEC)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Scanned (${controller.scannedCount.value})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scanType == 'scanned'
                          ? const Color(0xFF213AEC)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildReportList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
        onRefresh: () async {
          controller.fetchCounts();
          await controller.fetchReport();
        },
        child: controller.filteredData.isEmpty
            ? LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: const Center(
                      child: Text(
                        'No data found.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.filteredData.length,
                itemBuilder: (context, index) {
                  final item = controller.filteredData[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
                                    //  SHop Icon
                                    Icon(
                                      Icons.storefront,
                                      size: 18,
                                      color: Color(0xff213AEC),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  item.givenname,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'State: ${item.state}',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                if (item.awardType.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Award Type: ${item.awardType}',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (item.orderBy.isNotEmpty) ...[
                                      Text(
                                        'Order By: ${item.orderBy}',
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                    //
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "Code: ${item.uniqueId}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF213AEC),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.updateUserScan(item.uniqueId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF213AEC),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}

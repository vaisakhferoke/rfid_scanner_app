import 'package:event_rfid_app/models/location_model.dart';
import 'package:event_rfid_app/screens/reports/location_wise/location_wise_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/daywise_report_model.dart';
import 'controller/daywise_report_controller.dart';

class DaywiseReportScreen extends StatelessWidget {
  final DaywiseReportController controller = Get.put(DaywiseReportController());

  DaywiseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF213AEC),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daywise Report',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFiltersSection(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.reportData.isEmpty) {
                  return const Center(
                    child: Text(
                      'No data found. Select a day and search.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }
                return _buildResultsView(context);
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomStats(),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _buildDayDropdown(context)),
          const SizedBox(width: 8),
          _buildFilterActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDayDropdown(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isDaysLoading.value;
      if (isLoading) {
        return const SizedBox(
          height: 48,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      final daysList = controller.days;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DistinctDayModel>(
            value: controller.selectedDay.value,
            hint: const Text(
              'Select Day',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
            items: daysList.map((DistinctDayModel dayModel) {
              return DropdownMenuItem<DistinctDayModel>(
                value: dayModel,
                child: Text(
                  dayModel.day,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedDay.value = value;
            },
          ),
        ),
      );
    });
  }

  Widget _buildFilterActionButtons() {
    return Row(
      children: [
        IconButton(
          onPressed: controller.clearFilters,
          icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
          tooltip: 'Clear Filters',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: controller.fetchReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF213AEC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: const Icon(Icons.search, size: 20),
        ),
      ],
    );
  }

  Widget _buildResultsView(BuildContext context) {
    final dayVal = controller.selectedDay.value?.day;
    final int totalLocations = controller.reportData.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (dayVal != null) ...[
          _buildDayCard(dayVal),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 24),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Locations List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total Locations: $totalLocations',
                style: const TextStyle(
                  color: Color(0xFF213AEC),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...controller.reportData.map(
          (item) => _buildLocationCard(context, item),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            controller.downloadExcel();
          },
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Download & Share'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(String day) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF213AEC),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Day',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, DaywiseReportModel item) {
    return InkWell(
      onTap: () {
        Get.to(
          () => LocationWiseReportScreen(),
          arguments: {
            'location': LocationModel(
              id: item.locationId,
              name: item.location,
              isCurrentLocation: '0',
            ),
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF213AEC),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Name',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'User Count',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          item.userCount,
                          style: const TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
    );
  }

  Widget _buildBottomStats() {
    return Obx(() {
      if (controller.reportData.isEmpty) return const SizedBox.shrink();

      int totalUsers = 0;
      for (var item in controller.reportData) {
        totalUsers += int.tryParse(item.userCount) ?? 0;
      }

      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF213AEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Total Users Count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF213AEC),
                  ),
                ),
              ),
              Text(
                '$totalUsers',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF213AEC),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

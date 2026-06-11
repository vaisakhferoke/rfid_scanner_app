import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/location_based_user_details_controller.dart';

class LocationBasedUserDetailsScreen extends StatelessWidget {
  final String locationId;
  final String vehicleId;
  final String locationName;
  final String vehicleName;

  late final LocationBasedUserDetailsController controller;

  LocationBasedUserDetailsScreen({
    super.key,
    required this.locationId,
    required this.vehicleId,
    required this.locationName,
    required this.vehicleName,
  }) {
    controller = Get.put(
      LocationBasedUserDetailsController(
        locationId: locationId,
        vehicleId: vehicleId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF213AEC),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Delegate List',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Action for deleting the whole list or specific action from appbar
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.userDetails.isEmpty) {
            return const Center(
              child: Text(
                'No user details found.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }
          return _buildContent(context);
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final int totalUsers = controller.userDetails.length;
    final String rawDate = controller.userDetails.isNotEmpty
        ? controller.userDetails.first.date
        : '';
    final String displayDate = rawDate.replaceFirst(' ', '\n');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopCard(displayDate, totalUsers),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildDataTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: controller.downloadExcel,
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Download'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: controller.shareExcel,
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCard(String date, int totalUsers) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopCardColumn(
              Icons.location_on_outlined,
              'Location',
              locationName,
            ),
            _buildVerticalDivider(),
            _buildTopCardColumn(
              Icons.directions_bus_outlined,
              'Vehicle',
              vehicleName,
            ),
            _buildVerticalDivider(),
            _buildTopCardColumn(Icons.calendar_today_outlined, 'Date', date),
            _buildVerticalDivider(),
            _buildTopCardColumn(
              Icons.people_outline,
              'Total',
              totalUsers.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCardColumn(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF213AEC), size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'N/A' : value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: const Color(0xFFE2E8F0));
  }

  Widget _buildDataTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF0F172A)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          dataRowHeight: 80,
          columnSpacing: 24,
          border: const TableBorder(
            verticalInside: BorderSide(color: Color(0xFFE2E8F0)),
            horizontalInside: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Name\n(Code)')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('State')),
            DataColumn(label: Text('Given\nName')),
            DataColumn(label: Text('Surname')),
            DataColumn(label: Text('UID')),
            DataColumn(label: Text('Action')),
          ],
          rows: controller.userDetails.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;

            final isDelegate = user.type.toLowerCase().contains('delegate');

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.code,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDelegate
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.type,
                      style: TextStyle(
                        color: isDelegate
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF166534),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    user.state,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(user.givenname)),
                DataCell(Text(user.surname)),
                DataCell(
                  Text(
                    user.uniqId,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF4444),
                    ),
                    onPressed: () {
                      _showDeleteDialog(context, user.uniqId);
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    final TextEditingController passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please type "git123" to confirm deletion of this user.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text == 'git123') {
                Get.back(); // close dialog
                controller.deleteUser(userId);
              } else {
                Get.snackbar(
                  'Error',
                  'Incorrect password.',
                  backgroundColor: const Color(0xFFEF4444),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

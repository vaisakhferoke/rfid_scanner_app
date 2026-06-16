import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_rfid_app/controllers/activity_summary_details_controller.dart';

class ActivitySummaryDetailsScreen extends StatelessWidget {
  final ActivitySummaryDetailsController controller = Get.put(
    ActivitySummaryDetailsController(),
  );

  ActivitySummaryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Obx(
          () => Text(
            _getFormattedTitle(controller.type.value),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF0F172A)),
            onPressed: () {
              controller.downloadExcel();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0043A4)),
                );
              }

              final displayList = controller.filteredUsersList;

              if (displayList.isEmpty) {
                return const Center(
                  child: Text(
                    'No records found.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final user = displayList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  user.givenname.isNotEmpty
                                      ? user.givenname
                                      : user.givenname,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (user.uniqueId.isNotEmpty)
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
                                    user.uniqueId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF213AEC),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (user.name.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Dealer Name: ${user.name}',
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                          if (user.code.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Code: ${user.code}',
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                          if (user.state.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'State: ${user.state}',
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getFormattedTitle(String type) {
    if (type.isEmpty) return 'Details';
    List<String> parts = type.split('_');
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
      }
    }
    return parts.join(' ');
  }
}

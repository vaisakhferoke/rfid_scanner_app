import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/location_model.dart';
import '../../controllers/location_master_controller.dart';

class LocationMasterScreen extends GetView<LocationMasterController> {
  const LocationMasterScreen({super.key});

  void _showFormDialog(BuildContext context, {LocationModel? location}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: location?.name ?? '');
    bool isCurrentLocation = location?.isCurrentLocation == '1';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                location == null
                    ? Icons.add_circle_rounded
                    : Icons.edit_rounded,
                color: const Color(0xFF0043A4),
              ),
              const SizedBox(width: 8),
              Text(
                location == null ? 'Add Location' : 'Edit Location',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location Name',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Feroke, Kozhikode Main Gate',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter location name'
                      : null,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Is Current Location',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                        Switch(
                          value: isCurrentLocation,
                          activeColor: const Color(0xFF0043A4),
                          onChanged: (val) {
                            setStateSB(() {
                              isCurrentLocation = val;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  controller.saveLocation(
                    type: location == null ? 'add' : 'edit',
                    id: location?.id,
                    name: nameController.text.trim(),
                    isCurrentLocation: isCurrentLocation ? '1' : '0',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0043A4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDialog(BuildContext context, LocationModel location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                'Delete Location',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${location.name}"? This action cannot be undone.',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteLocation(location.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0043A4),
      appBar: AppBar(
        title: const Text(
          'Location Master',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0043A4),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: Column(
              children: [
                // Top Search & Server Address Info Row
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      // Search field
                      TextField(
                        controller: controller.searchController,
                        onChanged: controller.filterLocations,
                        decoration: InputDecoration(
                          hintText: 'Search by location name...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                          ),
                          suffixIcon: Obx(
                            () => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Color(0xFF64748B),
                                    ),
                                    onPressed: () {
                                      controller.searchController.clear();
                                      controller.filterLocations('');
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),

                // Location List area
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.fetchLocations,
                    color: const Color(0xFF0043A4),
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.locations.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0043A4),
                            ),
                          ),
                        );
                      }

                      if (controller.filteredLocations.isEmpty) {
                        return ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                            ),
                            const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_off_rounded,
                                    size: 72,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No Locations Found',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Pull down to refresh or add a new location.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        itemCount: controller.filteredLocations.length,
                        itemBuilder: (context, index) {
                          final location = controller.filteredLocations[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0043A4,
                                      ).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Color(0xFF0043A4),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                location.name,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                            if (location.isCurrentLocation ==
                                                '1') ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFEFF6FF,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Current',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0043A4),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'ID: ${location.id}',
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                    onPressed: () => _showFormDialog(
                                      context,
                                      location: location,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _confirmDeleteDialog(context, location),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        backgroundColor: const Color(0xFF0043A4),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

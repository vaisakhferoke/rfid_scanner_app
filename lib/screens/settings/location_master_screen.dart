import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/location_model.dart';
import '../../config/api_config.dart';
import '../../repository/location_repository.dart';

class LocationMasterScreen extends StatefulWidget {
  const LocationMasterScreen({super.key});

  @override
  State<LocationMasterScreen> createState() => _LocationMasterScreenState();
}

class _LocationMasterScreenState extends State<LocationMasterScreen> {
  final LocationRepository _locationRepository = LocationRepository();

  String _baseUrl = '';
  bool _isLoading = false;
  List<LocationModel> _locations = [];
  List<LocationModel> _filteredLocations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBaseUrlAndFetch();
  }

  Future<void> _loadBaseUrlAndFetch() async {
    final baseUrl = await ApiConfig.getBaseUrl();
    setState(() {
      _baseUrl = baseUrl;
    });
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _locationRepository.fetchLocations();
      setState(() {
        _locations = list;
        _filterLocations(_searchController.text);
      });
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredLocations = List.from(_locations);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredLocations = _locations.where((loc) {
        return loc.name.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _saveLocation({
    required String type, // 'add' or 'edit'
    String? id,
    required String name,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;
      if (type == 'add') {
        success = await _locationRepository.addLocation(name: name);
      } else if (type == 'edit' && id != null) {
        success = await _locationRepository.editLocation(id: id, name: name);
      }

      if (success) {
        Get.snackbar(
          'Success',
          'Location ${type == 'add' ? 'added' : 'updated'} successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        _fetchLocations();
      }
    } catch (e) {
      debugPrint('Error saving location: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteLocation(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _locationRepository.deleteLocation(id);
      if (success) {
        Get.snackbar(
          'Success',
          'Location deleted successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        _fetchLocations();
      }
    } catch (e) {
      debugPrint('Error deleting location: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  void _showBaseUrlConfigDialog() {
    final controller = TextEditingController(text: _baseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.settings_input_component_rounded,
                color: Color(0xFF0043A4),
              ),
              SizedBox(width: 8),
              Text(
                'API Server Address',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the backend API Base URL:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'e.g. http://newtest.vkcparivar.com/api/',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF0043A4),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ],
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
              onPressed: () async {
                String inputUrl = controller.text.trim();
                if (inputUrl.isNotEmpty) {
                  await ApiConfig.setBaseUrl(inputUrl);
                  setState(() {
                    _baseUrl = inputUrl;
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  _fetchLocations();
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
                'Save & Reconnect',
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

  void _showFormDialog({LocationModel? location}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: location?.name ?? '');

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
                  _saveLocation(
                    type: location == null ? 'add' : 'edit',
                    id: location?.id,
                    name: nameController.text.trim(),
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

  void _confirmDeleteDialog(LocationModel location) {
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
                _deleteLocation(location.id);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_input_component_rounded),
            tooltip: 'Server Settings',
            onPressed: _showBaseUrlConfigDialog,
          ),
        ],
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
                      // Active Base Url display
                      Row(
                        children: [
                          const Icon(
                            Icons.link,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Server: $_baseUrl',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: _showBaseUrlConfigDialog,
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0043A4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search field
                      TextField(
                        controller: _searchController,
                        onChanged: _filterLocations,
                        decoration: InputDecoration(
                          hintText: 'Search by location name...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Color(0xFF64748B),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterLocations('');
                                  },
                                )
                              : null,
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
                    onRefresh: _fetchLocations,
                    color: const Color(0xFF0043A4),
                    child: _isLoading && _locations.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0043A4),
                              ),
                            ),
                          )
                        : _filteredLocations.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
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
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            itemCount: _filteredLocations.length,
                            itemBuilder: (context, index) {
                              final location = _filteredLocations[index];
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                            Text(
                                              location.name,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
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
                                        onPressed: () =>
                                            _showFormDialog(location: location),
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
                                            _confirmDeleteDialog(location),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF0043A4),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

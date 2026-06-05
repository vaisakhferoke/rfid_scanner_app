import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/vehicle_model.dart';
import '../../config/api_config.dart';
import '../../repository/vehicle_repository.dart';

class VehicleMasterScreen extends StatefulWidget {
  const VehicleMasterScreen({super.key});

  @override
  State<VehicleMasterScreen> createState() => _VehicleMasterScreenState();
}

class _VehicleMasterScreenState extends State<VehicleMasterScreen> {
  final VehicleRepository _vehicleRepository = VehicleRepository();

  String _baseUrl = '';
  bool _isLoading = false;
  List<VehicleModel> _vehicles = [];
  List<VehicleModel> _filteredVehicles = [];
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
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _vehicleRepository.fetchVehicles();
      setState(() {
        _vehicles = list;
        _filterVehicles(_searchController.text);
      });
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterVehicles(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredVehicles = List.from(_vehicles);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredVehicles = _vehicles.where((vehicle) {
        return vehicle.name.toLowerCase().contains(lowerQuery) ||
            vehicle.vehicleType.toLowerCase().contains(lowerQuery) ||
            vehicle.remark.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _saveVehicle({
    required String type, // 'add' or 'edit'
    String? id,
    required String name,
    required String vehicleType,
    required String remark,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;
      if (type == 'add') {
        success = await _vehicleRepository.addVehicle(
          name: name,
          vehicleType: vehicleType,
          remark: remark,
        );
      } else if (type == 'edit' && id != null) {
        success = await _vehicleRepository.editVehicle(
          id: id,
          name: name,
          vehicleType: vehicleType,
          remark: remark,
        );
      }

      if (success) {
        Get.snackbar(
          'Success',
          'Vehicle ${type == 'add' ? 'added' : 'updated'} successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        _fetchVehicles();
      }
    } catch (e) {
      debugPrint('Error saving vehicle: $e');
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteVehicle(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _vehicleRepository.deleteVehicle(id);
      if (success) {
        Get.snackbar(
          'Success',
          'Vehicle deleted successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
        _fetchVehicles();
      }
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
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
                  _fetchVehicles();
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

  void _showFormDialog({VehicleModel? vehicle}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: vehicle?.name ?? '');
    final remarkController = TextEditingController(text: vehicle?.remark ?? '');
    String selectedType =
        (vehicle != null &&
            [
              'Bus',
              'Van',
              'Mini Bus',
              'Truck',
              'Car',
            ].contains(vehicle.vehicleType))
        ? vehicle.vehicleType
        : 'Bus';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    vehicle == null
                        ? Icons.add_circle_rounded
                        : Icons.edit_rounded,
                    color: const Color(0xFF0043A4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Name',
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
                          hintText: 'e.g. Bus 102, Delivery Van',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Please enter a name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vehicle Type',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            isExpanded: true,
                            items: ['Bus', 'Van', 'Mini Bus', 'Truck', 'Car']
                                .map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedType = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Remark',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: remarkController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. Route A scanner, spare vehicle',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      _saveVehicle(
                        type: vehicle == null ? 'add' : 'edit',
                        id: vehicle?.id,
                        name: nameController.text.trim(),
                        vehicleType: selectedType,
                        remark: remarkController.text.trim(),
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
      },
    );
  }

  void _confirmDeleteDialog(VehicleModel vehicle) {
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
                'Delete Vehicle',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${vehicle.name}"? This action cannot be undone.',
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
                _deleteVehicle(vehicle.id);
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

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'van':
        return Icons.airport_shuttle_rounded;
      case 'mini bus':
        return Icons.airport_shuttle_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      default:
        return Icons.directions_bus_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0043A4),
      appBar: AppBar(
        title: const Text(
          'Vehicle Master',
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
                        onChanged: _filterVehicles,
                        decoration: InputDecoration(
                          hintText: 'Search by vehicle name, type, remark...',
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
                                    _filterVehicles('');
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

                // Vehicle List area
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchVehicles,
                    color: const Color(0xFF0043A4),
                    child: _isLoading && _vehicles.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0043A4),
                              ),
                            ),
                          )
                        : _filteredVehicles.isEmpty
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
                                      Icons.directions_bus_filled_outlined,
                                      size: 72,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No Vehicles Found',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Pull down to refresh or add a new vehicle.',
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
                            itemCount: _filteredVehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = _filteredVehicles[index];
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
                                        child: Icon(
                                          _getVehicleIcon(vehicle.vehicleType),
                                          color: const Color(0xFF0043A4),
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
                                                Text(
                                                  vehicle.name,
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
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
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    vehicle.vehicleType,
                                                    style: const TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF0043A4),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (vehicle.remark.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                vehicle.remark,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                            if (vehicle.addedOn.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                'Added: ${vehicle.addedOn}',
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 10,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
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
                                            _showFormDialog(vehicle: vehicle),
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
                                            _confirmDeleteDialog(vehicle),
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

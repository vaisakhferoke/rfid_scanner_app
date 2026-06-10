class LocationWiseReportModel {
  final String locationId;
  final String location;
  final String vehicleId;
  final String vehicleName;
  final String scannedCount;

  LocationWiseReportModel({
    required this.locationId,
    required this.location,
    required this.vehicleId,
    required this.vehicleName,
    required this.scannedCount,
  });

  factory LocationWiseReportModel.fromJson(Map<String, dynamic> json) {
    return LocationWiseReportModel(
      locationId: json['location_id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString() ?? '',
      scannedCount: json['scanned_count']?.toString() ?? '',
    );
  }
}

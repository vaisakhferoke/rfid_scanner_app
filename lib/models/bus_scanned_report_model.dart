class BusScannedReportModel {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String uniqueId;
  final String user;
  final String code;
  final String busNo;
  final String day;
  final String fromLocationId;
  final String fromLocation;
  final String toLocationId;
  final String toLocation;
  final String date;

  BusScannedReportModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.uniqueId,
    required this.user,
    required this.code,
    required this.busNo,
    required this.day,
    required this.fromLocationId,
    required this.fromLocation,
    required this.toLocationId,
    required this.toLocation,
    required this.date,
  });

  factory BusScannedReportModel.fromJson(Map<String, dynamic> json) {
    return BusScannedReportModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString() ?? '',
      uniqueId: json['unique_id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      busNo: json['bus_no']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      fromLocationId: json['from_location_id']?.toString() ?? '',
      fromLocation: json['from_location']?.toString() ?? '',
      toLocationId: json['to_location_id']?.toString() ?? '',
      toLocation: json['to_location']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}

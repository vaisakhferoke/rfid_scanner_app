class DaywiseReportModel {
  final String locationId;
  final String location;
  final String userCount;

  DaywiseReportModel({
    required this.locationId,
    required this.location,
    required this.userCount,
  });

  factory DaywiseReportModel.fromJson(Map<String, dynamic> json) {
    return DaywiseReportModel(
      locationId: json['location_id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      userCount: json['user_count']?.toString() ?? '',
    );
  }
}

class DistinctDayModel {
  final String day;

  DistinctDayModel({required this.day});

  factory DistinctDayModel.fromJson(Map<String, dynamic> json) {
    return DistinctDayModel(
      day: json['day']?.toString() ?? '',
    );
  }
}

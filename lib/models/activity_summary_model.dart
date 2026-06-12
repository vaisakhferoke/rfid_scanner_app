class ActivitySummaryModel {
  final bool status;
  final String message;
  final String totalCount;
  final String parasailingAssignedCount;
  final String parasailingUsedCount;
  final String snorkelingAssignedCount;
  final String snorkelingUsedCount;
  final String bananaBoatAssignedCount;
  final String bananaBoatUsedCount;

  ActivitySummaryModel({
    required this.status,
    required this.message,
    required this.totalCount,
    required this.parasailingAssignedCount,
    required this.parasailingUsedCount,
    required this.snorkelingAssignedCount,
    required this.snorkelingUsedCount,
    required this.bananaBoatAssignedCount,
    required this.bananaBoatUsedCount,
  });

  factory ActivitySummaryModel.fromJson(Map<String, dynamic> json) {
    return ActivitySummaryModel(
      status: json['status'] ?? false,
      message: json['Message'] ?? '',
      totalCount: json['total_count']?.toString() ?? '0',
      parasailingAssignedCount:
          json['parasailing_assigned_count']?.toString() ?? '0',
      parasailingUsedCount: json['parasailing_used_count']?.toString() ?? '0',
      snorkelingAssignedCount:
          json['snorkeling_assigned_count']?.toString() ?? '0',
      snorkelingUsedCount: json['snorkeling_used_count']?.toString() ?? '0',
      bananaBoatAssignedCount:
          json['banana_boat_assigned_count']?.toString() ?? '0',
      bananaBoatUsedCount: json['banana_boat_used_count']?.toString() ?? '0',
    );
  }
}

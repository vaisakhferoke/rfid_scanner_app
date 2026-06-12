class ActivitySummaryDetailModel {
  final String uniqueId;
  final String name;
  final String code;
  final String state;
  final String givenname;

  ActivitySummaryDetailModel({
    required this.uniqueId,
    required this.name,
    required this.code,
    required this.state,
    required this.givenname,
  });

  factory ActivitySummaryDetailModel.fromJson(Map<String, dynamic> json) {
    return ActivitySummaryDetailModel(
      uniqueId: json['unique_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['user']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      givenname: json['givenname']?.toString() ?? '',
    );
  }
}

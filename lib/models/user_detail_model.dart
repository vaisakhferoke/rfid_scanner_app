class UserDetailModel {
  final String uniqueId;
  final String user;
  final String state;
  final String vehicleName;

  UserDetailModel({
    required this.uniqueId,
    required this.user,
    required this.state,
    required this.vehicleName,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      uniqueId: json['unique_id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString() ?? '',
    );
  }
}

class UserDetailModel {
  final String uniqueId;
  final String user;
  final String state;
  final String vehicleName;
  final String name;
  final String type;

  UserDetailModel({
    required this.uniqueId,
    required this.user,
    required this.state,
    required this.vehicleName,
    required this.name,
    required this.type,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      uniqueId: json['unique_id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class UserDetailModel {
  final String uniqueId;
  final String user;
  final String state;

  UserDetailModel({required this.uniqueId, required this.user, required this.state});

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      uniqueId: json['unique_id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }
}

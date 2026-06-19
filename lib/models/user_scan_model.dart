class UserScanModel {
  final String id;
  final String uniqueId;
  final String title;
  final String name;
  final String code;
  final String state;
  final String surname;
  final String givenname;
  final String type;
  final String checkinStatus;
  final String checkinTime;
  final String awardStatus;
  final String awardTime;
  final String photoboothStatus;
  final String photoboothTime;
  final String specialawardStatus;
  final String specialawardTime;
  final String awardType;
  final String specialAwardType;
  final String orderBy;

  UserScanModel({
    required this.id,
    required this.uniqueId,
    required this.title,
    required this.name,
    required this.code,
    required this.state,
    required this.surname,
    required this.givenname,
    required this.type,
    required this.checkinStatus,
    required this.checkinTime,
    required this.awardStatus,
    required this.awardTime,
    required this.photoboothStatus,
    required this.photoboothTime,
    required this.specialawardStatus,
    required this.specialawardTime,
    required this.awardType,
    required this.specialAwardType,
    required this.orderBy,
  });

  factory UserScanModel.fromJson(Map<String, dynamic> json) {
    return UserScanModel(
      id: json['id']?.toString() ?? '',
      uniqueId: json['unique_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      givenname: json['givenname']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      checkinStatus: json['checkin_status']?.toString() ?? '',
      checkinTime: json['checkin_time']?.toString() ?? '',
      awardStatus: json['award_status']?.toString() ?? '',
      awardTime: json['award_time']?.toString() ?? '',
      photoboothStatus: json['photobooth_status']?.toString() ?? '',
      photoboothTime: json['photobooth_time']?.toString() ?? '',
      specialawardStatus: json['specialaward_status']?.toString() ?? '',
      specialawardTime: json['specialaward_time']?.toString() ?? '',
      awardType: json['award_type']?.toString() ?? '',
      specialAwardType: json['special_award_type']?.toString() ?? '',
      orderBy: json['order_by']?.toString() ?? '',
    );
  }
}

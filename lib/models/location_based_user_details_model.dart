class LocationBasedUserDetailsModel {
  final String uniqId;
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
  final String photoBoothTime;
  final String date;
  final String locationId;
  final String location;
  final String vehicleId;
  final String vehicleName;

  LocationBasedUserDetailsModel({
    required this.uniqId,
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
    required this.photoBoothTime,
    required this.date,
    required this.locationId,
    required this.location,
    required this.vehicleId,
    required this.vehicleName,
  });

  factory LocationBasedUserDetailsModel.fromJson(Map<String, dynamic> json) {
    return LocationBasedUserDetailsModel(
      uniqId: json['uniq_id']?.toString() ?? '',
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
      photoBoothTime: json['photo_booth_time']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString() ?? '',
    );
  }
}

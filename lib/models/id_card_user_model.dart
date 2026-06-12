class IdCardUser {
  String? id;
  String? uniqueId;
  String? title;
  String? name;
  String? code;
  String? state;
  String? type;
  String? image;
  String? checkinStatus;
  String? checkinTime;
  String? awardStatus;
  String? awardTime;
  String? surname;
  String? givenname;
  String? photoboothStatus;
  String? photoboothTime;
  String? busId;
  String? bus;
  String? lastBusScan;
  String? day;
  String? eventIdCard;
  String? travelIdCard;

  IdCardUser(
      {this.id,
      this.uniqueId,
      this.title,
      this.name,
      this.code,
      this.state,
      this.type,
      this.image,
      this.checkinStatus,
      this.checkinTime,
      this.awardStatus,
      this.awardTime,
      this.surname,
      this.givenname,
      this.photoboothStatus,
      this.photoboothTime,
      this.busId,
      this.bus,
      this.lastBusScan,
      this.day,
      this.eventIdCard,
      this.travelIdCard});

  IdCardUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uniqueId = json['unique_id'];
    title = json['title'];
    name = json['name'];
    code = json['code'];
    state = json['state'];
    type = json['type'];
    image = json['image'];
    checkinStatus = json['checkin_status'];
    checkinTime = json['checkin_time'];
    awardStatus = json['award_status'];
    awardTime = json['award_time'];
    surname = json['surname'];
    givenname = json['givenname'];
    photoboothStatus = json['photobooth_status'];
    photoboothTime = json['photobooth_time'];
    busId = json['bus_id'];
    bus = json['bus'];
    lastBusScan = json['last_bus_scan'];
    day = json['day'];
    eventIdCard = json['event_id_card'];
    travelIdCard = json['travel_id_card'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unique_id'] = uniqueId;
    data['title'] = title;
    data['name'] = name;
    data['code'] = code;
    data['state'] = state;
    data['type'] = type;
    data['image'] = image;
    data['checkin_status'] = checkinStatus;
    data['checkin_time'] = checkinTime;
    data['award_status'] = awardStatus;
    data['award_time'] = awardTime;
    data['surname'] = surname;
    data['givenname'] = givenname;
    data['photobooth_status'] = photoboothStatus;
    data['photobooth_time'] = photoboothTime;
    data['bus_id'] = busId;
    data['bus'] = bus;
    data['last_bus_scan'] = lastBusScan;
    data['day'] = day;
    data['event_id_card'] = eventIdCard;
    data['travel_id_card'] = travelIdCard;
    return data;
  }
}

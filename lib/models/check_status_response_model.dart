class CheckStatusResponseModel {
  final bool status;
  final int totalPassengers;
  final int boardedCount;
  final List<BoardedUser> boardedList;
  final int invalidUserCount;
  final List<InvalidUser> invalidUserList;
  final int missingCount;
  final int wrongBusCount;
  final List<MissingPassenger> missingPassengers;
  final List<WrongBusUser> wrongBus;

  CheckStatusResponseModel({
    required this.status,
    required this.totalPassengers,
    required this.boardedCount,
    required this.boardedList,
    required this.invalidUserCount,
    required this.invalidUserList,
    required this.missingCount,
    required this.wrongBusCount,
    required this.missingPassengers,
    required this.wrongBus,
  });

  factory CheckStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckStatusResponseModel(
      status: json['status'] ?? false,
      totalPassengers: json['totalpassengers'] ?? 0,
      boardedCount: json['boardedCount'] ?? 0,
      boardedList: (json['boardedlist'] as List<dynamic>?)
              ?.map((e) => BoardedUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      invalidUserCount: json['invalidusercount'] ?? 0,
      invalidUserList: (json['invaliduserlist'] as List<dynamic>?)
              ?.map((e) => InvalidUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      missingCount: json['missing_count'] ?? 0,
      wrongBusCount: json['wrong_bus_count'] ?? 0,
      missingPassengers: (json['missing_passengers'] as List<dynamic>?)
              ?.map((e) => MissingPassenger.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      wrongBus: (json['wrong_bus'] as List<dynamic>?)
              ?.map((e) => WrongBusUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalpassengers': totalPassengers,
      'boardedCount': boardedCount,
      'boardedlist': boardedList.map((e) => e.toJson()).toList(),
      'invalidusercount': invalidUserCount,
      'invaliduserlist': invalidUserList.map((e) => e.toJson()).toList(),
      'missing_count': missingCount,
      'wrong_bus_count': wrongBusCount,
      'missing_passengers': missingPassengers.map((e) => e.toJson()).toList(),
      'wrong_bus': wrongBus.map((e) => e.toJson()).toList(),
    };
  }
}

class BoardedUser {
  final String uniqId;
  final String name;
  final String state;

  BoardedUser({
    required this.uniqId,
    required this.name,
    required this.state,
  });

  factory BoardedUser.fromJson(Map<String, dynamic> json) {
    return BoardedUser(
      uniqId: json['uniq_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniq_id': uniqId,
      'name': name,
      'state': state,
    };
  }
}

class InvalidUser {
  final String uniqId;

  InvalidUser({
    required this.uniqId,
  });

  factory InvalidUser.fromJson(Map<String, dynamic> json) {
    return InvalidUser(
      uniqId: json['uniq_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniq_id': uniqId,
    };
  }
}

class MissingPassenger {
  final String uniqId;
  final String name;
  final String code;

  MissingPassenger({
    required this.uniqId,
    required this.name,
    required this.code,
  });

  factory MissingPassenger.fromJson(Map<String, dynamic> json) {
    return MissingPassenger(
      uniqId: json['uniq_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniq_id': uniqId,
      'name': name,
      'code': code,
    };
  }
}

class WrongBusUser {
  final String uniqId;
  final String name;
  final String code;
  final String assignedBus;
  final String assignedBusName;
  final String scannedBus;
  final String scannedBusName;

  WrongBusUser({
    required this.uniqId,
    required this.name,
    required this.code,
    required this.assignedBus,
    required this.assignedBusName,
    required this.scannedBus,
    required this.scannedBusName,
  });

  factory WrongBusUser.fromJson(Map<String, dynamic> json) {
    return WrongBusUser(
      uniqId: json['uniq_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      assignedBus: json['assigned_bus']?.toString() ?? '',
      assignedBusName: json['assigned_bus_name']?.toString() ?? '',
      scannedBus: json['scanned_bus']?.toString() ?? '',
      scannedBusName: json['scanned_bus_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniq_id': uniqId,
      'name': name,
      'code': code,
      'assigned_bus': assignedBus,
      'assigned_bus_name': assignedBusName,
      'scanned_bus': scannedBus,
      'scanned_bus_name': scannedBusName,
    };
  }
}

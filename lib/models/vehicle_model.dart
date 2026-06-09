class VehicleModel {
  final String id;
  final String name;
  final String vehicleTypeId;
  final String vehicleType;
  final String remark;
  final String addedOn;

  VehicleModel({
    required this.id,
    required this.name,
    required this.vehicleTypeId,
    required this.vehicleType,
    required this.remark,
    required this.addedOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicletype_id': vehicleTypeId,
      'vehicletype': vehicleType,
      'remark': remark,
      'added_on': addedOn,
    };
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      vehicleTypeId: json['vehicletype_id']?.toString() ?? '',
      vehicleType: json['vehicletype']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      addedOn: json['added_on']?.toString() ?? '',
    );
  }

  VehicleModel copyWith({
    String? id,
    String? name,
    String? vehicleTypeId,
    String? vehicleType,
    String? remark,
    String? addedOn,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      vehicleType: vehicleType ?? this.vehicleType,
      remark: remark ?? this.remark,
      addedOn: addedOn ?? this.addedOn,
    );
  }
}

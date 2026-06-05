class VehicleModel {
  final String id;
  final String name;
  final String vehicleType;
  final String remark;
  final String addedOn;

  VehicleModel({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.remark,
    required this.addedOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicle_type': vehicleType,
      'remark': remark,
      'added_on': addedOn,
    };
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      addedOn: json['added_on']?.toString() ?? '',
    );
  }

  VehicleModel copyWith({
    String? id,
    String? name,
    String? vehicleType,
    String? remark,
    String? addedOn,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleType: vehicleType ?? this.vehicleType,
      remark: remark ?? this.remark,
      addedOn: addedOn ?? this.addedOn,
    );
  }
}

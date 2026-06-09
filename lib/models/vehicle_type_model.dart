class VehicleTypeModel {
  final String id;
  final String name;

  VehicleTypeModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  VehicleTypeModel copyWith({
    String? id,
    String? name,
  }) {
    return VehicleTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

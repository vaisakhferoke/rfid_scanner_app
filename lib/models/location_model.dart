class LocationModel {
  final String id;
  final String name;

  LocationModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  LocationModel copyWith({
    String? id,
    String? name,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

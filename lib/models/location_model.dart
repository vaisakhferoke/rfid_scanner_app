class LocationModel {
  final String id;
  final String name;
  final String isCurrentLocation;

  LocationModel({
    required this.id,
    required this.name,
    required this.isCurrentLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_current_location': isCurrentLocation,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isCurrentLocation: json['is_current_location']?.toString() ?? '0',
    );
  }

  LocationModel copyWith({
    String? id,
    String? name,
    String? isCurrentLocation,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }
}

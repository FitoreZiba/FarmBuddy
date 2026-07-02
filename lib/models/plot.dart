class Plot {
  final String id;
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final double? areaSqMeters;
  final String? soilType;
  final DateTime createdAt;

  Plot({
    required this.id,
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.areaSqMeters,
    this.soilType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'areaSqMeters': areaSqMeters,
        'soilType': soilType,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Plot.fromMap(Map<String, dynamic> map) => Plot(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        areaSqMeters: map['areaSqMeters'] == null
            ? null
            : (map['areaSqMeters'] as num).toDouble(),
        soilType: map['soilType'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  Plot copyWith({
    String? name,
    double? latitude,
    double? longitude,
    double? areaSqMeters,
    String? soilType,
  }) =>
      Plot(
        id: id,
        userId: userId,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        areaSqMeters: areaSqMeters ?? this.areaSqMeters,
        soilType: soilType ?? this.soilType,
        createdAt: createdAt,
      );
}

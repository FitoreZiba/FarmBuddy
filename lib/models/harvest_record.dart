class HarvestRecord {
  final String id;
  final String cropId;
  final DateTime date;
  final double yieldKg;
  final String? qualityNotes;
  final String? photoPath;

  HarvestRecord({
    required this.id,
    required this.cropId,
    required this.date,
    required this.yieldKg,
    this.qualityNotes,
    this.photoPath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cropId': cropId,
        'date': date.toIso8601String(),
        'yieldKg': yieldKg,
        'qualityNotes': qualityNotes,
        'photoPath': photoPath,
      };

  factory HarvestRecord.fromMap(Map<String, dynamic> map) => HarvestRecord(
        id: map['id'] as String,
        cropId: map['cropId'] as String,
        date: DateTime.parse(map['date'] as String),
        yieldKg: (map['yieldKg'] as num).toDouble(),
        qualityNotes: map['qualityNotes'] as String?,
        photoPath: map['photoPath'] as String?,
      );
}

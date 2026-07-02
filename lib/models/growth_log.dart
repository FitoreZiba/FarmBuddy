import 'crop.dart';

class GrowthLog {
  final String id;
  final String cropId;
  final DateTime date;
  final String? photoPath;
  final String? note;
  final CropStage stageAtLog;

  GrowthLog({
    required this.id,
    required this.cropId,
    required this.date,
    this.photoPath,
    this.note,
    required this.stageAtLog,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cropId': cropId,
        'date': date.toIso8601String(),
        'photoPath': photoPath,
        'note': note,
        'stageAtLog': stageAtLog.name,
      };

  factory GrowthLog.fromMap(Map<String, dynamic> map) => GrowthLog(
        id: map['id'] as String,
        cropId: map['cropId'] as String,
        date: DateTime.parse(map['date'] as String),
        photoPath: map['photoPath'] as String?,
        note: map['note'] as String?,
        stageAtLog: stageFromString(map['stageAtLog'] as String),
      );
}

class WeatherSnapshot {
  final String id;
  final String plotId;
  final DateTime date;
  final double tempHighC;
  final double tempLowC;
  final double precipitationMm;
  final DateTime fetchedAt;
  final String? conditionCode;

  WeatherSnapshot({
    required this.id,
    required this.plotId,
    required this.date,
    required this.tempHighC,
    required this.tempLowC,
    required this.precipitationMm,
    required this.fetchedAt,
    this.conditionCode,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'plotId': plotId,
        'date': date.toIso8601String(),
        'tempHighC': tempHighC,
        'tempLowC': tempLowC,
        'precipitationMm': precipitationMm,
        'fetchedAt': fetchedAt.toIso8601String(),
        'conditionCode': conditionCode,
      };

  factory WeatherSnapshot.fromMap(Map<String, dynamic> map) => WeatherSnapshot(
        id: map['id'] as String,
        plotId: map['plotId'] as String,
        date: DateTime.parse(map['date'] as String),
        tempHighC: (map['tempHighC'] as num).toDouble(),
        tempLowC: (map['tempLowC'] as num).toDouble(),
        precipitationMm: (map['precipitationMm'] as num).toDouble(),
        fetchedAt: DateTime.parse(map['fetchedAt'] as String),
        conditionCode: map['conditionCode'] as String?,
      );
}

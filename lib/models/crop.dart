enum CropStage { seed, germination, vegetative, flowering, fruiting, harvested }

CropStage stageFromString(String s) =>
    CropStage.values.firstWhere((e) => e.name == s, orElse: () => CropStage.seed);

class CropTypeDefaults {
  final double baseTempC;
  final double gddToMaturity;
  final int daysToMaturity;
  final List<int> stageDayThresholds;
  const CropTypeDefaults(
    this.baseTempC,
    this.gddToMaturity,
    this.daysToMaturity,
    this.stageDayThresholds,
  );
}


const Map<String, CropTypeDefaults> kCropDefaults = {
  'Watermelon': CropTypeDefaults(15.5, 1500, 90,  [5,  20, 45, 65, 90]),
  'Tomato':     CropTypeDefaults(10.0, 1400, 80,  [7,  21, 40, 55, 80]),
  'Pepper':     CropTypeDefaults(12.8, 1500, 90,  [10, 25, 50, 65, 90]),
  'Cucumber':   CropTypeDefaults(15.5, 900,  55,  [4,  14, 30, 42, 55]),
  'Corn':       CropTypeDefaults(10.0, 1300, 75,  [7,  20, 45, 60, 75]),
  'Lettuce':    CropTypeDefaults(4.4,  500,  45,  [5,  12, 25, 35, 45]),
  'Other':      CropTypeDefaults(10.0, 1200, 75,  [7,  21, 40, 55, 75]),
};


CropStage inferStageFromDays(String cropType, DateTime plantingDate) {
  final days = DateTime.now().difference(plantingDate).inDays;
  final t = kCropDefaults[cropType]?.stageDayThresholds ??
      kCropDefaults['Other']!.stageDayThresholds;
  if (days < t[0]) return CropStage.seed;
  if (days < t[1]) return CropStage.germination;
  if (days < t[2]) return CropStage.vegetative;
  if (days < t[3]) return CropStage.flowering;
  if (days < t[4]) return CropStage.fruiting;
  return CropStage.harvested;
}

double inferProgressFromDays(String cropType, DateTime plantingDate) {
  final days = DateTime.now().difference(plantingDate).inDays;
  final total = kCropDefaults[cropType]?.daysToMaturity ??
      kCropDefaults['Other']!.daysToMaturity;
  return (days / total * 100).clamp(0.0, 100.0);
}

class Crop {
  final String id;
  final String plotId;
  final String cropType;
  final String? variety;
  final DateTime plantingDate;
  final CropStage currentStage;
  final double baseTempC;
  final double gddToMaturity;
  final double accumulatedGDD;
  final DateTime? estimatedHarvestDate;
  final String status;

  Crop({
    required this.id,
    required this.plotId,
    required this.cropType,
    this.variety,
    required this.plantingDate,
    this.currentStage = CropStage.seed,
    required this.baseTempC,
    required this.gddToMaturity,
    this.accumulatedGDD = 0,
    this.estimatedHarvestDate,
    this.status = 'active',
  });

  double get progressPercent {
    if (accumulatedGDD > 0 && gddToMaturity > 0) {
      return (accumulatedGDD / gddToMaturity).clamp(0, 1) * 100;
    }
    return inferProgressFromDays(cropType, plantingDate);
  }

  
  CropStage get displayStage {
    
    if (currentStage == CropStage.seed &&
        DateTime.now().difference(plantingDate).inDays > 7) {
      return inferStageFromDays(cropType, plantingDate);
    }
    return currentStage;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'plotId': plotId,
        'cropType': cropType,
        'variety': variety,
        'plantingDate': plantingDate.toIso8601String(),
        'currentStage': currentStage.name,
        'baseTempC': baseTempC,
        'gddToMaturity': gddToMaturity,
        'accumulatedGDD': accumulatedGDD,
        'estimatedHarvestDate': estimatedHarvestDate?.toIso8601String(),
        'status': status,
      };

  factory Crop.fromMap(Map<String, dynamic> map) => Crop(
        id: map['id'] as String,
        plotId: map['plotId'] as String,
        cropType: map['cropType'] as String,
        variety: map['variety'] as String?,
        plantingDate: DateTime.parse(map['plantingDate'] as String),
        currentStage: stageFromString(map['currentStage'] as String),
        baseTempC: (map['baseTempC'] as num).toDouble(),
        gddToMaturity: (map['gddToMaturity'] as num).toDouble(),
        accumulatedGDD: (map['accumulatedGDD'] as num).toDouble(),
        estimatedHarvestDate: map['estimatedHarvestDate'] == null
            ? null
            : DateTime.parse(map['estimatedHarvestDate'] as String),
        status: map['status'] as String? ?? 'active',
      );

  Crop copyWith({
    String? variety,
    CropStage? currentStage,
    double? accumulatedGDD,
    DateTime? estimatedHarvestDate,
    String? status,
  }) =>
      Crop(
        id: id,
        plotId: plotId,
        cropType: cropType,
        variety: variety ?? this.variety,
        plantingDate: plantingDate,
        currentStage: currentStage ?? this.currentStage,
        baseTempC: baseTempC,
        gddToMaturity: gddToMaturity,
        accumulatedGDD: accumulatedGDD ?? this.accumulatedGDD,
        estimatedHarvestDate: estimatedHarvestDate ?? this.estimatedHarvestDate,
        status: status ?? this.status,
      );
}

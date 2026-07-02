import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/crop.dart';
import '../models/growth_log.dart';
import '../models/harvest_record.dart';
import '../models/weather_snapshot.dart';
import '../services/database_helper.dart';
import '../services/gdd_calculator.dart';

class CropProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  List<Crop> _crops = [];
  final Map<String, List<GrowthLog>> _logsByCrop = {};
  final Map<String, List<HarvestRecord>> _harvestsByCrop = {};
  bool isLoading = false;

  List<Crop> get crops => _crops;
  List<Crop> cropsForPlot(String plotId) => _crops.where((c) => c.plotId == plotId).toList();
  List<GrowthLog> logsForCrop(String cropId) => _logsByCrop[cropId] ?? [];
  List<HarvestRecord> harvestsForCrop(String cropId) => _harvestsByCrop[cropId] ?? [];

  Crop? byId(String id) {
    try {
      return _crops.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadAllForUserPlots(List<String> plotIds) async {
    isLoading = true;
    notifyListeners();
    _crops = [];
    for (final plotId in plotIds) {
      final rows = await _db.queryAll('crops', where: 'plotId = ?', whereArgs: [plotId]);
      _crops.addAll(rows.map((r) => Crop.fromMap(r)));
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadLogsForCrop(String cropId) async {
    final rows = await _db.queryAll('growth_logs', where: 'cropId = ?', whereArgs: [cropId], orderBy: 'date DESC');
    _logsByCrop[cropId] = rows.map((r) => GrowthLog.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> loadHarvestsForCrop(String cropId) async {
    final rows = await _db.queryAll('harvest_records', where: 'cropId = ?', whereArgs: [cropId], orderBy: 'date DESC');
    _harvestsByCrop[cropId] = rows.map((r) => HarvestRecord.fromMap(r)).toList();
    notifyListeners();
  }

  Future<Crop> addCrop({
    required String plotId,
    required String cropType,
    String? variety,
    required DateTime plantingDate,
  }) async {
    final defaults = kCropDefaults[cropType] ?? kCropDefaults['Other']!;
    final crop = Crop(
      id: _uuid.v4(),
      plotId: plotId,
      cropType: cropType,
      variety: variety,
      plantingDate: plantingDate,
      baseTempC: defaults.baseTempC,
      gddToMaturity: defaults.gddToMaturity,
    );
    await _db.insert('crops', crop.toMap());
    _crops.insert(0, crop);
    notifyListeners();
    return crop;
  }

  Future<void> updateCrop(Crop crop) async {
    await _db.update('crops', crop.toMap(), crop.id);
    final idx = _crops.indexWhere((c) => c.id == crop.id);
    if (idx != -1) _crops[idx] = crop;
    notifyListeners();
  }

  Future<void> deleteCrop(String id) async {
    await _db.delete('crops', id);
    _crops.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<GrowthLog> addGrowthLog({
    required String cropId,
    required DateTime date,
    String? photoPath,
    String? note,
  }) async {
    final crop = byId(cropId);
    final log = GrowthLog(
      id: _uuid.v4(),
      cropId: cropId,
      date: date,
      photoPath: photoPath,
      note: note,
      stageAtLog: crop?.currentStage ?? CropStage.seed,
    );
    await _db.insert('growth_logs', log.toMap());
    _logsByCrop.putIfAbsent(cropId, () => []).insert(0, log);
    notifyListeners();
    return log;
  }

  Future<HarvestRecord> addHarvestRecord({
    required String cropId,
    required DateTime date,
    required double yieldKg,
    String? qualityNotes,
    String? photoPath,
  }) async {
    final record = HarvestRecord(
      id: _uuid.v4(),
      cropId: cropId,
      date: date,
      yieldKg: yieldKg,
      qualityNotes: qualityNotes,
      photoPath: photoPath,
    );
    await _db.insert('harvest_records', record.toMap());
    _harvestsByCrop.putIfAbsent(cropId, () => []).insert(0, record);

    final crop = byId(cropId);
    if (crop != null) {
      await updateCrop(crop.copyWith(currentStage: CropStage.harvested, status: 'harvested'));
    }
    notifyListeners();
    return record;
  }

  /// Recomputes accumulated GDD for a crop from cached weather snapshots
  /// (innovation feature). Call after a fresh weather fetch.
  Future<void> recalculateGdd(String cropId, List<WeatherSnapshot> snapshotsSincePlanting) async {
    final crop = byId(cropId);
    if (crop == null) return;
    final accumulated = GddCalculator.accumulate(
      snapshots: snapshotsSincePlanting,
      baseTempC: crop.baseTempC,
    );
    final estimate = GddCalculator.estimateHarvestDate(
      plantingDate: crop.plantingDate,
      accumulatedGDD: accumulated,
      gddToMaturity: crop.gddToMaturity,
    );
    await updateCrop(crop.copyWith(accumulatedGDD: accumulated, estimatedHarvestDate: estimate));
  }
}

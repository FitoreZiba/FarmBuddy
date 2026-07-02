import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/weather_snapshot.dart';
import '../services/database_helper.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _service = WeatherService();
  final _uuid = const Uuid();

  Map<String, dynamic>? currentConditions; // for Dashboard snapshot card
  bool isLoading = false;
  String? errorMessage;

  final Map<String, List<WeatherSnapshot>> _snapshotsByPlot = {};
  List<WeatherSnapshot> snapshotsForPlot(String plotId) => _snapshotsByPlot[plotId] ?? [];

  Future<void> fetchCurrent(double lat, double lon) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentConditions = await _service.getCurrentWeather(lat, lon);
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  /// Fetches the forecast, writes it into the weather_snapshots cache table
  /// (so we're not re-hitting the API on every screen open), and returns the
  /// snapshots so the caller can feed CropProvider.recalculateGdd.
  Future<List<WeatherSnapshot>> fetchAndCacheForecast(String plotId, double lat, double lon) async {
    final daily = await _service.getDailyForecast(lat, lon);
    final List<WeatherSnapshot> snapshots = [];
    for (final d in daily) {
      final snap = WeatherSnapshot(
        id: _uuid.v4(),
        plotId: plotId,
        date: d['date'] as DateTime,
        tempHighC: d['high'] as double,
        tempLowC: d['low'] as double,
        precipitationMm: d['precip'] as double,
        fetchedAt: DateTime.now(),
        conditionCode: d['condition'] as String?,
      );
      await _db.insert('weather_snapshots', snap.toMap());
      snapshots.add(snap);
    }
    _snapshotsByPlot[plotId] = snapshots;
    notifyListeners();
    return snapshots;
  }

  Future<void> loadCachedSnapshots(String plotId) async {
    final rows = await _db.queryAll('weather_snapshots', where: 'plotId = ?', whereArgs: [plotId], orderBy: 'date ASC');
    _snapshotsByPlot[plotId] = rows.map((r) => WeatherSnapshot.fromMap(r)).toList();
    notifyListeners();
  }
}

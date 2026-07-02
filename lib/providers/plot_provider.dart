import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/plot.dart';
import '../services/database_helper.dart';

class PlotProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  List<Plot> _plots = [];
  bool isLoading = false;

  List<Plot> get plots => _plots;

  Plot? byId(String id) {
    try {
      return _plots.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadPlots(String userId) async {
    isLoading = true;
    notifyListeners();
    final rows = await _db.queryAll('plots', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    _plots = rows.map((r) => Plot.fromMap(r)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<Plot> addPlot({
    required String userId,
    required String name,
    required double latitude,
    required double longitude,
    double? areaSqMeters,
    String? soilType,
  }) async {
    final plot = Plot(
      id: _uuid.v4(),
      userId: userId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      areaSqMeters: areaSqMeters,
      soilType: soilType,
      createdAt: DateTime.now(),
    );
    await _db.insert('plots', plot.toMap());
    _plots.insert(0, plot);
    notifyListeners();
    return plot;
  }

  Future<void> updatePlot(Plot plot) async {
    await _db.update('plots', plot.toMap(), plot.id);
    final idx = _plots.indexWhere((p) => p.id == plot.id);
    if (idx != -1) _plots[idx] = plot;
    notifyListeners();
  }

  Future<void> deletePlot(String id) async {
    await _db.delete('plots', id);
    _plots.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}

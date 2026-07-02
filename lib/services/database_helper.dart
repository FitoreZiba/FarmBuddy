import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Central sqflite gateway. Plots, crops, growth logs, tasks, weather
/// snapshots, and harvest records all live in one local database since
/// they're relationally linked by foreign keys (plotId / cropId).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'farmbuddy.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE plots (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            areaSqMeters REAL,
            soilType TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE crops (
            id TEXT PRIMARY KEY,
            plotId TEXT NOT NULL,
            cropType TEXT NOT NULL,
            variety TEXT,
            plantingDate TEXT NOT NULL,
            currentStage TEXT NOT NULL,
            baseTempC REAL NOT NULL,
            gddToMaturity REAL NOT NULL,
            accumulatedGDD REAL NOT NULL DEFAULT 0,
            estimatedHarvestDate TEXT,
            status TEXT NOT NULL DEFAULT 'active',
            FOREIGN KEY (plotId) REFERENCES plots (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE growth_logs (
            id TEXT PRIMARY KEY,
            cropId TEXT NOT NULL,
            date TEXT NOT NULL,
            photoPath TEXT,
            note TEXT,
            stageAtLog TEXT NOT NULL,
            FOREIGN KEY (cropId) REFERENCES crops (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            cropId TEXT,
            plotId TEXT,
            type TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            isRecurring INTEGER NOT NULL DEFAULT 0,
            recurrenceDays INTEGER,
            completed INTEGER NOT NULL DEFAULT 0,
            completedAt TEXT,
            title TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE weather_snapshots (
            id TEXT PRIMARY KEY,
            plotId TEXT NOT NULL,
            date TEXT NOT NULL,
            tempHighC REAL NOT NULL,
            tempLowC REAL NOT NULL,
            precipitationMm REAL NOT NULL,
            fetchedAt TEXT NOT NULL,
            conditionCode TEXT,
            FOREIGN KEY (plotId) REFERENCES plots (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE harvest_records (
            id TEXT PRIMARY KEY,
            cropId TEXT NOT NULL,
            date TEXT NOT NULL,
            yieldKg REAL NOT NULL,
            qualityNotes TEXT,
            photoPath TEXT,
            FOREIGN KEY (cropId) REFERENCES crops (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Generic helpers used by the providers below.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String table, Map<String, dynamic> row, String id) async {
    final db = await database;
    return db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table,
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }
}

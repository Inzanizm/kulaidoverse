// services/local_database.dart
import 'package:kulaidoverse/games/game_history.dart';
import 'package:kulaidoverse/testing/test_result.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // services/local_database.dart

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'kulaidoverse.db');

    return await openDatabase(
      path,
      version: 3, // 🔥 INCREMENT from 2 to 3
      onCreate: (db, version) async {
        // Existing tables...
        await db.execute('''
        CREATE TABLE game_history (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          game_type TEXT NOT NULL,
          stage_reached INTEGER NOT NULL,
          score INTEGER NOT NULL,
          accuracy REAL NOT NULL,
          completed_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0
        )
      ''');
        await db.execute('''
        CREATE INDEX idx_user_id ON game_history(user_id)
      ''');

        await db.execute('''
        CREATE TABLE test_results (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          test_type TEXT NOT NULL,
          overall_rating REAL NOT NULL,
          overall_status TEXT NOT NULL,
          recommendation TEXT NOT NULL,
          completed_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0
        )
      ''');
        await db.execute('''
        CREATE INDEX idx_test_user_id ON test_results(user_id)
      ''');

        // 🔥 ADD user_settings table in onCreate
        await db.execute('''
        CREATE TABLE user_settings (
          user_id TEXT PRIMARY KEY,
          camera_quality TEXT DEFAULT 'medium',
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migration from version 1 to 2 (test_results table)
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS test_results (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            test_type TEXT NOT NULL,
            overall_rating REAL NOT NULL,
            overall_status TEXT NOT NULL,
            recommendation TEXT NOT NULL,
            completed_at TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0
          )
        ''');
          await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_test_user_id ON test_results(user_id)
        ''');
        }

        // 🔥 Migration from version 2 to 3 (user_settings table)
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS user_settings (
            user_id TEXT PRIMARY KEY,
            camera_quality TEXT DEFAULT 'medium',
            updated_at TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0
          )
        ''');
        }
      },
    );
  }

  // Insert game result locally
  Future<void> insertGameHistory(GameHistory history) async {
    final db = await database;
    await db.insert(
      'game_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all unsynced records
  Future<List<GameHistory>> getUnsyncedRecords(String userId) async {
    final db = await database;
    final maps = await db.query(
      'game_history',
      where: 'user_id = ? AND is_synced = ?',
      whereArgs: [userId, 0],
    );
    return maps.map((map) => GameHistory.fromMap(map)).toList();
  }

  // Add this method to force initialization
  Future<void> ensureInitialized() async {
    await database; // This triggers _initDatabase()
  }

  // Update all query methods to handle errors better:
  Future<List<GameHistory>> getGameHistory(String userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'game_history',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'completed_at DESC',
      );
      return maps.map((map) => GameHistory.fromMap(map)).toList();
    } catch (e) {
      print('Error getting game history: $e');
      return []; // Return empty on error instead of crashing
    }
  }

  // Mark records as synced
  Future<void> markAsSynced(List<String> ids) async {
    final db = await database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        'game_history',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  // Delete old records (optional cleanup)
  Future<void> deleteOldRecords(String userId, DateTime before) async {
    final db = await database;
    await db.delete(
      'game_history',
      where: 'user_id = ? AND completed_at < ?',
      whereArgs: [userId, before.toIso8601String()],
    );
  }

  Future<void> insertTestResult(TestResult result) async {
    final db = await database;
    await db.insert(
      'test_results',
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all unsynced test results
  Future<List<TestResult>> getUnsyncedTestResults(String userId) async {
    final db = await database;
    final maps = await db.query(
      'test_results',
      where: 'user_id = ? AND is_synced = ?',
      whereArgs: [userId, 0],
    );
    return maps.map((map) => TestResult.fromMap(map)).toList();
  }

  // Get all test results for user
  Future<List<TestResult>> getTestResults(String userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'test_results',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'completed_at DESC',
      );
      return maps.map((map) => TestResult.fromMap(map)).toList();
    } catch (e) {
      print('Error getting test results: $e');
      return [];
    }
  }

  // Get test results by type
  Future<List<TestResult>> getTestResultsByType(
    String userId,
    String testType,
  ) async {
    final db = await database;
    final maps = await db.query(
      'test_results',
      where: 'user_id = ? AND test_type = ?',
      whereArgs: [userId, testType],
      orderBy: 'completed_at DESC',
    );
    return maps.map((map) => TestResult.fromMap(map)).toList();
  }

  // Mark test results as synced
  Future<void> markTestResultsAsSynced(List<String> ids) async {
    final db = await database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        'test_results',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  // Get user settings
  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    final db = await database;
    final maps = await db.query(
      'user_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  // Save user settings locally
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    final db = await database;
    await db.insert(
      'user_settings',
      settings,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add to LocalDatabase class
  Future<void> debugPrintAllData() async {
    final db = await database;

    final gameHistory = await db.query('game_history');
    print('=== GAME HISTORY (${gameHistory.length} records) ===');
    for (var row in gameHistory) {
      print(row);
    }

    final testResults = await db.query('test_results');
    print('=== TEST RESULTS (${testResults.length} records) ===');
    for (var row in testResults) {
      print(row);
    }
  }
}

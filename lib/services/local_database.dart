// services/local_database.dart
import 'package:kulaidoverse/games/game_history.dart';
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

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'kulaidoverse.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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

        // Index for faster queries
        await db.execute('''
          CREATE INDEX idx_user_id ON game_history(user_id)
        ''');
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

  // Get all records for user (for history screen)
  Future<List<GameHistory>> getGameHistory(String userId) async {
    final db = await database;
    final maps = await db.query(
      'game_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );
    return maps.map((map) => GameHistory.fromMap(map)).toList();
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
}

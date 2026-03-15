// services/sync_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kulaidoverse/games/game_history.dart';
import 'package:kulaidoverse/testing/test_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'local_database.dart';

class SyncService {
  final LocalDatabase _localDb = LocalDatabase();
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  // Check if online
  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Save game result (handles both online and offline)
  Future<void> saveGameResult({
    required String userId,
    required String gameType,
    required int stageReached,
    required int score,
    required double accuracy,
  }) async {
    final history = GameHistory(
      id: _uuid.v4(),
      userId: userId,
      gameType: gameType,
      stageReached: stageReached,
      score: score,
      accuracy: accuracy,
      completedAt: DateTime.now(),
      isSynced: false,
    );

    // 1. Always save locally first
    await _localDb.insertGameHistory(history);

    // 2. Try to sync immediately if online
    if (await isOnline()) {
      await _syncSingleRecord(history);
    }
  }

  // Sync a single record to Supabase
  Future<void> _syncSingleRecord(GameHistory history) async {
    try {
      await _supabase.from('game_history').insert(history.toSupabaseJson());
      await _localDb.markAsSynced([history.id]);
    } catch (e) {
      print('Failed to sync record: $e');
      // Will remain unsynced and picked up by batch sync later
    }
  }

  // Sync all pending records (call this when app comes online)
  Future<void> syncPendingRecords(String userId) async {
    if (!await isOnline()) return;

    final unsynced = await _localDb.getUnsyncedRecords(userId);
    if (unsynced.isEmpty) return;

    final syncedIds = <String>[];

    for (final record in unsynced) {
      try {
        await _supabase.from('game_history').insert(record.toSupabaseJson());
        syncedIds.add(record.id);
      } catch (e) {
        print('Failed to sync record ${record.id}: $e');
        // Continue with next record
      }
    }

    if (syncedIds.isNotEmpty) {
      await _localDb.markAsSynced(syncedIds);
      print('Synced ${syncedIds.length} records');
    }
  }

  // Save test result (handles both online and offline)
  Future<void> saveTestResult({
    required String userId,
    required String testType,
    required double overallRating,
    required String overallStatus,
    required String recommendation,
  }) async {
    final result = TestResult(
      id: _uuid.v4(),
      userId: userId,
      testType: testType,
      overallRating: overallRating,
      overallStatus: overallStatus,
      recommendation: recommendation,
      completedAt: DateTime.now(),
      isSynced: false,
    );

    // 1. Always save locally first
    await _localDb.insertTestResult(result);

    // 2. Try to sync immediately if online
    if (await isOnline()) {
      await _syncSingleTestResult(result);
    }
  }

  // Sync a single test result to Supabase
  Future<void> _syncSingleTestResult(TestResult result) async {
    try {
      await _supabase.from('test_results').insert(result.toSupabaseJson());
      await _localDb.markTestResultsAsSynced([result.id]);
    } catch (e) {
      print('Failed to sync test result: $e');
    }
  }

  // Sync all pending test results
  Future<void> syncPendingTestResults(String userId) async {
    if (!await isOnline()) return;

    final unsynced = await _localDb.getUnsyncedTestResults(userId);
    if (unsynced.isEmpty) return;

    final syncedIds = <String>[];

    for (final record in unsynced) {
      try {
        await _supabase.from('test_results').insert(record.toSupabaseJson());
        syncedIds.add(record.id);
      } catch (e) {
        print('Failed to sync test result ${record.id}: $e');
      }
    }

    if (syncedIds.isNotEmpty) {
      await _localDb.markTestResultsAsSynced(syncedIds);
      print('Synced ${syncedIds.length} test results');
    }
  }

  // Combined sync for both games and tests
  Future<void> syncAllPendingData(String userId) async {
    await syncPendingRecords(userId); // Game history
    await syncPendingTestResults(userId); // Test results
  }

  // Updated auto-sync to handle both
  void startAutoSync(String userId) {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        print('Connection restored, syncing all data...');
        await syncAllPendingData(userId);
      }
    });
  }

  // Sync user settings to Supabase
  Future<void> syncUserSettings(String userId) async {
    if (!await isOnline()) return;

    final settings = await _localDb.getUserSettings(userId);
    if (settings == null) return;
    if (settings['is_synced'] == 1) return;

    try {
      await _supabase.from('user_settings').upsert({
        'user_id': userId,
        'camera_quality': settings['camera_quality'],
        'updated_at': settings['updated_at'],
      });

      // Mark as synced
      await _localDb.saveUserSettings({...settings, 'is_synced': 1});

      print('User settings synced');
    } catch (e) {
      print('Failed to sync user settings: $e');
    }
  }
}

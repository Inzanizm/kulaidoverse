// services/sync_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kulaidoverse/games/game_history.dart';
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

  // Listen to connectivity changes and auto-sync
  void startAutoSync(String userId) {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        print('Connection restored, syncing...');
        await syncPendingRecords(userId);
      }
    });
  }
}

// lib/game_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:kulaidoverse/services/local_database.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class GameStatsScreen extends StatefulWidget {
  const GameStatsScreen({super.key});

  @override
  State<GameStatsScreen> createState() => _GameStatsScreenState();
}

class GameStatsScreenState {
  final int totalGamesPlayed;
  final Map<String, GameStat> gameStats;

  GameStatsScreenState({
    required this.totalGamesPlayed,
    required this.gameStats,
  });
}

class GameStat {
  final int gamesPlayed;
  final int highScore;
  final int? highStage;
  final double? bestAccuracy;

  GameStat({
    required this.gamesPlayed,
    required this.highScore,
    this.highStage,
    this.bestAccuracy,
  });
}

class _GameStatsScreenState extends State<GameStatsScreen> {
  final LocalDatabase _localDb = LocalDatabase();
  final SyncService _syncService = SyncService();
  bool _isLoading = true;
  bool _isOnline = false;
  GameStatsScreenState? _stats;

  // Game configurations with logo image paths
  final List<Map<String, dynamic>> _games = [
    {
      'key': 'hue hunt',
      'name': 'Hue Hunt',
      'logo': 'assets/game_logos/huehunt_dark.png',
      'color': Colors.black,
    },
    {
      'key': 'tone trail',
      'name': 'Tone Trail',
      'logo': 'assets/game_logos/tonetrail_dark.png',
      'color': Colors.black,
    },
    {
      'key': 'hue the impostor',
      'name': 'Hue the Impostor',
      'logo': 'assets/game_logos/huetheimpostor_dark.png',
      'color': Colors.black,
    },
    {
      'key': 'color mixing lab',
      'name': 'Color Mixing Lab',
      'logo': 'assets/game_logos/colormixinglab_dark.png',
      'color': Colors.black,
    },
    {
      'key': 'huellision',
      'name': 'Huellision',
      'logo': '',
      'color': Colors.black,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    try {
      List<Map<String, dynamic>> results;

      if (_isOnline) {
        // Online: Try to sync first, then fetch from Supabase
        try {
          await _syncService.syncPendingRecords(user.id);
        } catch (e) {
          debugPrint('Sync failed, will use local data: $e');
        }

        try {
          final response = await Supabase.instance.client
              .from('game_history')
              .select()
              .eq('user_id', user.id);
          results = List<Map<String, dynamic>>.from(response);
        } catch (e) {
          debugPrint('Supabase fetch failed, falling back to local: $e');
          // Fall back to local if Supabase query fails
          final localHistory = await _localDb.getGameHistory(user.id);
          results = localHistory.map((h) => h.toMap()).toList();
        }
      } else {
        // Offline: Only fetch from local SQLite database
        debugPrint('Offline mode: Fetching from local database');
        final localHistory = await _localDb.getGameHistory(user.id);
        results = localHistory.map((h) => h.toMap()).toList();
        debugPrint('Found ${results.length} local records');
      }

      // Calculate stats per game type
      Map<String, List<Map<String, dynamic>>> groupedResults = {};
      for (var result in results) {
        final gameType = result['game_type'] as String?;
        if (gameType != null) {
          groupedResults.putIfAbsent(gameType, () => []);
          groupedResults[gameType]!.add(result);
        }
      }

      // Build game stats
      Map<String, GameStat> gameStats = {};
      int totalGames = 0;

      for (var game in _games) {
        final key = game['key'] as String;
        final gameResults = groupedResults[key] ?? [];

        int gamesPlayed = gameResults.length;
        totalGames += gamesPlayed;

        int highScore = 0;
        int? highStage;
        double? bestAccuracy;

        for (var result in gameResults) {
          final score = (result['score'] as num?)?.toInt() ?? 0;
          if (score > highScore) {
            highScore = score;
          }

          final stage = (result['stage_reached'] as num?)?.toInt();
          if (stage != null && (highStage == null || stage > highStage)) {
            highStage = stage;
          }

          final accuracy = (result['accuracy'] as num?)?.toDouble();
          if (accuracy != null &&
              (bestAccuracy == null || accuracy > bestAccuracy)) {
            bestAccuracy = accuracy;
          }
        }

        gameStats[key] = GameStat(
          gamesPlayed: gamesPlayed,
          highScore: highScore,
          highStage: highStage,
          bestAccuracy: bestAccuracy,
        );
      }

      setState(() {
        _stats = GameStatsScreenState(
          totalGamesPlayed: totalGames,
          gameStats: gameStats,
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Game Stats',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTotalGamesCard(),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Game Performance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._games.map((game) {
                        final key = game['key'] as String;
                        final stat = _stats?.gameStats[key];
                        return _buildGameCard(
                          name: game['name'] as String,
                          logoPath: game['logo'] as String,
                          color: game['color'] as Color,
                          stat: stat,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTotalGamesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.videogame_asset, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            _isOnline ? 'Total Games Played' : 'Total Games (Offline)',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${_stats?.totalGamesPlayed ?? 0}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!_isOnline) ...[
            const SizedBox(height: 8),
            const Text(
              'Some stats may be pending sync',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String name,
    required String logoPath,
    required Color color,
    required GameStat? stat,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Game Logo Image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    logoPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return Icon(
                        Icons.sports_esports_rounded,
                        color: color,
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (stat?.gamesPlayed ?? 0) > 0 ? color : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Times Played: ${stat?.gamesPlayed ?? 0}',
                  style: TextStyle(
                    color:
                        (stat?.gamesPlayed ?? 0) > 0
                            ? Colors.white
                            : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stat != null && stat.gamesPlayed > 0) ...[
            Row(
              children: [
                _buildStatItem(
                  label: 'High Score',
                  value: stat.highScore.toString(),
                  icon: Icons.emoji_events,
                ),
                if (stat.highStage != null) ...[
                  const SizedBox(width: 12),
                  _buildStatItem(
                    label: 'Best Stage',
                    value: stat.highStage.toString(),
                    icon: Icons.flag,
                  ),
                ],
                if (stat.bestAccuracy != null) ...[
                  const SizedBox(width: 12),
                  _buildStatItem(
                    label: 'Best Accuracy',
                    value: '${stat.bestAccuracy!.toStringAsFixed(1)}%',
                    icon: Icons.gps_fixed,
                  ),
                ],
              ],
            ),
          ] else ...[
            Center(
              child: Text(
                'No games played yet',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

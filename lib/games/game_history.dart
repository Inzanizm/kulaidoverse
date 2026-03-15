class GameHistory {
  final String id;
  final String userId;
  final String gameType; // 'huellision', 'other_game', etc.
  final int stageReached;
  final int score;
  final double accuracy;
  final DateTime completedAt;
  final bool isSynced; // Track sync status

  GameHistory({
    required this.id,
    required this.userId,
    required this.gameType,
    required this.stageReached,
    required this.score,
    required this.accuracy,
    required this.completedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'game_type': gameType,
      'stage_reached': stageReached,
      'score': score,
      'accuracy': accuracy,
      'completed_at': completedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory GameHistory.fromMap(Map<String, dynamic> map) {
    return GameHistory(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      gameType: map['game_type'] as String,
      stageReached: (map['stage_reached'] as num).toInt(),
      score: (map['score'] as num).toInt(),
      accuracy: (map['accuracy'] as num).toDouble(),
      completedAt: DateTime.parse(map['completed_at'] as String),
      isSynced: map['is_synced'] == 1,
    );
  }

  // For Supabase (snake_case)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'game_type': gameType,
      'stage_reached': stageReached,
      'score': score,
      'accuracy': accuracy,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}

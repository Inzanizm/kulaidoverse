class TestResult {
  final String id;
  final String userId;
  final String testType; // 'ishihara', 'd15', 'hrr', 'mosaic', etc.
  final double overallRating; // 0-100 percentage
  final String overallStatus; // 'Normal', 'Mild', 'Moderate', 'Severe'
  final String recommendation;
  final DateTime completedAt;
  final bool isSynced;

  TestResult({
    required this.id,
    required this.userId,
    required this.testType,
    required this.overallRating,
    required this.overallStatus,
    required this.recommendation,
    required this.completedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'test_type': testType,
      'overall_rating': overallRating,
      'overall_status': overallStatus,
      'recommendation': recommendation,
      'completed_at': completedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'],
      userId: map['user_id'],
      testType: map['test_type'],
      overallRating: map['overall_rating'],
      overallStatus: map['overall_status'],
      recommendation: map['recommendation'],
      completedAt: DateTime.parse(map['completed_at']),
      isSynced: map['is_synced'] == 1,
    );
  }

  // For Supabase (snake_case)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'test_type': testType,
      'overall_rating': overallRating,
      'overall_status': overallStatus,
      'recommendation': recommendation,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}

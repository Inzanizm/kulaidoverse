// lib/testing_results_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulaidoverse/services/local_database.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:kulaidoverse/testing/test_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TestingResultsScreen extends StatefulWidget {
  const TestingResultsScreen({super.key});

  @override
  State<TestingResultsScreen> createState() => _TestingResultsScreenState();
}

class _TestingResultsScreenState extends State<TestingResultsScreen> {
  final LocalDatabase _localDb = LocalDatabase();
  final SyncService _syncService = SyncService();

  bool _isLoading = true;
  bool _isOnline = false;

  // Pagination
  static const int _itemsPerPage = 5;
  int _currentPage = 0;
  List<TestResult> _allResults = [];
  List<TestResult> _filteredResults = [];

  // Filter
  String? _selectedTestType;
  final List<String> _testTypes = [
    'All',
    'ishihara',
    'd15',
    'hrr',
    'mosaic',
    'lantern',
  ];

  // Sort
  String _sortBy = 'completed_at';
  bool _sortAscending = false;
  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Date (Newest)', 'value': 'completed_at', 'ascending': false},
    {'label': 'Date (Oldest)', 'value': 'completed_at', 'ascending': true},
    {'label': 'Test Type (A-Z)', 'value': 'test_type', 'ascending': true},
    {'label': 'Test Type (Z-A)', 'value': 'test_type', 'ascending': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    try {
      List<TestResult> results;

      if (_isOnline) {
        // Try to sync first
        try {
          await _syncService.syncPendingTestResults(user.id);
        } catch (e) {
          debugPrint('Test sync failed: $e');
        }

        // Fetch from Supabase
        try {
          final response = await Supabase.instance.client
              .from('test_results')
              .select()
              .eq('user_id', user.id)
              .order('completed_at', ascending: false);

          results =
              (response as List)
                  .map(
                    (json) => TestResult(
                      id: json['id'],
                      userId: json['user_id'],
                      testType: json['test_type'],
                      overallRating: (json['overall_rating'] as num).toDouble(),
                      overallStatus: json['overall_status'],
                      recommendation: json['recommendation'],
                      completedAt: DateTime.parse(json['completed_at']),
                      isSynced: true,
                    ),
                  )
                  .toList();
        } catch (e) {
          debugPrint('Supabase fetch failed, using local: $e');
          results = await _localDb.getTestResults(user.id);
        }
      } else {
        // Offline: use local only
        results = await _localDb.getTestResults(user.id);
      }

      setState(() {
        _allResults = results;
        _applyFilterAndSort();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading test results: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilterAndSort() {
    // Filter
    if (_selectedTestType != null && _selectedTestType != 'All') {
      _filteredResults =
          _allResults.where((r) => r.testType == _selectedTestType).toList();
    } else {
      _filteredResults = List.from(_allResults);
    }

    // Sort
    _filteredResults.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'test_type':
          comparison = a.testType.compareTo(b.testType);
          break;
        case 'completed_at':
        default:
          comparison = a.completedAt.compareTo(b.completedAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    // Reset to first page when filter/sort changes
    _currentPage = 0;
  }

  List<TestResult> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    if (startIndex >= _filteredResults.length) return [];
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      _filteredResults.length,
    );
    return _filteredResults.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredResults.length / _itemsPerPage).ceil();

  String _formatTestType(String testType) {
    switch (testType) {
      case 'ishihara':
        return 'Ishihara Test';
      case 'd15':
        return 'D-15 Test';
      case 'hrr':
        return 'HRR Test';
      case 'mosaic':
        return 'Mosaic Test';
      case 'lantern':
        return 'Lantern Test';
      default:
        return testType
            .split(' ')
            .map((word) {
              if (word.isEmpty) return word;
              return word[0].toUpperCase() + word.substring(1);
            })
            .join(' ');
    }
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM d, y').format(dt);
  }

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
      case 'Normal Color Vision':
        return Colors.black;
      case 'Mild':
      case 'Mild Deficiency':
      case 'Mild Color Blindness':
        return Colors.black;
      case 'Moderate':
      case 'Moderate Deficiency':
      case 'Moderate Color Blindness':
        return Colors.black;
      case 'Severe':
      case 'Severe Deficiency':
      case 'Severe Color Blindness':
        return Colors.black;
      case 'Monochromacy':
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  IconData _getTestIcon(String testType) {
    switch (testType) {
      case 'ishihara':
        return Icons.remove_red_eye;
      case 'd15':
        return Icons.view_agenda;
      case 'hrr':
        return Icons.bubble_chart;
      case 'mosaic':
        return Icons.grid_on;
      case 'lantern':
        return Icons.circle;
      default:
        return Icons.assignment;
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
          'Testing Results',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Filter and Sort Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Test Type Filter
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTestType ?? 'All',
                                isExpanded: true,
                                icon: const Icon(Icons.filter_list, size: 20),
                                items:
                                    _testTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type == 'All'
                                              ? 'All Tests'
                                              : _formatTestType(type),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTestType = value;
                                    _applyFilterAndSort();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Sort Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                isExpanded: true,
                                icon: const Icon(Icons.sort, size: 20),
                                value: _sortOptions.firstWhere(
                                  (opt) =>
                                      opt['value'] == _sortBy &&
                                      opt['ascending'] == _sortAscending,
                                  orElse: () => _sortOptions[0],
                                ),
                                items:
                                    _sortOptions.map((option) {
                                      return DropdownMenuItem(
                                        value: option,
                                        child: Text(
                                          option['label'],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _sortBy = value['value'];
                                      _sortAscending = value['ascending'];
                                      _applyFilterAndSort();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredResults.length} results',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (_totalPages > 0)
                          Text(
                            'Page ${_currentPage + 1} of $_totalPages',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // List (1 column, max 5 items)
                  Expanded(
                    child:
                        _filteredResults.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No test results yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Complete a color vision test to see results here',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _currentPageItems.length,
                              itemBuilder: (context, index) {
                                final result = _currentPageItems[index];
                                return _buildResultCard(result);
                              },
                            ),
                  ),

                  // Pagination - Icon buttons with rounded borders
                  if (_totalPages > 1)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Previous button
                            Material(
                              color:
                                  _currentPage > 0
                                      ? Colors.black
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap:
                                    _currentPage > 0
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color:
                                        _currentPage > 0
                                            ? Colors.white
                                            : Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_currentPage + 1} / $_totalPages',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Next button
                            Material(
                              color:
                                  _currentPage < _totalPages - 1
                                      ? Colors.black
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap:
                                    _currentPage < _totalPages - 1
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color:
                                        _currentPage < _totalPages - 1
                                            ? Colors.white
                                            : Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildResultCard(TestResult result) {
    final color = _getStatusColor(result.overallStatus);
    final testColor = _getTestColor(result.testType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Test Type + Sync Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: testColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTestIcon(result.testType),
                    color: testColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatTestType(result.testType),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!result.isSynced)
                  Icon(Icons.sync_problem, size: 18, color: Colors.orange[600]),
              ],
            ),
            const Divider(height: 20),

            // Rating and Status Row
            Row(
              children: [
                // Rating
                Expanded(
                  child: _buildInfoRow(
                    'Rating',
                    '${result.overallRating.toStringAsFixed(1)}%',
                    Icons.score,
                    Colors.black,
                  ),
                ),
                // Status
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: color, size: 10),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            result.overallStatus,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recommendation
            _buildInfoRow(
              'Recommendation',
              result.recommendation,
              Icons.lightbulb_outline,
              Colors.black,
            ),
            const SizedBox(height: 12),

            // Date & Time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  _formatDateTime(result.completedAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  _formatTime(result.completedAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTestColor(String testType) {
    switch (testType) {
      case 'ishihara':
        return Colors.black;
      case 'd15':
        return Colors.black;
      case 'hrr':
        return Colors.black;
      case 'mosaic':
        return Colors.black;
      case 'lantern':
        return Colors.black;
      default:
        return Colors.black;
    }
  }
}

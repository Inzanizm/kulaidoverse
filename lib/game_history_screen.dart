// lib/game_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulaidoverse/games/game_history.dart';
import 'package:kulaidoverse/services/local_database.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  final LocalDatabase _localDb = LocalDatabase();
  final SyncService _syncService = SyncService();

  bool _isLoading = true;
  bool _isOnline = false;

  // Pagination
  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  List<GameHistory> _allHistory = [];
  List<GameHistory> _filteredHistory = [];

  // Filter
  String? _selectedGameType;
  final List<String> _gameTypes = [
    'All',
    'hue hunt',
    'tone trail',
    'hue the impostor',
    'color mixing lab',
    'huellision',
  ];

  // Sort
  String _sortBy = 'completed_at';
  bool _sortAscending = false;
  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Date (Newest)', 'value': 'completed_at', 'ascending': false},
    {'label': 'Date (Oldest)', 'value': 'completed_at', 'ascending': true},
    {'label': 'Game Type (A-Z)', 'value': 'game_type', 'ascending': true},
    {'label': 'Game Type (Z-A)', 'value': 'game_type', 'ascending': false},
    {'label': 'Stage (Low-High)', 'value': 'stage_reached', 'ascending': true},
    {'label': 'Stage (High-Low)', 'value': 'stage_reached', 'ascending': false},
    {'label': 'Score (Low-High)', 'value': 'score', 'ascending': true},
    {'label': 'Score (High-Low)', 'value': 'score', 'ascending': false},
    {'label': 'Accuracy (Low-High)', 'value': 'accuracy', 'ascending': true},
    {'label': 'Accuracy (High-Low)', 'value': 'accuracy', 'ascending': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Ensure database is initialized
    await _localDb.ensureInitialized();

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    try {
      List<GameHistory> history;

      if (_isOnline) {
        // Try to sync first
        try {
          await _syncService.syncPendingRecords(user.id);
        } catch (e) {
          debugPrint('Sync failed: $e');
        }

        // Fetch from Supabase
        try {
          final response = await Supabase.instance.client
              .from('game_history')
              .select()
              .eq('user_id', user.id)
              .order('completed_at', ascending: false);

          history =
              (response as List)
                  .map(
                    (json) => GameHistory(
                      id: json['id'],
                      userId: json['user_id'],
                      gameType: json['game_type'],
                      stageReached: json['stage_reached'],
                      score: json['score'],
                      accuracy: (json['accuracy'] as num).toDouble(),
                      completedAt: DateTime.parse(json['completed_at']),
                      isSynced: true,
                    ),
                  )
                  .toList();
        } catch (e) {
          debugPrint('Supabase fetch failed, using local: $e');
          history = await _localDb.getGameHistory(user.id);
        }
      } else {
        // Offline: use local only
        history = await _localDb.getGameHistory(user.id);
      }

      setState(() {
        _allHistory = history;
        _applyFilterAndSort();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilterAndSort() {
    // Filter
    if (_selectedGameType != null && _selectedGameType != 'All') {
      _filteredHistory =
          _allHistory.where((h) => h.gameType == _selectedGameType).toList();
    } else {
      _filteredHistory = List.from(_allHistory);
    }

    // Sort
    _filteredHistory.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'game_type':
          comparison = a.gameType.compareTo(b.gameType);
          break;
        case 'stage_reached':
          comparison = a.stageReached.compareTo(b.stageReached);
          break;
        case 'score':
          comparison = a.score.compareTo(b.score);
          break;
        case 'accuracy':
          comparison = a.accuracy.compareTo(b.accuracy);
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

  List<GameHistory> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    if (startIndex >= _filteredHistory.length) return [];
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      _filteredHistory.length,
    );
    return _filteredHistory.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredHistory.length / _itemsPerPage).ceil();

  String _formatGameType(String gameType) {
    return gameType
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM d, y').format(dt);
  }

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  // Get logo path for each game type
  String _getGameLogoPath(String gameType) {
    switch (gameType) {
      case 'hue hunt':
        return 'assets/game_logos/huehunt_dark.png';
      case 'tone trail':
        return 'assets/game_logos/tonetrail_dark.png';
      case 'hue the impostor':
        return 'assets/game_logos/huetheimpostor_dark.png';
      case 'color mixing lab':
        return 'assets/game_logos/colormixinglab_dark.png';
      case 'huellision':
        return '';
      default:
        return 'assets/game_logos/huehunt_logo.png';
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
          'Game History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Removed wifi icon from actions
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
                        // Game Type Filter
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
                                value: _selectedGameType ?? 'All',
                                isExpanded: true,
                                icon: const Icon(Icons.filter_list, size: 20),
                                items:
                                    _gameTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type == 'All'
                                              ? 'All Games'
                                              : _formatGameType(type),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGameType = value;
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
                          '${_filteredHistory.length} games',
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

                  // Grid
                  Expanded(
                    child:
                        _filteredHistory.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No game history yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.85,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _currentPageItems.length,
                              itemBuilder: (context, index) {
                                final game = _currentPageItems[index];
                                return _buildHistoryCard(game);
                              },
                            ),
                  ),

                  // Pagination - Updated with rectangular rounded icon buttons
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
                            // Previous button - rectangular with rounded corners
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
                            // Next button - rectangular with rounded corners
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

  Widget _buildHistoryCard(GameHistory game) {
    final color = _getGameColor(game.gameType);
    final logoPath = _getGameLogoPath(game.gameType);
    final isHuellision = game.gameType == 'huellision';

    return Container(
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Type Header with Logo
            Row(
              children: [
                // Logo container with colored background
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      isHuellision
                          ? Icon(
                            Icons.sports_esports_rounded,
                            color: Colors.black,
                            size: 24,
                          )
                          : ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0, // Red channel (grayscale)
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0, // Green channel (grayscale)
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0, // Blue channel (grayscale)
                              0, 0, 0, 1, 0, // Alpha channel
                            ]),
                            child: Image.asset(logoPath, fit: BoxFit.contain),
                          ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatGameType(game.gameType),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!game.isSynced)
                  Icon(Icons.sync_problem, size: 16, color: Colors.orange[600]),
              ],
            ),
            const Divider(height: 16),

            // Stats
            _buildStatRow('Stage', '${game.stageReached}'),
            const SizedBox(height: 6),
            _buildStatRow('Score', '${game.score}'),
            const SizedBox(height: 6),
            _buildStatRow('Accuracy', '${game.accuracy.toStringAsFixed(1)}%'),

            const Spacer(),

            // Date & Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(game.completedAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTime(game.completedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _getGameColor(String gameType) {
    switch (gameType) {
      case 'hue hunt':
        return Colors.black;
      case 'tone trail':
        return Colors.black;
      case 'hue the impostor':
        return Colors.black;
      case 'color mixing lab':
        return Colors.black;
      case 'huellision':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}

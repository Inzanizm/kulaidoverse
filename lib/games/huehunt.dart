import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
/*
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
 */

enum Intensity { easy, medium, hard }

enum ColorblindType { normal, protanopia, deuteranopia, tritanopia }

class Huehunt extends StatefulWidget {
  const Huehunt({super.key});

  @override
  State<Huehunt> createState() => _HuehuntState();
}

class _HuehuntState extends State<Huehunt> {
  final SyncService _syncService = SyncService();
  // ───── GAME STATE ─────
  late List<Color> _colors;
  List<int> _revealed = [];
  List<int> _matched = [];
  bool _memorizing = true;
  bool _paused = false;

  Timer? _timer;
  int _timeLeft = 0;
  int _stage = 1;
  Intensity _currentIntensity = Intensity.easy;

  // ───── PERFORMANCE TRACKING ─────
  int _easyCompleted = 0;
  int _mediumCompleted = 0;
  int _hardCompleted = 0;
  int _attempts = 0;
  int _totalScore = 0;
  int _totalAttempts = 0; // Total across all stages
  int _totalMatches = 0; // Total successful matches across all stages

  // ───── SETTINGS ─────
  bool _soundFX = true;
  bool _music = true;
  final ColorblindType _userColorblindType =
      ColorblindType.normal; // Default, can be pulled from DB later

  /*final AudioCache _audioCache = AudioCache(prefix: 'assets/sounds/');
  AudioPlayer? _musicPlayer;*/

  @override
  void initState() {
    super.initState();
    _startStage();
    /*if (_music) {
      _playMusic();
    }*/
  }

  /*Future<void> _playMusic() async {
    _musicPlayer = AudioPlayer();
    await _musicPlayer!.setReleaseMode(ReleaseMode.loop); // Loop the music
    await _musicPlayer!.play(AssetSource('sounds/background.mp3'));
  }

  Future<void> _stopMusic() async {
    await _musicPlayer?.stop();
  }*/

  // ───── STAGE LOGIC ─────
  /// ───── START STAGE ─────
  void _startStage() {
    _timer?.cancel();
    _matched.clear();
    _revealed.clear();
    _memorizing = true;

    _currentIntensity = _getIntensity(_stage);
    _colors = _generateColors(_currentIntensity, _stage, _userColorblindType);
    _timeLeft = _calculateTime(_currentIntensity, _stage);

    // Show all cards for memorization
    _revealed = List.generate(_colors.length, (i) => i);
    if (mounted) setState(() {});

    // Memorization fade-out based on intensity
    Future.delayed(Duration(seconds: _memorizationTime()), () {
      if (!mounted) return;

      switch (_currentIntensity) {
        case Intensity.easy:
          _revealed.clear(); // Remove all at once
          break;

        case Intensity.medium:
          // Remove gradually
          for (int i = 0; i < _colors.length; i++) {
            Future.delayed(Duration(milliseconds: i * 100), () {
              if (!mounted) return;
              setState(() {
                if (_revealed.isNotEmpty) {
                  _revealed.removeLast();
                }
              });
            });
          }
          break;

        case Intensity.hard:
          // Remove quickly and randomly
          _revealed.shuffle();
          for (int i = 0; i < _colors.length; i++) {
            Future.delayed(Duration(milliseconds: i * 70), () {
              if (!mounted) return;
              setState(() {
                if (_revealed.isNotEmpty) {
                  _revealed.removeLast();
                }
              });
            });
          }
          break;
      }

      _memorizing = false;
      if (mounted) _startTimer();
      setState(() {});
    });
  }

  Intensity _getIntensity(int stage) {
    if (stage <= 5) return Intensity.easy;
    if (stage <= 12) return Intensity.medium;
    return Intensity.hard;
  }

  /// ───── GRID & CARD GENERATION ─────
  List<Color> _generateColors(
    Intensity intensity,
    int stage,
    ColorblindType type,
  ) {
    int pairs;

    switch (intensity) {
      case Intensity.easy:
        pairs = stage <= 5 ? 4 : 6;
        break;
      case Intensity.medium:
        pairs = stage <= 12 ? 6 : 8;
        break;
      case Intensity.hard:
        pairs = stage <= 20 ? 8 : 12;
        break;
    }

    List<Color> colors = [];

    // ✅ Generate matching pairs
    for (int i = 0; i < pairs; i++) {
      Color base = Colors.primaries[i % Colors.primaries.length];

      if (intensity == Intensity.medium) {
        base = base.withGreen((base.green + 50) % 255);
      }

      if (intensity == Intensity.hard) {
        base = base.withGreen((base.green + 20) % 255);
      }

      base = _adjustForColorblindness(base, type);

      colors.add(base);
      colors.add(base);
    }

    // ✅ Balance grid with distractor cards
    int cross = _getCrossAxisCount();
    int rows = (colors.length / cross).ceil();
    int totalSlots = rows * cross;

    final random = Random();

    while (colors.length < totalSlots) {
      Color distractor;

      do {
        distractor = Color.fromARGB(
          255,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );

        distractor = _adjustForColorblindness(distractor, type);
      } while (colors.contains(distractor) || // avoid matching any pair
          distractor.computeLuminance() >
              0.85 // avoid very light colors
              );

      colors.add(distractor);
    }

    colors.shuffle();
    return colors;
  }

  Color _adjustForColorblindness(Color color, ColorblindType type) {
    switch (type) {
      case ColorblindType.protanopia: // red-blind
        return Color.fromARGB(
          color.alpha,
          (color.red * 0.567 + color.green * 0.433).toInt(),
          color.green,
          color.blue,
        );
      case ColorblindType.deuteranopia: // green-blind
        return Color.fromARGB(
          color.alpha,
          color.red,
          (color.red * 0.558 + color.green * 0.442).toInt(),
          color.blue,
        );
      case ColorblindType.tritanopia: // blue-blind
        return Color.fromARGB(
          color.alpha,
          color.red,
          color.green,
          (color.red * 0.042 + color.blue * 0.958).toInt(),
        );
      case ColorblindType.normal:
      default:
        return color;
    }
  }

  int _getCrossAxisCount() {
    switch (_currentIntensity) {
      case Intensity.easy:
        return 3; // always 3 columns for easy
      case Intensity.medium:
        return 4;
      case Intensity.hard:
        return 4;
    }
  }

  int _memorizationTime() {
    switch (_currentIntensity) {
      case Intensity.easy:
        return _stage <= 5 ? 3 : 4;

      case Intensity.medium:
        return _stage <= 10 ? 5 : 6;

      case Intensity.hard:
        return _stage <= 20 ? 7 : 8;
    }
  }

  int _calculateTime(Intensity intensity, int stage) {
    switch (intensity) {
      case Intensity.easy:
        return 30;
      case Intensity.medium:
        return 55;
      case Intensity.hard:
        return 80;
    }
  }

  // ───── TIMER ─────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_paused) return;
      if (_timeLeft == 0) {
        timer.cancel();
        _showGameOver();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  // ───── CARD TAP LOGIC ─────
  void _onCardTap(int index) {
    if (_memorizing || _paused) return;
    if (_revealed.contains(index) || _matched.contains(index)) return;

    // prevent tapping more than 2 cards
    if (_revealed.length >= 2) return;

    setState(() => _revealed.add(index));

    if (_revealed.length == 2) {
      _attempts++;
      _totalAttempts++;

      final a = _revealed[0];
      final b = _revealed[1];

      if (_colors[a] == _colors[b]) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          setState(() {
            _matched.addAll(_revealed);
            _totalMatches++;
            _revealed.clear();
          });

          _checkStageComplete();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() => _revealed.clear());
        });
      }
    }
  }

  // Total accuracy across all stages
  double _totalAccuracy() {
    if (_totalAttempts == 0) return 100.0;
    return min(100, (_totalMatches / _totalAttempts) * 100);
  }

  void _checkStageComplete() {
    Map<Color, int> counts = {};
    for (var c in _colors) {
      counts[c] = (counts[c] ?? 0) + 1;
    }

    int realCards = counts.values.where((v) => v > 1).fold(0, (a, b) => a + b);

    if (_matched.length == realCards) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        _showStageComplete();
      });
    }
  }

  double _currentAccuracy() {
    if (_attempts == 0) return 100;
    return min(100, ((_matched.length / 2) / _attempts) * 100);
  }

  bool _canAccessMedium() => _easyCompleted >= 5 && _currentAccuracy() >= 70;
  bool _canAccessHard() => _mediumCompleted >= 5 && _currentAccuracy() >= 75;

  // ───── STAGE COMPLETION DIALOG ─────
  void _showStageComplete() {
    double accuracy = _currentAccuracy();
    int stageScore = (_matched.length * 100) + (_timeLeft * 10);
    if (accuracy >= 80 &&
        _timeLeft > (_calculateTime(_currentIntensity, _stage) * 0.3)) {
      stageScore += 200; // consistency bonus
    }
    _totalScore += stageScore;

    if (_currentIntensity == Intensity.easy) _easyCompleted++;
    if (_currentIntensity == Intensity.medium) _mediumCompleted++;
    if (_currentIntensity == Intensity.hard) _hardCompleted++;

    _timer?.cancel();
    setState(() => _paused = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// ───── TITLE ─────
                      const Center(
                        child: Text(
                          "Stage Complete!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// ───── STAGE INFO ─────
                      Center(
                        child: Text(
                          "Stage $_stage",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ───── STATS ─────
                      Text(
                        "Accuracy: ${accuracy.toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Time Remaining: ${_formatTime(_timeLeft)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Score: $stageScore",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 24),

                      /// ───── ACTION BUTTONS ─────
                      Row(
                        children: [
                          // Retry Stage (LEFT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                _restartStage();
                              },
                              child: const Text(
                                "Retry",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Next Stage (RIGHT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                _nextStageConfirmed();
                              },
                              child: const Text(
                                "Next Stage",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _nextStageConfirmed() {
    _timer?.cancel();

    setState(() {
      _stage++;
      _attempts = 0;
      _revealed.clear();
      _matched.clear();
      _paused = false;
      _memorizing = true;
    });

    _startStage();
  }

  double _calculateUserAccuracy() {
    if (_attempts == 0) return 0.0; // avoid division by zero
    return (_matched.length / _attempts) * 100;
  }

  void _restartStage() {
    _timer?.cancel();

    setState(() {
      _paused = false;
      _attempts = 0;
      _matched.clear();
      _revealed.clear();
      _memorizing = true;
    });

    // regenerate current stage
    _currentIntensity = _getIntensity(_stage);
    _colors = _generateColors(_currentIntensity, _stage, _userColorblindType);
    _timeLeft = _calculateTime(_currentIntensity, _stage);

    // show cards for memorization
    _revealed = List.generate(_colors.length, (i) => i);
    setState(() {});

    Future.delayed(Duration(seconds: _memorizationTime()), () {
      if (!mounted) return;

      _revealed.clear();
      _memorizing = false;

      if (!_paused) _startTimer();
      setState(() {});
    });
  }

  void _showUnlockRequirement(
    String intensity,
    double requiredAccuracy,
    double currentAccuracy,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// ───── TITLE ─────
                  Center(
                    child: Text(
                      "$intensity Stage Locked",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ───── MESSAGE ─────
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: "You need "),
                          TextSpan(
                            text: "${requiredAccuracy.toStringAsFixed(0)}%",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: " accuracy in previous stages to unlock ",
                          ),
                          TextSpan(
                            text: "$intensity.\n",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: "Your current accuracy is "),
                          TextSpan(
                            text: "${currentAccuracy.toStringAsFixed(0)}%",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: "."),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ───── ACTION BUTTON ─────
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _restartGame(); // close dialog
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showGameOver() {
    _timer?.cancel();
    setState(() => _paused = true);

    // Calculate TOTAL accuracy (not stage accuracy)
    final totalAccuracy = _totalAccuracy();

    _saveGameResult(); // This will now save total accuracy

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// ───── TITLE ─────
                      const Center(
                        child: Text(
                          "Time's Up!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ───── MESSAGE ─────
                      Text(
                        "You reached Stage $_stage\n"
                        "Total Accuracy: ${totalAccuracy.toStringAsFixed(1)}%\n" // CHANGED: Total accuracy
                        "Total Score: $_totalScore",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ───── ACTION BUTTONS ─────
                      Row(
                        children: [
                          // Quit button (LEFT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Quit",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Restart button (RIGHT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _restartStage();
                              },
                              child: const Text(
                                "Retry Stage",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Future<void> _saveGameResult() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Use TOTAL accuracy, not stage accuracy
    final totalAccuracy = _totalAccuracy();

    await _syncService.saveGameResult(
      userId: user.id,
      gameType: 'hue hunt',
      stageReached: _stage,
      score: _totalScore,
      accuracy: totalAccuracy, // CHANGED: Now saves total accuracy
    );

    print(
      'Game saved! Stage: $_stage, Score: $_totalScore, Total Accuracy: ${totalAccuracy.toStringAsFixed(1)}%',
    );
  }

  void _restartGame() {
    // Cancel any running timer
    _timer?.cancel();

    setState(() {
      // Reset core game state
      _paused = false; // unpause
      _stage = 1;
      _totalScore = 0;
      _easyCompleted = 0;
      _mediumCompleted = 0;
      _hardCompleted = 0;
      _attempts = 0;
      _totalAttempts = 0;
      _totalMatches = 0;

      // Reset board state
      _matched.clear();
      _revealed.clear();
      _memorizing = true;

      // Reset intensity, colors, and timer for stage 1
      _currentIntensity = _getIntensity(_stage);
      _colors = _generateColors(_currentIntensity, _stage, _userColorblindType);
      _timeLeft = _calculateTime(_currentIntensity, _stage);

      // Show all cards briefly for memorization
      _revealed = List.generate(_colors.length, (i) => i);
    });

    if (mounted) setState(() {}); // trigger UI update

    // Memorization fade-out
    Future.delayed(Duration(seconds: _memorizationTime()), () {
      if (!mounted) return;
      _revealed.clear();
      _memorizing = false;
      _startTimer();
      setState(() {});
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _confirmExitGame() {
    _timer?.cancel();
    setState(() => _paused = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// ───── TITLE ─────
                      const Center(
                        child: Text(
                          "Quit Game?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ───── MESSAGE ─────
                      const Center(
                        child: Text(
                          "Are you sure you want to quit?\nYour current progress will be lost.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ───── ACTION BUTTONS ─────
                      Row(
                        children: [
                          // Quit Button (LEFT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                Navigator.pop(context); // exit game
                              },
                              child: const Text(
                                "Quit",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Cancel Button (RIGHT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                _resumeGame();
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _confirmRestartGame() {
    _timer?.cancel();
    setState(() => _paused = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// ───── TITLE ─────
                      const Center(
                        child: Text(
                          "Restart Game?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ───── MESSAGE ─────
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Are you sure you want to restart the game?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight
                                        .w600, // slightly bolder for emphasis
                                height: 1.5, // more breathing room
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8), // space between lines
                            Text(
                              "All progress will be reset and the game will start from Stage 1.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ───── ACTION BUTTONS ─────
                      Row(
                        children: [
                          // Restart Button (LEFT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                _restartGame(); // reset everything
                              },
                              child: const Text(
                                "Restart",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Cancel Button (RIGHT)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                _resumeGame();
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  // ───── UI ─────
  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      // Add generic type <Object?>
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // New callback with result parameter
        if (didPop) return;
        _confirmExitGame();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 40, 50, 56),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _confirmExitGame,
              ),
            ),
          ),
          centerTitle: true,
          title: Column(
            children: [
              Image.asset('assets/logo/LogoKly.png', width: 28, height: 28),
              const SizedBox(height: 4),
              const Text(
                "KULAIDOVERSE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            const SizedBox(width: 4),

            // INFO BUTTON
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF283238),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                iconSize: 18,
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () async {
                  setState(() => _paused = true);
                  _timer?.cancel();

                  await showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("How to Play Hue Hunt"),
                          content: const Text(
                            "1. Memorize the colors.\n"
                            "2. Tap to match pairs.\n"
                            "3. Complete stages before the timer runs out.\n"
                            "4. Accuracy affects your score",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                  );

                  if (!_memorizing) _startTimer();
                  setState(() => _paused = false);
                },
              ),
            ),

            // PAUSE BUTTON
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF283238),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                iconSize: 18,
                icon: const Icon(Icons.pause, color: Colors.white),
                onPressed: _showPauseMenu,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ───── TITLE ─────
              const SizedBox(height: 24),
              const Text(
                "Hue-Hunt",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              /// ───── STAGE INFO ─────
              Text(
                "Stage $_stage",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              /// ───── PROGRESS BAR ─────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_stage % 10) / 10, // loops every 10 stages
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// ───── REMAINING TIME ─────
              Text(
                "Remaining Time: ${_formatTime(_timeLeft)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _colors.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          _currentIntensity == Intensity.hard ? 4 : 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (_, index) {
                      final visible =
                          _revealed.contains(index) || _matched.contains(index);
                      return GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: visible ? _colors[index] : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black, // color of the border
                              width: 2, // thickness of the border
                            ),
                          ),
                          child:
                              visible
                                  ? null
                                  : Center(
                                    child: Image.asset(
                                      'assets/logo/LogoKly.png',
                                      width: 24,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseMenu() {
    if (_paused) return;

    setState(() => _paused = true);
    _timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ───── TITLE ─────
                        const Center(
                          child: Text(
                            "Game Paused",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// ───── GAME INFO ─────
                        Text(
                          "Stage: $_stage",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Attempts: $_attempts",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Remaining Time: ${_formatTime(_timeLeft)}",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 20),

                        /// ───── ACTION BUTTONS ─────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// Resume Game
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _resumeGame();
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text(
                                "Resume",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            /// Retry Stage (primary)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _restartStage(); // retry current stage
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text(
                                "Retry Stage",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            /// Restart Game (secondary, with confirmation)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.black54,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmRestartGame();
                              },
                              icon: const Icon(Icons.restart_alt),
                              label: const Text(
                                "Restart Game",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _resumeGame() {
    setState(() => _paused = false);
    _startTimer(); // make sure your timer restarts properly
  }
}

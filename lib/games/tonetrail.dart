import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class Tonetrail extends StatefulWidget {
  const Tonetrail({super.key});

  @override
  State<Tonetrail> createState() => _TonetrailState();
}

enum Difficulty { easy, medium, hard }

class _TonetrailState extends State<Tonetrail> {
  int _stage = 1;
  int _totalScore = 0;

  int _totalAttempts = 0;
  int _correctPlacements = 0;

  double _accuracy = 0;
  Timer? _timer;
  int _timeLeft = 0;

  bool _paused = false;

  List<Color> correctOrder = [];
  late List<Color> draggableColors;
  List<Color?> slots = [];

  Difficulty _difficulty = Difficulty.easy;

  String currentColorName = "";

  Difficulty _getDifficulty() {
    if (_stage <= 5) return Difficulty.easy;
    if (_stage <= 12) return Difficulty.medium;
    return Difficulty.hard;
  }

  String _getIntensity(double saturation, double lightStart, double lightEnd) {
    double avgLight = (lightStart + lightEnd) / 2;

    if (saturation > 0.75 && avgLight > 0.6) return "Vivid";
    if (saturation > 0.7 && avgLight <= 0.6) return "Deep";
    if (saturation <= 0.65 && avgLight > 0.6) return "Soft";
    return "Muted";
  }

  String _getHueName(double hue) {
    hue = hue % 360;

    if (hue < 15 || hue >= 345) return "Red";
    if (hue < 45) return "Red-Orange";
    if (hue < 75) return "Orange";
    if (hue < 105) return "Yellow";
    if (hue < 135) return "Yellow-Green";
    if (hue < 165) return "Green";
    if (hue < 195) return "Blue-Green";
    if (hue < 225) return "Cyan";
    if (hue < 255) return "Blue";
    if (hue < 285) return "Blue-Violet";
    if (hue < 315) return "Violet";
    return "Red-Violet";
  }

  int _getTimeLimit() {
    switch (_difficulty) {
      case Difficulty.easy:
        return 15;
      case Difficulty.medium:
        return 20;
      case Difficulty.hard:
        return 30;
    }
  }

  final Map<Difficulty, Set<int>> _usedHueGroups = {
    Difficulty.easy: {},
    Difficulty.medium: {},
    Difficulty.hard: {},
  };

  void _startTimer({bool reset = true}) {
    _timer?.cancel(); // stop previous timer

    if (reset) {
      _timeLeft = _getTimeLimit(); // only reset if needed
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
        _onTimeUp();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onTimeUp() {
    _timer?.cancel();
    setState(() => _paused = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              final screenWidth = MediaQuery.of(context).size.width;

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.45, // better width for landscape
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// TITLE
                        const Center(
                          child: Text(
                            "Time's Up!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// MESSAGE
                        Text(
                          "You reached Stage $_stage\n"
                          "Accuracy: ${_currentAccuracy().toStringAsFixed(1)}%\n"
                          "Total Score: $_totalScore",
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 26),

                        /// BUTTONS
                        Row(
                          children: [
                            /// Quit
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  // Return to landscape when quitting
                                  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.landscapeLeft,
                                    DeviceOrientation.landscapeRight,
                                  ]);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Quit",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// Retry
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  resetGame(); // or _restartStage()
                                },
                                child: const Text(
                                  "Retry Stage",
                                  style: TextStyle(
                                    fontSize: 15,
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
                ),
              );
            },
          ),
    );
  }

  // 🎯 Determine tile count per stage
  int getTileCount() {
    if (_stage <= 5) return 4; // Easy
    if (_stage <= 12) return 6; // Medium
    if (_stage <= 20) return 8; // Hard
    return 9; // Master
  }

  // 🎨 Generate gradient dynamically
  List<Color> generateGradient(int count) {
    final random = Random();

    // Divide 360 degrees into 12 hue families
    const int hueStep = 30; // 360 / 12
    int maxGroups = 12;

    // Reset used hues when player levels up difficulty
    if (_usedHueGroups[_difficulty]!.length >= maxGroups) {
      _usedHueGroups[_difficulty]!.clear();
    }

    // Pick unused hue family
    int hueGroup;
    do {
      hueGroup = random.nextInt(maxGroups);
    } while (_usedHueGroups[_difficulty]!.contains(hueGroup));

    _usedHueGroups[_difficulty]!.add(hueGroup);

    double baseHue = hueGroup * hueStep.toDouble();

    switch (_difficulty) {
      case Difficulty.easy:
        return _generateSingleTone(baseHue, count);

      case Difficulty.medium:
        return _generateTwoTone(baseHue, count);

      case Difficulty.hard:
        return _generateThreeTone(baseHue, count);
    }
  }

  List<Color> _generateSingleTone(double hue, int count) {
    double saturation = 0.8;
    double lightStart = 0.35;
    double lightEnd = 0.75;

    String hueName = _getHueName(hue);

    // Simple single-tone description
    currentColorName = "Dark $hueName to Light $hueName";

    return List.generate(count, (i) {
      double t = i / (count - 1);
      double lightness = lightStart + (lightEnd - lightStart) * t;

      return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
    });
  }

  List<Color> _generateTwoTone(double hue, int count) {
    double secondHue = (hue + 25) % 360;

    double saturation = 0.7;
    double lightStart = 0.45;
    double lightEnd = 0.75;

    String startName = _getHueName(hue);
    String endName = _getHueName(secondHue);

    // Simple two-tone description
    currentColorName = "$startName to $endName";

    return List.generate(count, (i) {
      double t = i / (count - 1);
      double blendedHue = hue + (secondHue - hue) * t;
      double lightness = lightStart + (lightEnd - lightStart) * t;

      return HSLColor.fromAHSL(
        1.0,
        blendedHue,
        saturation,
        lightness,
      ).toColor();
    });
  }

  List<Color> _generateThreeTone(double hue, int count) {
    double secondHue = (hue + 20) % 360;
    double thirdHue = (hue - 20 + 360) % 360;

    double saturation = 0.65;
    double lightStart = 0.50;
    double lightEnd = 0.70;

    String firstName = _getHueName(thirdHue);
    String midName = _getHueName(hue);
    String lastName = _getHueName(secondHue);

    // Simple three-tone description
    currentColorName = "$firstName to $midName to $lastName";

    return List.generate(count, (i) {
      double t = i / (count - 1);

      double blendedHue;
      if (t < 0.5) {
        blendedHue = thirdHue + (hue - thirdHue) * (t * 2);
      } else {
        blendedHue = hue + (secondHue - hue) * ((t - 0.5) * 2);
      }

      double lightness = lightStart + (lightEnd - lightStart) * t;

      return HSLColor.fromAHSL(
        1.0,
        blendedHue,
        saturation,
        lightness,
      ).toColor();
    });
  }

  // ─── Pre-calculate tile size at stage load ───
  double getTileSize(double maxWidth) {
    final tileCount = slots.length;
    const cardHorizontalPadding = 10 * 2; // card padding horizontal
    const minTile = 32.0;
    const maxTile = 52.0;

    // reduce spacing slightly for larger tile counts
    double spacing = tileCount > 6 ? 6.0 : 8.0;

    double size =
        (maxWidth - cardHorizontalPadding - (spacing * (tileCount - 1))) /
        tileCount;
    return size.clamp(minTile, maxTile);
  }

  // 🔄 Load stage setup
  void _loadStage() {
    _difficulty = _getDifficulty();
    int count = getTileCount();

    correctOrder = generateGradient(count);
    draggableColors = List<Color>.from(correctOrder);
    draggableColors.shuffle();
    slots = List<Color?>.filled(count, null);

    _startTimer(reset: true); // reset for new stage

    setState(() {});
  }

  // ✅ Check arrangement
  OverlayEntry? _currentSnackBarEntry;

  double _currentAccuracy() {
    if (_totalAttempts == 0) return 0;
    return (_correctPlacements / _totalAttempts) * 100;
  }

  void checkAnswer() {
    if (slots.contains(null)) {
      _showCustomSnackBar(message: "Fill all slots first", color: Colors.grey);
      return;
    }

    int correctCount = 0;

    for (int i = 0; i < slots.length; i++) {
      _totalAttempts++;

      if (slots[i] == correctOrder[i]) {
        correctCount++;
        _correctPlacements++;
      }
    }

    if (correctCount == slots.length) {
      _showStageComplete();
    } else {
      _showGameOver();
    }
  }

  /// 🔹 Custom snackbar for nicer UI
  void _showCustomSnackBar({
    required String message,
    required Color color,
    int duration = 1200,
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Remove any existing snackbar overlay
    _currentSnackBarEntry?.remove();

    _currentSnackBarEntry = OverlayEntry(
      builder:
          (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(_currentSnackBarEntry!);

    // Remove after duration
    Future.delayed(Duration(milliseconds: duration), () {
      _currentSnackBarEntry?.remove();
      _currentSnackBarEntry = null;
    });
  }

  void _showGameOver() {
    _timer?.cancel();
    setState(() => _paused = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              final screenWidth = MediaQuery.of(context).size.width;

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.45, // better width for landscape
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// TITLE
                        const Center(
                          child: Text(
                            "Game Over!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// MESSAGE
                        Text(
                          "You reached Stage $_stage\n"
                          "Accuracy: ${_currentAccuracy().toStringAsFixed(1)}%\n"
                          "Total Score: $_totalScore",
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 26),

                        /// BUTTONS
                        Row(
                          children: [
                            /// Quit
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// Retry
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  resetGame(); // or _restartStage()
                                },
                                child: const Text(
                                  "Retry Stage",
                                  style: TextStyle(
                                    fontSize: 15,
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
                ),
              );
            },
          ),
    );
  }

  void _showStageComplete() {
    double accuracy = _currentAccuracy();

    int stageScore = 0;

    // base score
    stageScore += slots.length * 100;

    // time bonus
    stageScore += _timeLeft * 10;

    // accuracy bonus
    if (accuracy >= 90) {
      stageScore += 200;
    } else if (accuracy >= 75) {
      stageScore += 100;
    }

    _totalScore += stageScore;

    _timer?.cancel();
    setState(() => _paused = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              final screenWidth = MediaQuery.of(context).size.width;

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.45, // landscape-friendly width
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// TITLE
                        const Center(
                          child: Text(
                            "Stage Complete!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// STAGE INFO
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
                          "Score: $stageScore",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "Time Remaining: ${_formatTime(_timeLeft)}",
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 24),

                        /// BUTTONS
                        Row(
                          children: [
                            /// Retry
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _resetGame();
                                },
                                child: const Text(
                                  "Retry Stage",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            /// Next Stage
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);

                                  setState(() {
                                    _stage++;
                                    _paused = false;
                                  });

                                  _loadStage();
                                },
                                child: const Text(
                                  "Next Stage",
                                  style: TextStyle(
                                    fontSize: 15,
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
                ),
              );
            },
          ),
    );
  }

  void _resetGame() {
    // Stop any running timer
    _timer?.cancel();

    setState(() {
      _paused = false; // ensure game is not paused
      _stage = 1; // reset to stage 1
      slots = List<Color?>.filled(slots.length, null); // reset slots
      draggableColors.clear(); // clear draggable colors
    });

    // Reload stage 1 properly
    _loadStage();

    // Start timer after state is updated
    _startTimer(reset: true);
  }

  void _confirmRestartGame() {
    // Pause the timer
    _timer?.cancel();
    setState(() => _paused = true);

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
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 360, // max width for larger screens
                ),
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
                    const Center(
                      child: Text(
                        "Are you sure you want to restart the game?\nAll progress will be reset and the game will start from Stage 1.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.black87,
                        ),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // close dialog
                              _resetGame(); // reset everything
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // close dialog
                              _startTimer(
                                reset: false,
                              ); // resume timer instead of resetting
                              setState(() => _paused = false);
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
            ),
          ),
    );
  }

  /// ───── CONFIRM EXIT GAME ─────
  void _confirmExitGame() {
    // Pause the timer
    _timer?.cancel();
    setState(() => _paused = true);

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
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400, // maximum width for large screens
                ),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // close dialog
                              _startTimer(
                                reset: false,
                              ); // resume timer instead of resetting
                              setState(() => _paused = false);
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
            ),
          ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void resetGame() {
    _timer?.cancel();

    setState(() {
      _paused = false; // important: allow pause button to work
      for (int i = 0; i < slots.length; i++) {
        if (slots[i] != null) {
          draggableColors.add(slots[i]!);
          slots[i] = null;
        }
      }
      draggableColors.shuffle();
    });

    _startTimer(reset: true); // retrying stage → reset timer
  }

  void _resumeGame() {
    setState(() => _paused = false);
    _startTimer(); // make sure your timer restarts properly
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadStage();
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
        backgroundColor: const Color(0xFFEDEDED),

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          toolbarHeight: 70,
          centerTitle: true,

          /// BACK BUTTON
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF283238),
                borderRadius: BorderRadius.circular(12),
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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: _confirmExitGame,
              ),
            ),
          ),

          /// TITLE
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo/LogoKly.png', width: 28, height: 28),
              const SizedBox(width: 6),
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

          /// INFO + PAUSE
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF283238),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                iconSize: 20,
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () async {
                  setState(() => _paused = true);
                  _timer?.cancel();

                  await showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: const Text("How to Play Tone Trail"),
                          content: const Text(
                            "1. Arrange the tones from lightest to darkest.\n\n"
                            "2. Fill all empty slots before checking.\n\n"
                            "3. Complete the gradient before time runs out.\n\n"
                            "4. Stages become harder as tones get closer.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Got it"),
                            ),
                          ],
                        ),
                  );

                  if (!_paused) return;
                  _startTimer();
                  setState(() => _paused = false);
                },
              ),
            ),

            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF283238),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                iconSize: 20,
                icon: const Icon(Icons.pause, color: Colors.white),
                onPressed: _openSettingsMenu,
              ),
            ),
          ],
        ),

        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      /// TITLE
                      const SizedBox(height: 10),
                      const Text(
                        "Tone Trail",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// STAGE
                      Text(
                        "Stage $_stage",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// PROGRESS BAR
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_stage % 10) / 10,
                            minHeight: 10,
                            backgroundColor: Colors.grey[300],
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// TIMER
                      Text(
                        "Remaining Time: ${_formatTime(_timeLeft)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// GAME CONTAINER
                      Center(
                        child: Container(
                          width:
                              constraints.maxWidth > 700
                                  ? 600
                                  : constraints.maxWidth * 0.9,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2E35),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            children: [
                              /// COLOR NAME
                              Text(
                                currentColorName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 14),

                              /// ─── DROP SLOTS (click-to-place) ───
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(slots.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Remove color from slot back to palette
                                      if (slots[index] != null) {
                                        setState(() {
                                          draggableColors.add(slots[index]!);
                                          slots[index] = null;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color:
                                            slots[index] ??
                                            Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 16),

                              /// ─── COLOR PALETTE (click to place) ───
                              if (draggableColors.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 14,
                                    runSpacing: 14,
                                    children:
                                        draggableColors.map((color) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                // Find first empty slot
                                                final emptyIndex = slots
                                                    .indexOf(null);
                                                if (emptyIndex != -1) {
                                                  slots[emptyIndex] = color;
                                                  draggableColors.remove(color);
                                                } else {
                                                  // Optionally show snackbar if all slots are filled
                                                  _showCustomSnackBar(
                                                    message:
                                                        "All slots are already filled!",
                                                    color: Colors.grey,
                                                  );
                                                }
                                              });
                                            },
                                            child: colorTile(color),
                                          );
                                        }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              /// SUBMIT BUTTON
                              SizedBox(
                                width: 160,
                                child: ElevatedButton(
                                  onPressed: checkAnswer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Submit"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget colorTile(Color color, {bool dragging = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow:
            dragging
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
      ),
    );
  }

  void _openSettingsMenu() {
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
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 380, // limit width for wide screens
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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

                          const SizedBox(height: 18),

                          /// ───── GAME STATS ─────
                          Text(
                            "Stage: $_stage",
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Accuracy: ${_currentAccuracy().toStringAsFixed(1)}%",
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Remaining Time: ${_formatTime(_timeLeft)}",
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 22),

                          /// ───── ACCESSIBILITY ─────
                          const Text(
                            "Accessibility",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          /// ───── AUDIO ─────
                          const Text(
                            "Audio",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          const SizedBox(height: 22),

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
                                  _startTimer(
                                    reset: false,
                                  ); // resume timer instead of resetting
                                  setState(() => _paused = false);
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

                              /// Retry Stage
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
                                  resetGame(); // retry current stage
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

                              /// Restart Game (confirmation)
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
                ),
              );
            },
          ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _timer?.cancel();
    super.dispose();
  }
}

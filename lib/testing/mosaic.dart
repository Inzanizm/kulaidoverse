import 'dart:math';
import 'package:flutter/material.dart';

class mosaic extends StatefulWidget {
  const mosaic({super.key});

  @override
  State<mosaic> createState() => _mosaicState();
}

enum MosaicTaskType {
  redGreen, // Protanopia test
  greenYellow, // Deuteranopia test
  tritan, // Tritanopia test - ADDED
}

class _StageData {
  final String type;
  final int maxErrors;
  int errors = 0;
  int correct = 0;
  int consecutiveMisses = 0;
  bool failed = false;
  bool completed = false;

  _StageData({required this.type, required this.maxErrors});
}

class DiagnosisResult {
  final String protanStatus;
  final String deutanStatus;
  final String tritanStatus; // ADDED
  final double protanScore;
  final double deutanScore;
  final double tritanScore; // ADDED
  final String recommendation;

  DiagnosisResult({
    required this.protanStatus,
    required this.deutanStatus,
    required this.tritanStatus, // ADDED
    required this.protanScore,
    required this.deutanScore,
    required this.tritanScore, // ADDED
    required this.recommendation,
  });
}

class _mosaicState extends State<mosaic> with SingleTickerProviderStateMixin {
  static const int gridSize = 12;
  static const int maxDifficulty = 20;

  final Random _random = Random();
  late AnimationController _controller;
  late List<double> _tilePhases;

  // Clinical diagnosis state
  late Map<int, _StageData> _stages;
  int _currentStage = 1;
  DiagnosisResult? _finalDiagnosis;

  // Your existing state
  int difficulty = 1;
  MosaicTaskType currentTask = MosaicTaskType.redGreen;
  int taskIndex = 0;
  Set<int> targetIndices = {};
  List<Color> tiles = [];
  bool testEnded = false;

  // Track correct taps per task
  final Map<MosaicTaskType, int> correctTapsMap = {
    MosaicTaskType.redGreen: 0,
    MosaicTaskType.greenYellow: 0,
    MosaicTaskType.tritan: 0, // ADDED
  };

  final Map<MosaicTaskType, int> totalRoundsMap = {
    MosaicTaskType.redGreen: 0,
    MosaicTaskType.greenYellow: 0,
    MosaicTaskType.tritan: 0, // ADDED
  };

  @override
  void initState() {
    super.initState();
    _initDiagnosisEngine();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
    _generateRound();
  }

  void _confirmExitGame() {
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
    );
  }

  void _initDiagnosisEngine() {
    _stages = {
      1: _StageData(type: 'redGreen', maxErrors: 2), // Protan test
      2: _StageData(type: 'greenYellow', maxErrors: 2), // Deutan test
      3: _StageData(type: 'tritan', maxErrors: 2), // Tritan test - ADDED
    };
    _currentStage = 1;
    _finalDiagnosis = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Set<int> _generate2x2Target() {
    final row = _random.nextInt(gridSize - 1);
    final col = _random.nextInt(gridSize - 1);
    final topLeft = row * gridSize + col;
    return {topLeft, topLeft + 1, topLeft + gridSize, topLeft + gridSize + 1};
  }

  void _generateRound() {
    targetIndices = _generate2x2Target();
    Color baseColor;
    Color targetColor;

    switch (currentTask) {
      case MosaicTaskType.redGreen:
        // Red-Green for Protanopia detection
        baseColor = const Color(0xff4caf50); // Green background
        targetColor = const Color(0xffe53935); // Red target
        break;
      case MosaicTaskType.greenYellow:
        // Green-Yellow for Deuteranopia detection
        baseColor = const Color(0xffffeb3b); // Yellow background
        targetColor = const Color(0xff4caf50); // Green target
        break;
      case MosaicTaskType.tritan: // ADDED
        // Purple-Blue for Tritanopia detection
        baseColor = const Color(0xffd16aff); // Purple background
        targetColor = const Color.fromARGB(255, 53, 65, 229); // Blue target
        break;
    }

    double blendFactor = difficulty / maxDifficulty;
    Color blendedTarget = Color.lerp(targetColor, baseColor, blendFactor)!;

    tiles = List.generate(gridSize * gridSize, (index) {
      return targetIndices.contains(index) ? blendedTarget : baseColor;
    });

    _tilePhases = List.generate(
      gridSize * gridSize,
      (_) => _random.nextDouble() * 2 * pi,
    );
  }

  // Handle tap on grid
  void _handleTap(int index) {
    if (testEnded) return;

    final stage = _stages[_currentStage]!;
    final isCorrect = targetIndices.contains(index);

    totalRoundsMap[currentTask] = totalRoundsMap[currentTask]! + 1;

    if (isCorrect) {
      // Correct tap
      stage.correct++;
      correctTapsMap[currentTask] = correctTapsMap[currentTask]! + 1;
      stage.consecutiveMisses = 0;

      if (difficulty >= maxDifficulty) {
        // Completed all 20 levels
        stage.completed = true;
        _processStageComplete();
      } else {
        // Continue to next level
        setState(() {
          difficulty++;
          _generateRound();
        });
      }
    } else {
      // Wrong tap - increment error
      _handleError();
    }
  }

  // Handle error (wrong tap or "I don't see")
  void _handleError() {
    final stage = _stages[_currentStage]!;

    stage.errors++;
    stage.consecutiveMisses++;

    // Check if max errors reached (2 errors = fail)
    if (stage.errors >= stage.maxErrors) {
      stage.failed = true;
      stage.completed = true;
      _processStageComplete();
      return;
    }

    // 2 consecutive misses = force progress to next level
    if (stage.consecutiveMisses >= 2) {
      stage.consecutiveMisses = 0;

      if (difficulty >= maxDifficulty) {
        // Completed all levels despite errors
        stage.completed = true;
        _processStageComplete();
      } else {
        // Force progress to next level
        setState(() {
          difficulty++;
          _generateRound();
        });
      }
      return;
    }

    // Stay on same level, allow retry
    setState(() {});
  }

  // "I don't see" button - skip to next mosaic
  void _skipRound() {
    if (testEnded) return;

    totalRoundsMap[currentTask] = totalRoundsMap[currentTask]! + 1;

    // Get current stage data
    final stage = _stages[_currentStage]!;

    // Count as an error for current stage
    stage.errors++;
    stage.consecutiveMisses++;

    // Check if max errors reached (2 errors = fail stage)
    if (stage.errors >= stage.maxErrors) {
      stage.failed = true;
    }

    // Mark current stage as completed (whether failed or not)
    stage.completed = true;

    // Move to next stage or end test
    if (_currentStage < 3) {
      // Move to next stage - errors reset automatically because it's a new _StageData
      _currentStage++;
      taskIndex = _currentStage - 1; // FIX: Use direct mapping
      currentTask = MosaicTaskType.values[taskIndex];
      difficulty = 1;
      _generateRound();
      setState(() {});
    } else {
      // Last mosaic
      _generateDiagnosis();
      _endTest();
    }
  }

  void _processStageComplete() {
    if (_currentStage < 3) {
      // Move to next stage
      _currentStage++;
      taskIndex =
          _currentStage - 1; // FIX: Use direct mapping instead of increment
      currentTask = MosaicTaskType.values[taskIndex];
      difficulty = 1;
      _generateRound();
      setState(() {});
    } else {
      // All stages complete
      _generateDiagnosis();
      _endTest();
    }
  }

  String _getSeverityFromScore(double score) {
    // Always produce a severity based on score
    if (score >= 88) {
      return 'Normal';
    } else if (score >= 70) {
      return 'Mild';
    } else if (score >= 50) {
      return 'Moderate';
    } else {
      return 'Severe';
    }
  }

  void _generateDiagnosis() {
    // Calculate scores - always produce a score even if 0
    double protanScore = _getScorePercent(MosaicTaskType.redGreen);
    double deutanScore = _getScorePercent(MosaicTaskType.greenYellow);
    double tritanScore = _getScorePercent(MosaicTaskType.tritan); // ADDED

    // Get severity based on percentage - always produces a status
    String protanStatus = _getSeverityFromScore(protanScore);
    String deutanStatus = _getSeverityFromScore(deutanScore);
    String tritanStatus = _getSeverityFromScore(tritanScore); // ADDED

    String recommendation;
    if (protanStatus == 'Normal' &&
        deutanStatus == 'Normal' &&
        tritanStatus == 'Normal') {
      // MODIFIED
      recommendation = 'Normal color vision. No restrictions.';
    } else if (protanStatus == 'Severe' ||
        deutanStatus == 'Severe' ||
        tritanStatus == 'Severe') {
      // MODIFIED
      recommendation =
          'Significant color vision deficiency. Occupational guidance recommended.';
    } else if (protanStatus == 'Moderate' ||
        deutanStatus == 'Moderate' ||
        tritanStatus == 'Moderate') {
      // MODIFIED
      recommendation =
          'Moderate deficiency. May have difficulty with color-critical tasks.';
    } else {
      recommendation = 'Mild deficiency. Monitor for changes.';
    }

    _finalDiagnosis = DiagnosisResult(
      protanStatus: protanStatus,
      deutanStatus: deutanStatus,
      tritanStatus: tritanStatus, // ADDED
      protanScore: protanScore,
      deutanScore: deutanScore,
      tritanScore: tritanScore, // ADDED
      recommendation: recommendation,
    );
  }

  void _endTest() {
    // Ensure diagnosis is generated before ending
    if (_finalDiagnosis == null) {
      _generateDiagnosis();
    }
    setState(() {
      testEnded = true;
    });
  }

  double _getProgress() => (difficulty - 1) / (maxDifficulty - 1);

  double _getScorePercent(MosaicTaskType task) {
    int total = totalRoundsMap[task] ?? 0;
    int correct = correctTapsMap[task] ?? 0;
    // Always calculate score, return 0 if no attempts
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  void _resetTest() {
    setState(() {
      difficulty = 1;
      taskIndex = 0;
      currentTask = MosaicTaskType.redGreen;
      testEnded = false;
      _initDiagnosisEngine();
      correctTapsMap.updateAll((key, value) => 0);
      totalRoundsMap.updateAll((key, value) => 0);
      _generateRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (testEnded) return _buildResultScreen();
    return _buildTestScreen();
  }

  Widget _buildTestScreen() {
    final stage = _stages[_currentStage]!;

    // ADDED: Get subtitle based on current stage
    String subtitle;
    switch (_currentStage) {
      case 1:
        subtitle = "Protanopia Test (Red-Green)";
        break;
      case 2:
        subtitle = "Deuteranopia Test (Green-Yellow)";
        break;
      case 3:
        subtitle = "Tritanopia Test (Purple-Blue)";
        break;
      default:
        subtitle = "";
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),

        /// 🔙 BACK BUTTON
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF283238),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: _confirmExitGame, // confirm before leaving
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

          /// ℹ️ INFO BUTTON
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF283238),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => const AlertDialog(
                        title: Text("How to Play"),
                        content: Text(
                          "Tap the circle that has a slightly different hue.\n"
                          "Avoid mistakes — you only have 5 lives.\n"
                          "Stages get harder as you progress.",
                        ),
                      ),
                );
              },
            ),
          ),

          /// ⏸ PAUSE BUTTON
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF283238),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              iconSize: 20,
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: "Settings",
              onPressed: () {}, // you can rename to _openSettingsMenu later
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2F3238),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "Mosaic ${taskIndex + 1} / 3", // CHANGED from / 2 to / 3
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle, // MODIFIED to use variable
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              // Error counter - shows current errors
              Text(
                "Errors: ${stage.errors} / ${stage.maxErrors}",
                style: TextStyle(
                  color: stage.errors >= 1 ? Colors.orange : Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double time = _controller.value * 2 * pi;
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gridSize * gridSize,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridSize,
                            ),
                        itemBuilder: (context, index) {
                          Color c = tiles[index];
                          double amplitude = 0.09;
                          double pulse =
                              1 + amplitude * sin(time + _tilePhases[index]);
                          int r = (c.red * pulse).clamp(0, 255).round();
                          int g = (c.green * pulse).clamp(0, 255).round();
                          int b = (c.blue * pulse).clamp(0, 255).round();
                          return GestureDetector(
                            onTap: () => _handleTap(index),
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              color: Color.fromARGB(255, r, g, b),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progress: ${(_getProgress() * 100).round()}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _getProgress(),
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.lightGreenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _skipRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    child: const Text("I don't see"),
                  ),
                  ElevatedButton(
                    onPressed: () {
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
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
                                    const Center(
                                      child: Text(
                                        "Are you sure you want to restart?\nYour current progress will be lost.",
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _resetTest();
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
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
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
                      );
                    },
                    child: const Text(
                      "Restart",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    // Safely get diagnosis - should always exist now
    final diagnosis =
        _finalDiagnosis ??
        DiagnosisResult(
          protanStatus: 'Unknown',
          deutanStatus: 'Unknown',
          tritanStatus: 'Unknown', // ADDED
          protanScore: 0,
          deutanScore: 0,
          tritanScore: 0, // ADDED
          recommendation: 'Test incomplete. Please restart.',
        );

    String protanDisplay =
        "${diagnosis.protanStatus} (${diagnosis.protanScore.toStringAsFixed(1)}%)";
    String deutanDisplay =
        "${diagnosis.deutanStatus} (${diagnosis.deutanScore.toStringAsFixed(1)}%)";
    String tritanDisplay =
        "${diagnosis.tritanStatus} (${diagnosis.tritanScore.toStringAsFixed(1)}%)"; // ADDED

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),

        /// 🔙 BACK BUTTON
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF283238),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: _confirmExitGame, // confirm before leaving
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

          /// ℹ️ INFO BUTTON
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF283238),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => const AlertDialog(
                        title: Text("How to Play"),
                        content: Text(
                          "Tap the circle that has a slightly different hue.\n"
                          "Avoid mistakes — you only have 5 lives.\n"
                          "Stages get harder as you progress.",
                        ),
                      ),
                );
              },
            ),
          ),

          /// ⏸ PAUSE BUTTON
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF283238),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              iconSize: 20,
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: "Settings",
              onPressed: () {}, // you can rename to _openSettingsMenu later
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Your Color Vision Test Results",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF3A3F4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Table(
                    border: TableBorder.all(color: Colors.white24, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFF2F3238)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "Test Type",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "Score",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Red-Green / Protan row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 237, 238, 238),
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              "Red-Green (Protan)",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              "${diagnosis.protanScore.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              diagnosis.protanStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Green-Yellow / Deutan row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 229, 229, 230),
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              "Green-Yellow (Deutan)",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              "${diagnosis.deutanScore.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              diagnosis.deutanStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Purple-Blue / Tritan row - ADDED
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 237, 238, 238),
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              "Purple-Blue (Tritan)",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              "${diagnosis.tritanScore.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Text(
                              diagnosis.tritanStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3F4B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Text(
                      "Protanopia: $protanDisplay",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Deuteranopia: $deutanDisplay",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // ADDED Tritan display
                    Text(
                      "Tritanopia: $tritanDisplay",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Recommendation:",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diagnosis.recommendation,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 58, 63, 75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Restart Test"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Quit"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

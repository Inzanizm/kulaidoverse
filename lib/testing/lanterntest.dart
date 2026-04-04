import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:kulaidoverse/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Lanterntest extends StatefulWidget {
  const Lanterntest({super.key});

  @override
  State<Lanterntest> createState() => _LanterntestState();
}

class _LanterntestState extends State<Lanterntest> {
  int currentStage = 0;
  String upAnswer = "";
  String downAnswer = "";
  bool showLanterns = true;

  final List<Map<String, String>> userAnswers = [];

  final List<Map<String, String>> stages = [
    {"up": "Green", "down": "Red"},
    {"up": "Blue", "down": "Green"},
    {"up": "Red", "down": "Blue"},
    {"up": "Green", "down": "Blue"},
    {"up": "Red", "down": "Green"},
    {"up": "Blue", "down": "Red"},
    {"up": "Green", "down": "Red"},
    {"up": "Blue", "down": "Green"},
    {"up": "Red", "down": "Blue"},
  ];

  final Map<String, Color> colorMap = {
    "Red": Colors.red,
    "Green": Colors.green,
    "Blue": Colors.blue,
  };

  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();
    _startStageTimer();
  }

  void _startStageTimer() {
    _stageTimer?.cancel();
    if (mounted) {
      setState(() {
        showLanterns = true;
        upAnswer = "";
        downAnswer = "";
      });
    }
    _stageTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        showLanterns = false;
      });
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }

  void _submitAnswer() {
    userAnswers.add({"up": upAnswer, "down": downAnswer});

    if (currentStage < stages.length - 1) {
      setState(() {
        currentStage++;
      });
      _startStageTimer();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => LanternResultScreen(
                stages: stages,
                userAnswers: userAnswers,
                onRestart: () {
                  // Pop the result screen first, then restart
                  Navigator.pop(context);
                  _restartTest();
                },
                onQuit: () => Navigator.pop(context),
              ),
        ),
      );
    }
  }

  void _restartTest() {
    setState(() {
      currentStage = 0;
      upAnswer = "";
      downAnswer = "";
      showLanterns = true;
      userAnswers.clear();
    });
    _startStageTimer();
  }

  void _confirmExitTest() {
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
                  const Center(
                    child: Text(
                      "Quit Test?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  Row(
                    children: [
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
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
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

  void _confirmRestartTest() {
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
                  const Center(
                    child: Text(
                      "Restart Test?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Are you sure you want to restart the test?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "All progress will be reset and the test will start from Stage 1.",
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
                  Row(
                    children: [
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
                            Navigator.pop(context);
                            _restartTest();
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
    final currentStageData = stages[currentStage];
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _confirmExitTest();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.3),
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.pureBlack,
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
                onPressed: _confirmExitTest,
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppTheme.pureBlack,
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
                icon: const Icon(Icons.question_mark, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/game_logos/lantern_tutorial.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppTheme.pureBlack,
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
                          title: Text("Disclaimer and Purpose"),
                          content: Text(
                            "Disclaimer:\n"
                            "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis. Results may vary depending on device display, brightness, and lighting conditions. For an accurate assessment, please consult a qualified eye care professional or ophthalmologist.\n\n"
                            "Purpose:\n"
                            "The Lantern Test assesses a person's ability to recognize and distinguish colored signal lights, usually red, green, and white. By identifying these lights correctly, the test helps determine whether an individual can reliably recognize colors used in transportation and safety signaling.",
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Lantern Test",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 350,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "${currentStage + 1}/${stages.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (showLanterns)
                        Column(
                          children: [
                            _lanternLight(colorMap[currentStageData['up']]!),
                            const SizedBox(height: 30),
                            _lanternLight(colorMap[currentStageData['down']]!),
                          ],
                        )
                      else
                        const SizedBox(height: 300),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: const Text(
                              "UP:",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          _colorButton("Red", true),
                          const SizedBox(width: 4),
                          _colorButton("Green", true),
                          const SizedBox(width: 4),
                          _colorButton("Blue", true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // DOWN Row - Aligned
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: const Text(
                              "DOWN:",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          _colorButton("Red", false),
                          const SizedBox(width: 4),
                          _colorButton("Green", false),
                          const SizedBox(width: 4),
                          _colorButton("Blue", false),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(
                                  color: Color(0xFF2F3238),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _confirmRestartTest,
                              child: const Text(
                                "Restart",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 140,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    showLanterns ? Colors.grey : Colors.white,
                                foregroundColor:
                                    showLanterns
                                        ? Colors.black38
                                        : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: showLanterns ? null : _submitAnswer,
                              child: const Text(
                                "Submit",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lanternLight(Color color) {
    return Container(
      width: 10,
      height: 135,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 7,
          ),
        ],
      ),
    );
  }

  Widget _colorButton(String text, bool isUp) {
    bool selected = isUp ? upAnswer == text : downAnswer == text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 34,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? const Color(0xFF2F3238) : Colors.white,
            foregroundColor: selected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            setState(() {
              if (isUp) {
                upAnswer = text;
              } else {
                downAnswer = text;
              }
            });
          },
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}

// ----------------- RESULTS SCREEN -----------------
// CONVERTED TO STATEFUL WIDGET TO HANDLE SAVING

class LanternResultScreen extends StatefulWidget {
  final List<Map<String, String>> stages;
  final List<Map<String, String>> userAnswers;
  final VoidCallback? onRestart;
  final VoidCallback? onQuit;

  const LanternResultScreen({
    super.key,
    required this.stages,
    required this.userAnswers,
    this.onRestart,
    this.onQuit,
  });

  @override
  State<LanternResultScreen> createState() => _LanternResultScreenState();
}

class _LanternResultScreenState extends State<LanternResultScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _saveTestResult();
  }

  Future<void> _saveTestResult() async {
    if (_isSaved) return; // Prevent duplicate saves

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final syncService = SyncService();

    // Calculate results (same logic as build method)
    int totalQuestions = widget.stages.length * 2;
    int correctCount = 0;

    for (int i = 0; i < widget.stages.length; i++) {
      final stage = widget.stages[i];
      final answer = widget.userAnswers[i];
      final upCorrect = stage['up']!;
      final downCorrect = stage['down']!;
      final upAnswer = answer['up'] ?? '-';
      final downAnswer = answer['down'] ?? '-';

      if (upAnswer == upCorrect) correctCount++;
      if (downAnswer == downCorrect) correctCount++;
    }

    double percentCorrect = (correctCount / totalQuestions) * 100;

    // Determine classification
    String classification;
    String recommendation;
    if (percentCorrect >= 80) {
      classification = "Normal Color Vision";
      recommendation =
          "Your color vision appears normal. No further action needed.";
    } else if (percentCorrect >= 50) {
      classification = "Mild Color Deficiency";
      recommendation =
          "You may have mild color vision deficiency. Consider consulting an eye care professional.";
    } else {
      classification = "Severe Color Deficiency";
      recommendation =
          "Significant color vision deficiency detected. We recommend scheduling an appointment with an ophthalmologist.";
    }

    await syncService.saveTestResult(
      userId: user.id,
      testType: 'lantern',
      overallRating: percentCorrect,
      overallStatus: classification,
      recommendation: recommendation,
    );

    setState(() {
      _isSaved = true;
    });

    print(
      'Lantern test saved! Rating: ${percentCorrect.toStringAsFixed(1)}%, Status: $classification',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate ratings (same as before)
    int totalQuestions = widget.stages.length * 2;
    int correctCount = 0;
    Map<String, int> colorCorrect = {"Red": 0, "Green": 0, "Blue": 0};
    Map<String, int> colorTotal = {"Red": 0, "Green": 0, "Blue": 0};

    for (int i = 0; i < widget.stages.length; i++) {
      final stage = widget.stages[i];
      final answer = widget.userAnswers[i];
      final upCorrect = stage['up']!;
      final downCorrect = stage['down']!;
      final upAnswer = answer['up'] ?? '-';
      final downAnswer = answer['down'] ?? '-';

      colorTotal[upCorrect] = (colorTotal[upCorrect] ?? 0) + 1;
      colorTotal[downCorrect] = (colorTotal[downCorrect] ?? 0) + 1;

      if (upAnswer == upCorrect) {
        correctCount++;
        colorCorrect[upCorrect] = (colorCorrect[upCorrect] ?? 0) + 1;
      }
      if (downAnswer == downCorrect) {
        correctCount++;
        colorCorrect[downCorrect] = (colorCorrect[downCorrect] ?? 0) + 1;
      }
    }

    double percentCorrect = (correctCount / totalQuestions) * 100;

    // Classification
    String classification;
    String recommendation;
    if (percentCorrect >= 80) {
      classification = "Normal Color Vision";
      recommendation =
          "Your color vision appears normal. No further action needed.";
    } else if (percentCorrect >= 50) {
      classification = "Mild Color Deficiency";
      recommendation =
          "You may have mild color vision deficiency. Consider consulting an eye care professional.";
    } else {
      classification = "Severe Color Deficiency";
      recommendation =
          "Significant color vision deficiency detected. We recommend scheduling an appointment with an ophthalmologist.";
    }

    String lanternDisplay =
        "$classification (${percentCorrect.toStringAsFixed(1)}%)";

    // Build detailed table rows
    List<TableRow> detailRows = [
      const TableRow(
        decoration: BoxDecoration(color: Color(0xFF2F3238)),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Stage",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Your Answer",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Correct",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ];

    for (int i = 0; i < widget.stages.length; i++) {
      final stage = widget.stages[i];
      final answer = widget.userAnswers[i];
      final upCorrect = stage['up']!;
      final downCorrect = stage['down']!;
      final upAnswer = answer['up'] ?? '-';
      final downAnswer = answer['down'] ?? '-';
      final upCorrectBool = upAnswer == upCorrect;
      final downCorrectBool = downAnswer == downCorrect;

      detailRows.add(
        TableRow(
          decoration: BoxDecoration(
            color:
                (upCorrectBool && downCorrectBool)
                    ? const Color.fromARGB(255, 237, 238, 238)
                    : const Color.fromARGB(255, 255, 235, 235),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${i + 1}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "UP: $upAnswer",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "DOWN: $downAnswer",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "UP: $upCorrect",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  Text(
                    "DOWN: $downCorrect",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.3),
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppTheme.pureBlack,
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
                          title: Text("Disclaimer and Purpose"),
                          content: Text(
                            "Disclaimer:\n"
                            "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis. Results may vary depending on device display, brightness, and lighting conditions. For an accurate assessment, please consult a qualified eye care professional or ophthalmologist.\n\n"
                            "Purpose:\n"
                            "The Lantern Test assesses a person's ability to recognize and distinguish colored signal lights, usually red, green, and white. By identifying these lights correctly, the test helps determine whether an individual can reliably recognize colors used in transportation and safety signaling.",
                          ),
                        ),
                  );
                },
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
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Summary Table
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
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
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
                                "Rating",
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
                                "Lantern Test",
                                style: TextStyle(
                                  color: Colors.black,
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
                                "${percentCorrect.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  color: Colors.black,
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
                                classification,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
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
                // Summary Box
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
                        "Lantern: $lanternDisplay",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Recommendation:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Color breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _colorStat(
                            "Red",
                            colorCorrect["Red"]!,
                            colorTotal["Red"]!,
                          ),
                          _colorStat(
                            "Green",
                            colorCorrect["Green"]!,
                            colorTotal["Green"]!,
                          ),
                          _colorStat(
                            "Blue",
                            colorCorrect["Blue"]!,
                            colorTotal["Blue"]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Detailed Results
                Card(
                  color: const Color(0xFF3A3F4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            "Detailed Results",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Table(
                          border: TableBorder.all(
                            color: Colors.white24,
                            width: 1,
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(1.5),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: detailRows,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Button Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onRestart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            58,
                            63,
                            75,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
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
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Color.fromARGB(255, 58, 63, 75),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Quit"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorStat(String color, int correct, int total) {
    return Column(
      children: [
        Text(
          color,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          "$correct/$total",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

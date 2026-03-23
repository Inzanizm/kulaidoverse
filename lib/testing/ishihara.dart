import 'package:flutter/material.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IshiharaScreen extends StatefulWidget {
  const IshiharaScreen({super.key});

  @override
  State<IshiharaScreen> createState() => _IshiharaScreenState();
}

class _IshiharaScreenState extends State<IshiharaScreen> {
  int currentStage = 0;
  String? selectedAnswer;
  bool showResults = false;

  final List<Map<String, dynamic>> stages = [
    {
      "image": "assets/logo/ishihara1.png",
      "correct": "1",
      "choices": ["4", "1", "3", "_"],
    },
    {
      "image": "assets/logo/ishihara11.png",
      "correct": "11",
      "choices": ["3", "8", "11", "_"],
    },
    {
      "image": "assets/logo/ishihara5.png",
      "correct": "5",
      "choices": ["5", "2", "13", "_"],
    },
    {
      "image": "assets/logo/ishihara12.png",
      "correct": "12",
      "choices": ["4", "12", "3", "_"],
    },
    {
      "image": "assets/logo/ishihara21.png",
      "correct": "21",
      "choices": ["21", "12", "64", "_"],
    },
    {
      "image": "assets/logo/ishihara6.png",
      "correct": "6",
      "choices": ["6", "9", "3", "_"],
    },
    {
      "image": "assets/logo/ishihara7.png",
      "correct": "7",
      "choices": ["4", "7", "10", "_"],
    },
    {
      "image": "assets/logo/ishihara67.png",
      "correct": "67",
      "choices": ["6", "7", "67", "_"],
    },
    {
      "image": "assets/logo/ishihara23.png",
      "correct": "23",
      "choices": ["28", "23", "19", "_"],
    },
    {
      "image": "assets/logo/ishihara3.png",
      "correct": "3",
      "choices": ["34", "14", "3", "_"],
    },
    {
      "image": "assets/logo/ishihara13.png",
      "correct": "13",
      "choices": ["17", "12", "13", "_"],
    },
    {
      "image": "assets/logo/ishihara69.png",
      "correct": "69",
      "choices": ["69", "68", "63", "_"],
    },
  ];

  late List<String?> userAnswers;
  int correctCount = 0;
  double percentCorrect = 0;
  String classification = "";
  String recommendation = "";

  @override
  void initState() {
    super.initState();
    userAnswers = List.generate(stages.length, (_) => null);
  }

  void _submitStage() {
    if (selectedAnswer == null) return;

    userAnswers[currentStage] = selectedAnswer;

    if (currentStage < stages.length - 1) {
      setState(() {
        currentStage++;
        selectedAnswer = userAnswers[currentStage];
      });
    } else {
      _calculateResults();
      setState(() {
        showResults = true;
      });
    }
  }

  void _calculateResults() {
    int totalStages = stages.length;
    correctCount = 0;

    for (int i = 0; i < stages.length; i++) {
      final userAnswer = userAnswers[i] ?? "-";
      final correctAnswer = stages[i]["correct"];
      if (userAnswer == correctAnswer) correctCount++;
    }

    percentCorrect = (correctCount / totalStages) * 100;

    // Determine classification and recommendation
    if (percentCorrect >= 80) {
      classification = "Normal Color Vision";
      recommendation =
          "Your color vision appears normal. No further action needed.";
    } else if (percentCorrect >= 50) {
      classification = "Mild Color Blindness";
      recommendation =
          "You may have mild color vision deficiency. Consider consulting an eye care professional for a comprehensive evaluation.";
    } else {
      classification = "Severe Color Blindness";
      recommendation =
          "Significant color vision deficiency detected. We recommend scheduling an appointment with an ophthalmologist for professional diagnosis and guidance.";
    }

    _saveTestResult();
  }

  void _resetTest() {
    setState(() {
      currentStage = 0;
      selectedAnswer = null;
      userAnswers = List.generate(stages.length, (_) => null);
      showResults = false;
      correctCount = 0;
      percentCorrect = 0;
      classification = "";
      recommendation = "";
    });
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
                  /// ───── TITLE ─────
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
                  /// ───── TITLE ─────
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

                  /// ───── MESSAGE ─────
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Are you sure you want to restart the test?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600, // slightly bolder for emphasis
                            height: 1.5, // more breathing room
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8), // space between lines
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
                            _resetTest(); // reset everything
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

  Widget _buildResultScreen() {
    String ishiharaDisplay =
        "$classification (${percentCorrect.toStringAsFixed(1)}%)";

    return PopScope<Object?>(
      // Add generic type <Object?>
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // New callback with result parameter
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),

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
                          title: Text("Disclaimer and Purpose"),
                          content: Text(
                            "Disclaimer:\n"
                            "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis. Results may vary depending on device display, brightness, and lighting conditions. For an accurate assessment, please consult a qualified eye care professional or ophthalmologist.\n\n"
                            "Purpose:\n"
                            "It is designed to screen for color vision deficiencies, particularly red–green color blindness, by asking users to identify numbers embedded within patterns of colored dots. The test evaluates how well a person can distinguish color differences that form the hidden numbers.",
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
                                "Ishihara Test",
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
                                "${percentCorrect.toStringAsFixed(1)}%",
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
                                classification,
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
                        "Ishihara: $ishiharaDisplay",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Detailed breakdown table
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
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Color(0xFF2F3238),
                              ),
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
                            ...List.generate(stages.length, (i) {
                              final userAnswer = userAnswers[i] ?? "-";
                              final correctAnswer = stages[i]["correct"];
                              final isCorrect = userAnswer == correctAnswer;

                              return TableRow(
                                decoration: BoxDecoration(
                                  color:
                                      isCorrect
                                          ? const Color.fromARGB(
                                            255,
                                            237,
                                            238,
                                            238,
                                          )
                                          : const Color.fromARGB(
                                            255,
                                            255,
                                            235,
                                            235,
                                          ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${i + 1}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      userAnswer,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      correctAnswer,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Button row with both Restart and Quit options
                Row(
                  children: [
                    // Restart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmRestartTest,
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
                    // Quit Button
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _choiceButton(String text) {
    final bool isSelected = selectedAnswer == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswer = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F3238) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return _buildResultScreen();
    }

    final stage = stages[currentStage];

    return PopScope<Object?>(
      // Add generic type <Object?>
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // New callback with result parameter
        if (didPop) return;
        _confirmExitTest();
      },
      child: Scaffold(
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
                onPressed: _confirmExitTest, // confirm before leaving
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
                              'assets/game_logos/ishihara_tutorial.png',
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
                          title: Text("Disclaimer and Purpose"),
                          content: Text(
                            "Disclaimer:\n"
                            "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis. Results may vary depending on device display, brightness, and lighting conditions. For an accurate assessment, please consult a qualified eye care professional or ophthalmologist.\n\n"
                            "Purpose:\n"
                            "It is designed to screen for color vision deficiencies, particularly red–green color blindness, by asking users to identify numbers embedded within patterns of colored dots. The test evaluates how well a person can distinguish color differences that form the hidden numbers.",
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Ishihara-Test",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${currentStage + 1}/${stages.length}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F3238),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                "What number do you see",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  stage["image"],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Choose a number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          (stage["choices"] as List<String>)
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: _choiceButton(c),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Restart Button
                        SizedBox(
                          width: 140,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _confirmRestartTest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Color(0xFF2F3238)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Restart",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Submit Button
                        SizedBox(
                          width: 140,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                selectedAnswer == null ? null : _submitStage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F3238),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTestResult() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final syncService = SyncService();

    await syncService.saveTestResult(
      userId: user.id,
      testType: 'ishihara',
      overallRating: percentCorrect,
      overallStatus: classification,
      recommendation: recommendation,
    );

    print('Test saved! Rating: $percentCorrect%, Status: $classification');
  }
}

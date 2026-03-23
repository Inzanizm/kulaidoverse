import 'package:flutter/material.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HRRScreen extends StatefulWidget {
  const HRRScreen({super.key});

  @override
  State<HRRScreen> createState() => _HRRScreenState();
}

class _HRRScreenState extends State<HRRScreen> {
  int currentStage = 0;
  bool showResults = false;

  List<Map<String, String>> userAnswers = [];

  String topLeft = "Nothing";
  String topRight = "Nothing";
  String bottomLeft = "Nothing";
  String bottomRight = "Nothing";

  final List<String> choices = ["Nothing", "Triangle", "Circle"];

  final List<Map<String, dynamic>> stages = [
    {
      "image": "assets/logo/hrrt1.png",
      "category": "Deutan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Triangle",
        "bottomLeft": "Circle",
        "bottomRight": "Nothing",
      },
    },
    {
      "image": "assets/logo/hrrt2.png",
      "category": "Deutan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Nothing",
        "bottomLeft": "Triangle",
        "bottomRight": "Circle",
      },
    },
    {
      "image": "assets/logo/hrrt3.png",
      "category": "Deutan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Circle",
      },
    },
    {
      "image": "assets/logo/hrrt4.png",
      "category": "Deutan",
      "answers": {
        "topLeft": "Triangle",
        "topRight": "Circle",
        "bottomLeft": "Nothing",
        "bottomRight": "Nothing",
      },
    },
    {
      "image": "assets/logo/hrrt5.png",
      "category": "Protan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Triangle",
        "bottomLeft": "Circle",
        "bottomRight": "Nothing",
      },
    },
    {
      "image": "assets/logo/hrrt6.png",
      "category": "Protan",
      "answers": {
        "topLeft": "Triangle",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Nothing",
      },
    },
    {
      "image": "assets/logo/hrrt7.png",
      "category": "Tritan",
      "answers": {
        "topLeft": "Triangle",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Nothing",
      },
    },
    {
      "image": "assets/logo/hrrt8.png",
      "category": "Tritan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Triangle",
      },
    },
    {
      "image": "assets/logo/hrrt9.png",
      "category": "Tritan",
      "answers": {
        "topLeft": "Circle",
        "topRight": "Triangle",
        "bottomLeft": "Nothing",
        "bottomRight": "Nothing",
      },
    },
    {
      "image": "assets/logo/hrrt10.png",
      "category": "Tritan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Nothing",
        "bottomLeft": "Circle",
        "bottomRight": "Triangle",
      },
    },
    {
      "image": "assets/logo/hrrt11.png",
      "category": "Tritan",
      "answers": {
        "topLeft": "Triangle",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Circle",
      },
    },
    {
      "image": "assets/logo/hrrt12.png",
      "category": "Tritan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Circle",
      },
    },
    {
      "image": "assets/logo/hrrt13.png",
      "category": "Protan",
      "answers": {
        "topLeft": "Circle",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Nothing",
      },
    },
    {
      "image": "assets/logo/hrrt14.png",
      "category": "Protan",
      "answers": {
        "topLeft": "Nothing",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Circle",
      },
    },
  ];

  // Results data
  Map<String, int> total = {"Protan": 0, "Deutan": 0, "Tritan": 0};
  Map<String, int> wrong = {"Protan": 0, "Deutan": 0, "Tritan": 0};
  Map<String, int> correct = {"Protan": 0, "Deutan": 0, "Tritan": 0};
  double protanDeficiency = 0;
  double deutanDeficiency = 0;
  double tritanDeficiency = 0;
  double redGreenDeficiency = 0;
  double overallDeficiency = 0;
  bool isMonochrome = false;
  String classification = "";
  String recommendation = "";

  bool _isSaved = false; // Track if results have been saved

  @override
  void initState() {
    super.initState();
    userAnswers = List.generate(
      stages.length,
      (_) => {
        "topLeft": "Nothing",
        "topRight": "Nothing",
        "bottomLeft": "Nothing",
        "bottomRight": "Nothing",
      },
    );
  }

  bool get allSelected =>
      topLeft.isNotEmpty &&
      topRight.isNotEmpty &&
      bottomLeft.isNotEmpty &&
      bottomRight.isNotEmpty;

  void _loadStage(int stage) {
    setState(() {
      currentStage = stage;
      topLeft = userAnswers[stage]["topLeft"]!;
      topRight = userAnswers[stage]["topRight"]!;
      bottomLeft = userAnswers[stage]["bottomLeft"]!;
      bottomRight = userAnswers[stage]["bottomRight"]!;
    });
  }

  void _submitStage() {
    userAnswers[currentStage] = {
      "topLeft": topLeft,
      "topRight": topRight,
      "bottomLeft": bottomLeft,
      "bottomRight": bottomRight,
    };

    if (currentStage < stages.length - 1) {
      _loadStage(currentStage + 1);
    } else {
      _calculateResults();
      setState(() {
        showResults = true;
      });
      _saveTestResult(); // ADDED: Save results when test completes
    }
  }

  bool _compare(String user, String correct) =>
      user.trim().toUpperCase() == correct.trim().toUpperCase();

  void _calculateResults() {
    int totalWrongStages = 0;

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final category = stage["category"];
      final correctAnswers = stage["answers"];
      final answers = userAnswers[i];

      total[category] = total[category]! + 1;

      bool correctStage =
          _compare(answers["topLeft"]!, correctAnswers["topLeft"]) &&
          _compare(answers["topRight"]!, correctAnswers["topRight"]) &&
          _compare(answers["bottomLeft"]!, correctAnswers["bottomLeft"]) &&
          _compare(answers["bottomRight"]!, correctAnswers["bottomRight"]);

      if (!correctStage) {
        wrong[category] = wrong[category]! + 1;
        totalWrongStages++;
      } else {
        correct[category] = correct[category]! + 1;
      }
    }

    // Calculate correct counts (total - wrong)
    correct["Protan"] = total["Protan"]! - wrong["Protan"]!;
    correct["Deutan"] = total["Deutan"]! - wrong["Deutan"]!;
    correct["Tritan"] = total["Tritan"]! - wrong["Tritan"]!;

    // Calculate RATING percentages (correct rate)
    protanDeficiency = 100 - ((wrong["Protan"]! / total["Protan"]!) * 100);
    deutanDeficiency = 100 - ((wrong["Deutan"]! / total["Deutan"]!) * 100);
    tritanDeficiency = 100 - ((wrong["Tritan"]! / total["Tritan"]!) * 100);

    // Calculate Red-Green RATING percentage
    int redGreenWrongCount = wrong["Protan"]! + wrong["Deutan"]!;
    int redGreenTotal = total["Protan"]! + total["Deutan"]!;
    redGreenDeficiency = 100 - ((redGreenWrongCount / redGreenTotal) * 100);

    // Calculate overall rating
    int totalWrong = wrong["Protan"]! + wrong["Deutan"]! + wrong["Tritan"]!;
    int totalAll = total["Protan"]! + total["Deutan"]! + total["Tritan"]!;
    overallDeficiency = 100 - ((totalWrong / totalAll) * 100);

    isMonochrome = totalWrongStages == stages.length;

    // Classification based on rating
    if (isMonochrome) {
      classification = "Monochromacy";
      recommendation =
          "Total color vision deficiency detected. Immediate consultation with an ophthalmologist is strongly recommended.";
    } else if (overallDeficiency <= 50) {
      classification = "Severe Color Blindness";
      recommendation =
          "Significant color vision deficiency detected. We recommend scheduling an appointment with an ophthalmologist for professional diagnosis and guidance.";
    } else if (overallDeficiency <= 80) {
      classification = "Mild Color Blindness";
      recommendation =
          "You may have mild color vision deficiency. Consider consulting an eye care professional for a comprehensive evaluation.";
    } else {
      classification = "Normal Color Vision";
      recommendation =
          "Your color vision appears normal. No further action needed.";
    }
  }

  // ADDED: Save test results to database
  Future<void> _saveTestResult() async {
    if (_isSaved) return; // Prevent duplicate saves

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final syncService = SyncService();

    await syncService.saveTestResult(
      userId: user.id,
      testType: 'hrr',
      overallRating: overallDeficiency,
      overallStatus: classification,
      recommendation: recommendation,
    );

    setState(() {
      _isSaved = true;
    });

    print(
      'HRR test saved! Rating: ${overallDeficiency.toStringAsFixed(1)}%, Status: $classification',
    );
  }

  void _restartTest() {
    setState(() {
      currentStage = 0;
      topLeft = topRight = bottomLeft = bottomRight = "Nothing";
      userAnswers = List.generate(
        stages.length,
        (_) => {
          "topLeft": "Nothing",
          "topRight": "Nothing",
          "bottomLeft": "Nothing",
          "bottomRight": "Nothing",
        },
      );
      showResults = false;
      total = {"Protan": 0, "Deutan": 0, "Tritan": 0};
      wrong = {"Protan": 0, "Deutan": 0, "Tritan": 0};
      correct = {"Protan": 0, "Deutan": 0, "Tritan": 0};
      protanDeficiency = 0;
      deutanDeficiency = 0;
      tritanDeficiency = 0;
      redGreenDeficiency = 0;
      overallDeficiency = 0;
      isMonochrome = false;
      classification = "";
      recommendation = "";
      _isSaved = false; // Reset save flag
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

  Widget _buildResultScreen() {
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

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final answers = userAnswers[i];
      final correctAnswers = stage["answers"];

      bool tlCorrect = _compare(answers["topLeft"]!, correctAnswers["topLeft"]);
      bool trCorrect = _compare(
        answers["topRight"]!,
        correctAnswers["topRight"],
      );
      bool blCorrect = _compare(
        answers["bottomLeft"]!,
        correctAnswers["bottomLeft"],
      );
      bool brCorrect = _compare(
        answers["bottomRight"]!,
        correctAnswers["bottomRight"],
      );
      bool allCorrect = tlCorrect && trCorrect && blCorrect && brCorrect;

      detailRows.add(
        TableRow(
          decoration: BoxDecoration(
            color:
                allCorrect
                    ? const Color.fromARGB(255, 237, 238, 238)
                    : const Color.fromARGB(255, 235, 234, 234),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "UL: ${answers["topLeft"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                  Text(
                    "UR: ${answers["topRight"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                  Text(
                    "BL: ${answers["bottomLeft"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                  Text(
                    "BR: ${answers["bottomRight"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "UL: ${correctAnswers["topLeft"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                  Text(
                    "UR: ${correctAnswers["topRight"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                  Text(
                    "BL: ${correctAnswers["bottomLeft"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                  Text(
                    "BR: ${correctAnswers["bottomRight"]}",
                    style: const TextStyle(color: Colors.black87, fontSize: 11),
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
                            "The HRR Test (Hardy–Rand–Rittler Test) is used to detect and classify different types of color vision deficiencies through the recognition of symbols embedded in colored plates. It can identify both red–green and blue–yellow impairments and helps determine the type and possible severity of the color vision deficiency.",
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
                // Summary Table with 4 rows: Protan, Deutan, Tritan, Red-Green
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
                                "Correct",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Protan row
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 238, 238, 238),
                          ),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Text(
                                "Protan",
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
                                "${protanDeficiency.toStringAsFixed(1)}%",
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
                                "${correct["Protan"]}/${total["Protan"]}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Deutan row
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 231, 231, 231),
                          ),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Text(
                                "Deutan",
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
                                "${deutanDeficiency.toStringAsFixed(1)}%",
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
                                "${correct["Deutan"]}/${total["Deutan"]}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Tritan row
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 238, 238, 238),
                          ),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Text(
                                "Tritan",
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
                                "${tritanDeficiency.toStringAsFixed(1)}%",
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
                                "${correct["Tritan"]}/${total["Tritan"]}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Red-Green row
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 231, 231, 231),
                          ),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Text(
                                "Red-Green",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Text(
                                "${redGreenDeficiency.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Text(
                                "${correct["Protan"]! + correct["Deutan"]!}/${total["Protan"]! + total["Deutan"]!}",
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
                // Overall Rating Card
                Card(
                  color: const Color(0xFF3A3F4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          "Overall Rating: ${overallDeficiency.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          classification,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Recommendation Box
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
                      const Text(
                        "Recommendation:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
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

  Widget _dropdownBox({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items:
                  items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return _buildResultScreen();
    }

    final stageData = stages[currentStage];

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
                              'assets/game_logos/hrr_tutorial.png',
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
                            "The HRR Test (Hardy–Rand–Rittler Test) is used to detect and classify different types of color vision deficiencies through the recognition of symbols embedded in colored plates. It can identify both red–green and blue–yellow impairments and helps determine the type and possible severity of the color vision deficiency.",
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
            const SizedBox(height: 12),
            Text(
              "Stage ${currentStage + 1} of ${stages.length} (${stageData["category"]})",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              "What do you see?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3238),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      stageData["image"],
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Choose an answer",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownBox(
                          label: "Top left",
                          value: topLeft,
                          onChanged: (v) => setState(() => topLeft = v!),
                          items: choices,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dropdownBox(
                          label: "Top right",
                          value: topRight,
                          onChanged: (v) => setState(() => topRight = v!),
                          items: choices,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownBox(
                          label: "Bottom left",
                          value: bottomLeft,
                          onChanged: (v) => setState(() => bottomLeft = v!),
                          items: choices,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _dropdownBox(
                          label: "Bottom right",
                          value: bottomRight,
                          onChanged: (v) => setState(() => bottomRight = v!),
                          items: choices,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                SizedBox(
                  width: 140,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: allSelected ? _submitStage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F3238),
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

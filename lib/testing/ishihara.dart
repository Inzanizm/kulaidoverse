import 'package:flutter/material.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:kulaidoverse/theme.dart';
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
      setState(() => showResults = true);
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

    if (percentCorrect >= 80) {
      classification = "Normal Color Vision";
      recommendation =
          "Your color vision appears normal. No further action needed.";
    } else if (percentCorrect >= 50) {
      classification = "Mild Color Blindness";
      recommendation =
          "You may have mild color vision deficiency. Consider consulting an eye care professional.";
    } else {
      classification = "Severe Color Blindness";
      recommendation =
          "Significant color vision deficiency detected. We recommend scheduling an appointment with an ophthalmologist.";
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
          (_) => _buildConfirmDialog(
            title: "Quit Test?",
            message:
                "Are you sure you want to quit?\nYour current progress will be lost.",
            confirmButtonText: "Quit", // Add this
            onConfirm: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  void _confirmRestartTest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => _buildConfirmDialog(
            title: "Restart Test?",
            message:
                "Are you sure you want to restart the test?\nAll progress will be reset.",
            confirmButtonText: "Restart", // Add this
            onConfirm: () {
              Navigator.pop(context);
              _resetTest();
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _saveTestResult() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await SyncService().saveTestResult(
      userId: user.id,
      testType: 'ishihara',
      overallRating: percentCorrect,
      overallStatus: classification,
      recommendation: recommendation,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) return _buildResultScreen();
    return _buildTestScreen();
  }

  Widget _buildTestScreen() {
    final stage = stages[currentStage];
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width > 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExitTest();
      },
      child: Scaffold(
        backgroundColor: AppTheme.pureWhite,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  isSmallScreen
                                      ? AppTheme.spaceMd
                                      : AppTheme.spaceLg,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height:
                                      isSmallScreen
                                          ? AppTheme.spaceMd
                                          : AppTheme.spaceLg,
                                ),
                                Text(
                                  "Ishihara-Test",
                                  style: TextStyle(
                                    fontSize: isTablet ? 32 : 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spaceMd),
                                Text(
                                  "${currentStage + 1}/${stages.length}",
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spaceLg),

                                // Question text - OUTSIDE black container
                                // Question text - OUTSIDE black container
                                Text(
                                  "What number do you see?",
                                  style: TextStyle(
                                    fontSize:
                                        isTablet
                                            ? 24
                                            : 20, // Increased from 18/16
                                    fontWeight:
                                        FontWeight.bold, // Increased from w600
                                    color: AppTheme.pureBlack,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spaceMd),

                                // Ishihara Plate - image only inside black container
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          isTablet ? 500 : double.infinity,
                                      maxHeight: isTablet ? 400 : 350,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.softBlack,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusLarge,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(AppTheme.spaceMd),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMedium,
                                        ),
                                        child: Image.asset(
                                          stage["image"],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppTheme.spaceLg),
                                Text(
                                  "Choose a number",
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spaceMd),
                                // Choice buttons - responsive grid
                                Wrap(
                                  spacing: AppTheme.spaceMd,
                                  runSpacing: AppTheme.spaceMd,
                                  alignment: WrapAlignment.center,
                                  children:
                                      (stage["choices"] as List<String>)
                                          .map(
                                            (c) => _choiceButton(
                                              c,
                                              isSmallScreen,
                                              isTablet,
                                            ),
                                          )
                                          .toList(),
                                ),
                                SizedBox(height: AppTheme.spaceLg),
                                // Action buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: isTablet ? 160 : 140,
                                      height: isTablet ? 56 : 52,
                                      child: ElevatedButton(
                                        onPressed: _confirmRestartTest,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.pureWhite,
                                          foregroundColor: AppTheme.pureBlack,
                                          side: const BorderSide(
                                            color: AppTheme.softBlack,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusSmall,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Restart",
                                          style: TextStyle(
                                            fontSize: isTablet ? 18 : 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spaceMd),
                                    SizedBox(
                                      width: isTablet ? 160 : 140,
                                      height: isTablet ? 56 : 52,
                                      child: ElevatedButton(
                                        onPressed:
                                            selectedAnswer == null
                                                ? null
                                                : _submitStage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.softBlack,
                                          disabledBackgroundColor:
                                              AppTheme.grey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusSmall,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(
                                            fontSize: isTablet ? 20 : 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.pureWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.spaceLg),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width > 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.pureWhite,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, showBack: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        isSmallScreen ? AppTheme.spaceMd : AppTheme.spaceLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: AppTheme.spaceLg),
                      Center(
                        child: Text(
                          "Your Color Vision Test Results",
                          style: TextStyle(
                            fontSize: isTablet ? 26 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: AppTheme.spaceLg),
                      // Summary Card
                      Card(
                        color: AppTheme.softBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        elevation: AppTheme.elevationMedium,
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spaceMd),
                          child: Table(
                            border: TableBorder.all(
                              color: AppTheme.lightGrey.withOpacity(0.3),
                              width: 1,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2F3238),
                                ),
                                children: [
                                  _tableHeader("Test Type"),
                                  _tableHeader("Rating"),
                                  _tableHeader("Status"),
                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(
                                  color: AppTheme.offWhite,
                                ),
                                children: [
                                  _tableCell("Ishihara Test", isBold: false),
                                  _tableCell(
                                    "${percentCorrect.toStringAsFixed(1)}%",
                                  ),
                                  _tableCell(classification, isBold: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppTheme.spaceLg),
                      // Result Details
                      Container(
                        padding: EdgeInsets.all(AppTheme.spaceMd),
                        decoration: BoxDecoration(
                          color: AppTheme.softBlack,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          border: Border.all(
                            color: AppTheme.lightGrey.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Ishihara: $classification (${percentCorrect.toStringAsFixed(1)}%)",
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppTheme.spaceMd),
                            Text(
                              "Recommendation:",
                              style: TextStyle(
                                color: AppTheme.lightGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppTheme.spaceXs),
                            Text(
                              recommendation,
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppTheme.spaceLg),
                      // Detailed Results
                      Card(
                        color: AppTheme.softBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        elevation: AppTheme.elevationMedium,
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spaceMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Detailed Results",
                                style: TextStyle(
                                  color: AppTheme.pureWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppTheme.spaceMd),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: size.width - AppTheme.spaceLg * 4,
                                  ),
                                  child: Table(
                                    border: TableBorder.all(
                                      color: AppTheme.lightGrey.withOpacity(
                                        0.3,
                                      ),
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
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2F3238),
                                        ),
                                        children: [
                                          _tableHeader("Stage"),
                                          _tableHeader("Your Answer"),
                                          _tableHeader("Correct"),
                                        ],
                                      ),
                                      ...List.generate(stages.length, (i) {
                                        final userAnswer =
                                            userAnswers[i] ?? "-";
                                        final correctAnswer =
                                            stages[i]["correct"];
                                        final isCorrect =
                                            userAnswer == correctAnswer;

                                        return TableRow(
                                          decoration: BoxDecoration(
                                            color:
                                                isCorrect
                                                    ? AppTheme.offWhite
                                                    : const Color(0xFFFFEBEE),
                                          ),
                                          children: [
                                            _tableCell(
                                              "${i + 1}",
                                              isBold: false,
                                            ),
                                            _tableCell(userAnswer),
                                            _tableCell(
                                              correctAnswer,
                                              isBold: false,
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppTheme.spaceLg),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _resetTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.softBlack,
                                foregroundColor: AppTheme.pureWhite,
                                padding: EdgeInsets.symmetric(
                                  vertical: AppTheme.spaceMd,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text("Restart Test"),
                            ),
                          ),
                          SizedBox(width: AppTheme.spaceMd),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.pureWhite,
                                foregroundColor: AppTheme.pureBlack,
                                side: const BorderSide(
                                  color: AppTheme.softBlack,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: AppTheme.spaceMd,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text("Quit"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spaceMd),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, {bool showBack = true}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        boxShadow: AppTheme.shadowLow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button or Spacer
          showBack
              ? GestureDetector(
                onTap: _confirmExitTest,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.pureBlack,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.pureWhite,
                    size: 18,
                  ),
                ),
              )
              : const SizedBox(width: 40),
          // Center Logo & Title
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo/LogoKly.png', width: 28, height: 28),
                SizedBox(height: AppTheme.spaceXs),
                const Text("KULAIDOVERSE", style: AppTheme.appName),
              ],
            ),
          ),
          // Info Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(right: AppTheme.spaceXs),
                decoration: BoxDecoration(
                  color: AppTheme.pureBlack,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: IconButton(
                  iconSize: 18,
                  icon: const Icon(
                    Icons.question_mark,
                    color: AppTheme.pureWhite,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLarge,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLarge,
                              ),
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
                decoration: BoxDecoration(
                  color: AppTheme.pureBlack,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: IconButton(
                  iconSize: 18,
                  icon: const Icon(
                    Icons.info_outline,
                    color: AppTheme.pureWhite,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => const AlertDialog(
                            title: Text("Disclaimer and Purpose"),
                            content: Text(
                              "Disclaimer:\n"
                              "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis.\n\n"
                              "Purpose:\n"
                              "It is designed to screen for color vision deficiencies, particularly red–green color blindness, by asking users to identify numbers embedded within patterns of colored dots.",
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _choiceButton(String text, bool isSmallScreen, bool isTablet) {
    final bool isSelected = selectedAnswer == text;
    final size = isTablet ? 64.0 : (isSmallScreen ? 44.0 : 48.0);

    return GestureDetector(
      onTap: () => setState(() => selectedAnswer = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.softBlack : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected ? AppTheme.pureBlack : AppTheme.lightGrey,
            width: 2,
          ),
          boxShadow: isSelected ? AppTheme.shadowLow : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.pureWhite : AppTheme.pureBlack,
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.pureBlack,
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildConfirmDialog({
    required String title,
    required String message,
    required String confirmButtonText, // Add this parameter
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppTheme.spaceMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.bodyText,
            ),
            SizedBox(height: AppTheme.spaceLg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.pureWhite,
                      foregroundColor: AppTheme.pureBlack,
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                    ),
                    onPressed: onConfirm,
                    child: Text(
                      // Change from const Text to Text
                      confirmButtonText, // Use the parameter
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.pureBlack,
                      foregroundColor: AppTheme.pureWhite,
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                    ),
                    onPressed: onCancel,
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

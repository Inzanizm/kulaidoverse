import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Enum must be in this file
enum D15TestType { protan, deutan, tritan }

class D15TestScreen extends StatefulWidget {
  final D15TestType testType;

  const D15TestScreen({
    super.key,
    required this.testType,
  });

  @override
  State<D15TestScreen> createState() => _D15TestScreenState();
}

class _D15TestScreenState extends State<D15TestScreen> {
  bool isSaturated = true;
  Color? selectedColor;

  // Protan Test Colors - 15 Monochromatic Red caps (NOT including reference)
  // Reference is separate - these are the 15 caps user needs to arrange
 // Protan Test Colors - 15 Muted Red caps (NOT including reference)
// Desaturated, less bright red progression
// Protan Test Colors - 15 Brighter Muted Red caps (NOT including reference)
// Slightly more saturated but still not bright
final List<Color> protanColors = [
  const Color(0xFFF4C2C2), // Cap 1 - Brighter Light Pink
  const Color(0xFFE8A8A8), // Cap 2 - Brighter Dusty Pink
  const Color(0xFFDC9090), // Cap 3 - Brighter Muted Coral
  const Color(0xFFD07878), // Cap 4 - Brighter Soft Salmon
  const Color(0xFFC46060), // Cap 5 - Brighter Muted Light Red
  const Color(0xFFB84848), // Cap 6 - Brighter Dusty Red
  const Color(0xFFAC3030), // Cap 7 - Brighter Muted Red
  const Color(0xFFA02020), // Cap 8 - Brighter Dark Muted Red
  const Color(0xFF8C1818), // Cap 9 - Brighter Deep Muted Red
  const Color(0xFF781010), // Cap 10 - Brighter Darker Muted Red
  const Color(0xFF640C0C), // Cap 11 - Brighter Very Deep Muted
  const Color(0xFF500808), // Cap 12 - Brighter Dark Muted
  const Color(0xFF3C0404), // Cap 13 - Brighter Deep Dark Muted
  const Color(0xFF2C0202), // Cap 14 - Brighter Very Dark Muted
  const Color(0xFF1A0000), // Cap 15 - Brighter Deepest Muted Red
];

// Deutan Test Colors - 15 Brighter Muted Green caps (NOT including reference)
// Slightly more saturated but still not bright
final List<Color> deutanColors = [
  const Color(0xFFC2E8C2), // Cap 1 - Brighter Light Mint
  const Color(0xFFA8DCA8), // Cap 2 - Brighter Dusty Mint
  const Color(0xFF90D090), // Cap 3 - Brighter Muted Light Green
  const Color(0xFF78C478), // Cap 4 - Brighter Soft Green
  const Color(0xFF60B860), // Cap 5 - Brighter Muted Medium Green
  const Color(0xFF48AC48), // Cap 6 - Brighter Dusty Green
  const Color(0xFF30A030), // Cap 7 - Brighter Muted Green
  const Color(0xFF209020), // Cap 8 - Brighter Dark Muted Green
  const Color(0xFF188018), // Cap 9 - Brighter Deep Muted Green
  const Color(0xFF107010), // Cap 10 - Brighter Darker Muted Green
  const Color(0xFF0C600C), // Cap 11 - Brighter Very Deep Muted
  const Color(0xFF085008), // Cap 12 - Brighter Dark Muted
  const Color(0xFF044004), // Cap 13 - Brighter Deep Dark Muted
  const Color(0xFF023002), // Cap 14 - Brighter Very Dark Muted
  const Color(0xFF002000), // Cap 15 - Brighter Deepest Muted Green
];

// Tritan Test Colors - 15 Brighter Muted Blue caps (NOT including reference)
// Slightly more saturated but still not bright
final List<Color> tritanColors = [
  const Color(0xFFC2D8F0), // Cap 1 - Brighter Light Sky
  const Color(0xFFA8CCE8), // Cap 2 - Brighter Dusty Sky
  const Color(0xFF90C0E0), // Cap 3 - Brighter Muted Light Blue
  const Color(0xFF78B4D8), // Cap 4 - Brighter Soft Blue
  const Color(0xFF60A8D0), // Cap 5 - Brighter Muted Medium Blue
  const Color(0xFF489CC8), // Cap 6 - Brighter Dusty Blue
  const Color(0xFF3090C0), // Cap 7 - Brighter Muted Blue
  const Color(0xFF2080B0), // Cap 8 - Brighter Dark Muted Blue
  const Color(0xFF1870A0), // Cap 9 - Brighter Deep Muted Blue
  const Color(0xFF106090), // Cap 10 - Brighter Darker Muted Blue
  const Color(0xFF0C5080), // Cap 11 - Brighter Very Deep Muted
  const Color(0xFF084070), // Cap 12 - Brighter Dark Muted
  const Color(0xFF043060), // Cap 13 - Brighter Deep Dark Muted
  const Color(0xFF022050), // Cap 14 - Brighter Very Dark Muted
  const Color(0xFF001040), // Cap 15 - Brighter Deepest Muted Blue
];

  late Color referenceColor;
  late List<Color> capColors;
  late List<Color?> placedColors;
  late List<Color> shuffledCaps;

  @override
  void initState() {
    super.initState();

    // Set up colors based on test type
   switch (widget.testType) {
  case D15TestType.protan:
    capColors = protanColors;
    referenceColor = const Color(0xFFF8D8D8); // Brighter muted light pink
    break;
  case D15TestType.deutan:
    capColors = deutanColors;
    referenceColor = const Color(0xFFD8F8D8); // Brighter muted light mint
    break;
  case D15TestType.tritan:
    capColors = tritanColors;
    referenceColor = const Color(0xFFD8E8F8); // Brighter muted light sky
    break;
}

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initializeTest();
  }

  void _initializeTest() {
    // 16 slots total: 1 reference + 15 caps
    placedColors = List<Color?>.filled(16, null);
    placedColors[0] = referenceColor; // Reference at position 0

    // Shuffle the 15 caps (not the reference)
    shuffledCaps = List<Color>.from(capColors);
    shuffledCaps.shuffle(Random());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String get _testTitle {
    switch (widget.testType) {
      case D15TestType.protan:
        return "Protan Test (Red Vision)";
      case D15TestType.deutan:
        return "Deutan Test (Green Vision)";
      case D15TestType.tritan:
        return "Tritan Test (Blue Vision)";
    }
  }

  String get _testDescription {
    switch (widget.testType) {
      case D15TestType.protan:
        return "Arrange 15 caps from light pink to deep maroon";
      case D15TestType.deutan:
        return "Arrange 15 caps from light mint to deep forest";
      case D15TestType.tritan:
        return "Arrange 15 caps from light sky to deep navy";
    }
  }

  void _confirmExitTest() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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

  Color _applyMode(Color color) {
    if (isSaturated) return color;
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(0.2).toColor();
  }

  int _getCapNumber(Color color) {
    if (color == referenceColor) return 0;
    int index = capColors.indexOf(color);
    if (index != -1) return index + 1; // Returns 1-15 for the 15 caps
    return -1;
  }

  void _selectColor(Color color) {
    setState(() {
      if (selectedColor == color) {
        selectedColor = null;
      } else {
        selectedColor = color;
      }
    });
  }

  void _placeColor(int index) {
    if (index == 0) return; // Can't place in reference slot

    setState(() {
      if (selectedColor != null) {
        // Remove from previous position if already placed
        for (int i = 1; i < placedColors.length; i++) {
          if (placedColors[i] == selectedColor) {
            placedColors[i] = null;
          }
        }
        // Place or remove from current slot
        if (placedColors[index] == selectedColor) {
          placedColors[index] = null;
        } else {
          placedColors[index] = selectedColor;
        }
        selectedColor = null;
      } else {
        // If no color selected, clear this slot
        placedColors[index] = null;
      }
    });
  }

  Map<String, dynamic> _calculateResults() {
    Map<int, int> capToPosition = {};
    capToPosition[0] = 0; // Reference is always at position 0

    // Map placed caps to their positions (1-15)
    for (int pos = 1; pos < 16; pos++) {
      if (placedColors[pos] != null) {
        int capNum = _getCapNumber(placedColors[pos]!);
        if (capNum != -1) {
          capToPosition[capNum] = pos;
        }
      }
    }

    // Check if all 15 caps are placed
    if (capToPosition.length < 16) { // 0 (reference) + 15 caps
      return {'complete': false, 'placedCount': capToPosition.length - 1};
    }

    int totalError = 0;
    List<int> misplacedCaps = [];

    // Check if caps 1-15 are in correct positions 1-15
    for (int cap = 1; cap <= 15; cap++) {
      int expectedPos = cap;
      int actualPos = capToPosition[cap]!;

      if (actualPos != expectedPos) {
        totalError++;
        misplacedCaps.add(cap);
      }
    }

    int totalCrossings = _calculateCrossings(capToPosition);

   String severity;
Color severityColor;        // Changed from diagnosisColor to severityColor
Color diagnosisColor;       // New variable for diagnosis

if (totalError <= 2) {
  severity = "Normal";
  severityColor = const Color.fromARGB(255, 0, 0, 0);                    // White for severity
  diagnosisColor = Colors.black;                   // Black for diagnosis
} else if (totalError <= 5) {
  severity = "Mild Deficiency";
  severityColor = const Color.fromARGB(255, 0, 0, 0);
  diagnosisColor = Colors.black;
} else if (totalError <= 10) {
  severity = "Moderate Deficiency";
  severityColor = const Color.fromARGB(255, 0, 0, 0);
  diagnosisColor = Colors.black;
} else {
  severity = "Severe Deficiency";
  severityColor = const Color.fromARGB(255, 0, 0, 0);
  diagnosisColor = Colors.black;
}

    String specificDiagnosis;
    switch (widget.testType) {
      case D15TestType.protan:
        specificDiagnosis = totalError <= 2
            ? "Normal Red Vision"
            : "Protanomaly (Red Deficiency) - $severity";
        break;
      case D15TestType.deutan:
        specificDiagnosis = totalError <= 2
            ? "Normal Green Vision"
            : "Deuteranomaly (Green Deficiency) - $severity";
        break;
      case D15TestType.tritan:
        specificDiagnosis = totalError <= 2
            ? "Normal Blue Vision"
            : "Tritanomaly (Blue Deficiency) - $severity";
        break;
    }

    return {
      'complete': true,
      'totalError': totalError,
      'totalCrossings': totalCrossings,
      'capToPosition': capToPosition,
      'misplacedCaps': misplacedCaps,
      'diagnosis': specificDiagnosis,
      'diagnosisColor': diagnosisColor,
      'severity': severity,
      'testType': widget.testType,
    };
  }

  int _calculateCrossings(Map<int, int> capToPosition) {
    int crossings = 0;

    // Check crossings for caps 0-14 (reference + 14 caps)
    for (int i = 0; i < 15; i++) {
      int a = capToPosition[i]!;
      int b = capToPosition[i + 1]!;

      for (int j = i + 2; j < 15; j++) {
        int c = capToPosition[j]!;
        int d = capToPosition[j + 1]!;

        if (_segmentsCross(a, b, c, d)) {
          crossings++;
        }
      }
    }

    return crossings;
  }

  bool _segmentsCross(int a, int b, int c, int d) {
    if (a > b) {
      int temp = a;
      a = b;
      b = temp;
    }
    if (c > d) {
      int temp = c;
      c = d;
      d = temp;
    }

    return (a < c && c < b && b < d) || (c < a && a < d && d < b);
  }

  void _showResults() {
    final results = _calculateResults();

    if (!(results['complete'] ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Please place all ${15 - (results['placedCount'] ?? 0)} remaining caps first",
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => D15ResultsScreen(
          totalError: results['totalError'] as int,
          totalCrossings: results['totalCrossings'] as int,
          diagnosis: results['diagnosis'] as String,
          diagnosisColor: results['diagnosisColor'] as Color,
          severity: results['severity'] as String,
          testType: widget.testType,
          capToPosition: results['capToPosition'] as Map<int, int>,
          onRestart: () {
            Navigator.pop(context);
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            setState(() {
              placedColors = List<Color?>.filled(16, null);
              placedColors[0] = referenceColor;
              selectedColor = null;
              shuffledCaps.shuffle(Random());
            });
          },
          onQuit: () {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final fontSize = (width + height) / 80;

    // Fixed cap size that works well in landscape
    const double capSize = 36.0;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _confirmExitTest();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2E3035),
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
              Text(
                _testTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            const SizedBox(width: 4),
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
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                iconSize: 18,
                icon: const Icon(Icons.question_mark, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Tutorial: $_testTitle"),
                      content: Text(
                        "A reference color and 15 colored caps will appear. Select the caps in order to arrange them into a smooth color sequence starting from the reference. ${_testDescription}.",
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
                  String testSpecificInfo;
                  switch (widget.testType) {
                    case D15TestType.protan:
                      testSpecificInfo = "This test evaluates your ability to distinguish between 15 red hues from light pink to deep maroon.";
                      break;
                    case D15TestType.deutan:
                      testSpecificInfo = "This test evaluates your ability to distinguish between 15 green hues from light mint to deep forest.";
                      break;
                    case D15TestType.tritan:
                      testSpecificInfo = "This test evaluates your ability to distinguish between 15 blue hues from light sky to deep navy.";
                      break;
                  }

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Disclaimer and Purpose"),
                      content: Text(
                        "Disclaimer:\n"
                        "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis.\n\n"
                        "Purpose:\n"
                        "$testSpecificInfo",
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _testDescription,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize + 4,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _modeButton("Saturated", true, fontSize),
                      const SizedBox(width: 16),
                      _modeButton("Desaturated", false, fontSize),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Available caps row - 15 shuffled caps (not including reference)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Select caps (${shuffledCaps.length - placedColors.where((c) => c != null && c != referenceColor).length} remaining):",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: shuffledCaps.map((color) {
                              final isPlaced = placedColors.contains(color);
                              final displayColor = _applyMode(color);
                              final isSelected = selectedColor == color;

                              if (isPlaced) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () => _selectColor(color),
                                  child: Container(
                                    width: capSize,
                                    height: capSize,
                                    decoration: BoxDecoration(
                                      color: displayColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.black,
                                        width: isSelected ? 3 : 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.5),
                                                blurRadius: 6,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Placement slots row - 16 slots (1 reference + 15 caps)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Arrange here (Ref + 15 caps):",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(16, (index) {
                              final isReference = index == 0;
                              final hasColor = placedColors[index] != null;
                              final isEmptySlot = !isReference && !hasColor && selectedColor != null;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () => _placeColor(index),
                                  child: Container(
                                    width: capSize,
                                    height: capSize,
                                    decoration: BoxDecoration(
                                      color: _applyMode(
                                        placedColors[index] ??
                                            (isReference
                                                ? referenceColor
                                                : const Color.fromARGB(
                                                    255,
                                                    240,
                                                    240,
                                                    240,
                                                  )),
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isEmptySlot ? Colors.blue : Colors.black,
                                        width: isEmptySlot ? 3 : 1.5,
                                      ),
                                      boxShadow: isEmptySlot
                                          ? [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.3),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: isReference
                                        ? const Center(
                                            child: Text(
                                              "REF",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            placedColors = List<Color?>.filled(16, null);
                            placedColors[0] = referenceColor;
                            selectedColor = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: fontSize * 4,
                            vertical: fontSize * 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Restart",
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _showResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: fontSize * 4,
                            vertical: fontSize * 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Results",
                          style: TextStyle(fontSize: fontSize),
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
      ),
    );
  }

  Widget _modeButton(String text, bool value, double fontSize) {
    final isActive = isSaturated == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isSaturated = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.white : Colors.grey[700],
        foregroundColor: isActive ? Colors.black : Colors.white,
      ),
      child: Text(text, style: TextStyle(fontSize: fontSize)),
    );
  }
}

// Results Screen
class D15ResultsScreen extends StatefulWidget {
  final int totalError;
  final int totalCrossings;
  final String diagnosis;
  final Color diagnosisColor;
  final String severity;
  final D15TestType testType;
  final Map<int, int> capToPosition;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const D15ResultsScreen({
    super.key,
    required this.totalError,
    required this.totalCrossings,
    required this.diagnosis,
    required this.diagnosisColor,
    required this.severity,
    required this.testType,
    required this.capToPosition,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  State<D15ResultsScreen> createState() => _D15ResultsScreenState();
}

class _D15ResultsScreenState extends State<D15ResultsScreen> {
  @override
  void initState() {
    super.initState();
    _saveTestResult();
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




  String get _testTypeLabel {
    switch (widget.testType) {
      case D15TestType.protan:
        return "Protan (Red)";
      case D15TestType.deutan:
        return "Deutan (Green)";
      case D15TestType.tritan:
        return "Tritan (Blue)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                           "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis.",
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
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "$_testTypeLabel Test Results",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CustomPaint(
                    painter: D15ResultsPainter(
                      capToPosition: widget.capToPosition,
                      diagnosisColor: widget.diagnosisColor,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
                          "Test Type: $_testTypeLabel",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Table(
                          border: TableBorder.all(color: Colors.white24, width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(color: Color(0xFF2F3238)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    "Metric",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    "Value",
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
                                    "Total Errors",
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
                                    "${widget.totalError}",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                    "Total Crossings",
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
                                    "${widget.totalCrossings}",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                    "Severity",
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
                                    widget.severity,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: widget.diagnosisColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
                        widget.diagnosis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
                        _getRecommendation(widget.totalError),
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
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text("Quit"),
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

  String _getRecommendation(int totalError) {
    if (totalError <= 2) {
      return 'Normal color vision in this region. No restrictions.';
    } else if (totalError <= 5) {
      return 'Mild deficiency detected. Monitor for changes.';
    } else if (totalError <= 10) {
      return 'Moderate deficiency. May have difficulty with color-critical tasks.';
    } else {
      return 'Significant color vision deficiency. Occupational guidance recommended.';
    }
  }

  Future<void> _saveTestResult() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final syncService = SyncService();

    final rating = (100 - ((widget.totalError / 15) * 100));
    final testTypeString = 'd15_${widget.testType.name}';

    await syncService.saveTestResult(
      userId: user.id,
      testType: testTypeString,
      overallRating: rating,
      overallStatus: widget.diagnosis,
      recommendation: _getRecommendation(widget.totalError),
    );
  }
}

// Custom painter for D15 results visualization
class D15ResultsPainter extends CustomPainter {
  final Map<int, int> capToPosition;
  final Color diagnosisColor;

  D15ResultsPainter({
    required this.capToPosition,
    required this.diagnosisColor,
  });

  Offset _getPositionOffset(int position, Offset center, double radius) {
    double angle = (202.5 - position * 22.5) * pi / 180;

    return Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    final circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, circlePaint);

    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < 16; i++) {
      Offset pos = _getPositionOffset(i, center, radius);

      canvas.drawCircle(pos, 4, dotPaint);

      Offset labelPos = _getPositionOffset(i, center, radius + 18);

      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelPos.dx - textPainter.width / 2,
          labelPos.dy - textPainter.height / 2,
        ),
      );
    }

    final linePaint = Paint()
      ..color = diagnosisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int cap = 0; cap < 15; cap++) {
      int? fromPos = capToPosition[cap];
      int? toPos = capToPosition[cap + 1];

      if (fromPos != null && toPos != null) {
        Offset from = _getPositionOffset(fromPos, center, radius);
        Offset to = _getPositionOffset(toPos, center, radius);
        canvas.drawLine(from, to, linePaint);
      }
    }

    final capDotPaint = Paint()
      ..color = diagnosisColor
      ..style = PaintingStyle.fill;

    final capBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int cap = 0; cap <= 15; cap++) {
      int? pos = capToPosition[cap];
      if (pos != null) {
        Offset point = _getPositionOffset(pos, center, radius);
        canvas.drawCircle(point, 6, capDotPaint);
        canvas.drawCircle(point, 6, capBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
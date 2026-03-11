import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class D15TestScreen extends StatefulWidget {
  const D15TestScreen({super.key});

  @override
  State<D15TestScreen> createState() => _D15TestScreenState();
}

class _D15TestScreenState extends State<D15TestScreen> {
  bool isSaturated = true;
  Color? selectedColor;

  final List<Color> baseColors = [
    const Color(0xFF923E31), // Cap 1 - Red
    const Color(0xFFB24B28), // Cap 2
    const Color(0xFFD05923), // Cap 3
    const Color(0xFFDD701F), // Cap 4
    const Color(0xFFE69818), // Cap 5 - Orange
    const Color(0xFFF0B71C), // Cap 6
    const Color(0xFFF6D022), // Cap 7 - Yellow
    const Color(0xFFEED345), // Cap 8
    const Color(0xFFC9D35E), // Cap 9
    const Color(0xFFA6C47F), // Cap 10
    const Color(0xFF8DB392), // Cap 11
    const Color(0xFF7EB5A8), // Cap 12
    const Color(0xFF5CA9A8), // Cap 13
    const Color(0xFF467AAE), // Cap 14
    const Color(0xFF533AAD), // Cap 15 - Blue/Violet
  ];

  late List<Color?> placedColors;
  final Color referenceColor = const Color.fromARGB(255, 131, 56, 44);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    placedColors = List<Color?>.filled(16, null);
    placedColors[0] = referenceColor;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // ADDED: Confirm exit dialog method
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
    int index = baseColors.indexOf(color);
    if (index != -1) return index + 1;
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
    if (index == 0) return;

    setState(() {
      if (selectedColor != null) {
        for (int i = 1; i < placedColors.length; i++) {
          if (placedColors[i] == selectedColor) {
            placedColors[i] = null;
          }
        }
        if (placedColors[index] == selectedColor) {
          placedColors[index] = null;
        } else {
          placedColors[index] = selectedColor;
        }
        selectedColor = null;
      } else {
        placedColors[index] = null;
      }
    });
  }

  Map<String, dynamic> _calculateResults() {
    Map<int, int> capToPosition = {};
    capToPosition[0] = 0;

    for (int pos = 1; pos < 16; pos++) {
      if (placedColors[pos] != null) {
        int capNum = _getCapNumber(placedColors[pos]!);
        if (capNum != -1) {
          capToPosition[capNum] = pos;
        }
      }
    }

    if (capToPosition.length < 16) {
      return {'complete': false, 'placedCount': capToPosition.length - 1};
    }

    // Count only misplaced caps (caps not in their correct position)
    int totalError = 0;
    List<int> misplacedCaps = [];

    for (int cap = 1; cap <= 15; cap++) {
      int expectedPos = cap; // Cap N should be at position N
      int actualPos = capToPosition[cap]!;

      // If cap is not at expected position, it's an error
      if (actualPos != expectedPos) {
        totalError++;
        misplacedCaps.add(cap);
      }
    }

    int totalCrossings = _calculateCrossings(capToPosition);

    // Calculate errors by color region based on misplaced caps
    int protanErrors = 0;
    int deutanErrors = 0;
    int tritanErrors = 0;

    for (int cap in misplacedCaps) {
      if (cap <= 5)
        protanErrors++; // Red-orange region (caps 1-5)
      else if (cap <= 10)
        deutanErrors++; // Yellow-green region (caps 6-10)
      else
        tritanErrors++; // Blue-green/blue region (caps 11-15)
    }

    String diagnosis;
    Color diagnosisColor;

    if (totalError <= 2) {
      diagnosis = "Normal Color Vision";
      diagnosisColor = Colors.green;
    } else if (protanErrors > deutanErrors && protanErrors > tritanErrors) {
      diagnosis = "Protanomaly (Red Deficiency)";
      diagnosisColor = Colors.red;
    } else if (deutanErrors > protanErrors && deutanErrors > tritanErrors) {
      diagnosis = "Deuteranomaly (Green Deficiency)";
      diagnosisColor = Colors.green;
    } else if (tritanErrors > protanErrors && tritanErrors > deutanErrors) {
      diagnosis = "Tritanomaly (Blue Deficiency)";
      diagnosisColor = Colors.blue;
    } else {
      diagnosis = "Possible Color Vision Deficiency";
      diagnosisColor = Colors.orange;
    }

    return {
      'complete': true,
      'totalError': totalError,
      'totalCrossings': totalCrossings,
      'capToPosition': capToPosition,
      'misplacedCaps': misplacedCaps,
      'diagnosis': diagnosis,
      'diagnosisColor': diagnosisColor,
      'protanErrors': protanErrors,
      'deutanErrors': deutanErrors,
      'tritanErrors': tritanErrors,
    };
  }

  int _calculateCrossings(Map<int, int> capToPosition) {
    int crossings = 0;

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
            // ADDED: Center widget
            child: Text(
              "Please place all ${15 - (results['placedCount'] ?? 0)} remaining colors first",
              textAlign: TextAlign.center, // ADDED: text align center
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ... rest of the method remains the same

    // Force portrait for results
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => D15ResultsScreen(
              totalError: results['totalError'] as int,
              totalCrossings: results['totalCrossings'] as int,
              diagnosis: results['diagnosis'] as String,
              diagnosisColor: results['diagnosisColor'] as Color,
              protanErrors: results['protanErrors'] as int,
              deutanErrors: results['deutanErrors'] as int,
              tritanErrors: results['tritanErrors'] as int,
              capToPosition: results['capToPosition'] as Map<int, int>,
              onRestart: () {
                Navigator.pop(context);
                // Return to landscape for test
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
                setState(() {
                  placedColors = List<Color?>.filled(16, null);
                  placedColors[0] = referenceColor;
                  selectedColor = null;
                });
              },
              onQuit: () {
                // Return to landscape when quitting
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

    return Scaffold(
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
                          "Identify the shapes in each quadrant (Upper Left, Upper Right, Bottom Left, Bottom Right).\nSelect 'Nothing' if no shape is visible.\nSubmit when all quadrants are answered.",
                        ),
                      ),
                );
              },
            ),
          ),
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
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Arrange the colors in smooth transition order from red to blue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize + 4,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _modeButton("Saturated", true, fontSize),
                    const SizedBox(width: 16),
                    _modeButton("Desaturated", false, fontSize),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                baseColors.map((color) {
                                  final isPlaced = placedColors.contains(color);
                                  final displayColor = _applyMode(color);
                                  final isSelected = selectedColor == color;

                                  if (isPlaced)
                                    return const SizedBox(width: 0, height: 0);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _selectColor(color),
                                      child: Container(
                                        width: fontSize * 2.16,
                                        height: fontSize * 2.16,
                                        decoration: BoxDecoration(
                                          color: displayColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? Colors.blue
                                                    : Colors.black,
                                            width: isSelected ? 4 : 1.5,
                                          ),
                                          boxShadow:
                                              isSelected
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.blue
                                                          .withOpacity(0.5),
                                                      blurRadius: 8,
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
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 10,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: List.generate(16, (index) {
                          final isReference = index == 0;
                          final hasColor = placedColors[index] != null;
                          final isEmptySlot =
                              !isReference &&
                              !hasColor &&
                              selectedColor != null;

                          return GestureDetector(
                            onTap: () => _placeColor(index),
                            child: Container(
                              width: fontSize * 2.16,
                              height: fontSize * 2.16,
                              decoration: BoxDecoration(
                                color: _applyMode(
                                  placedColors[index] ??
                                      (isReference
                                          ? referenceColor
                                          : const Color.fromARGB(
                                            255,
                                            241,
                                            234,
                                            234,
                                          )),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isEmptySlot ? Colors.blue : Colors.black,
                                  width: isEmptySlot ? 3 : 1.5,
                                ),
                                boxShadow:
                                    isEmptySlot
                                        ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                        : null,
                              ),
                              child:
                                  isReference
                                      ? const Center(
                                        child: Text(
                                          "REF",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      : null,
                            ),
                          );
                        }),
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
    );
  }

  Widget _modeButton(String text, bool value, double fontSize) {
    final isActive = isSaturated == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isSaturated = value;
          placedColors = List<Color?>.filled(16, null);
          placedColors[0] = referenceColor;
          selectedColor = null;
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

// Results Screen - Portrait orientation with WillPopCallback
class D15ResultsScreen extends StatefulWidget {
  final int totalError;
  final int totalCrossings;
  final String diagnosis;
  final Color diagnosisColor;
  final int protanErrors;
  final int deutanErrors;
  final int tritanErrors;
  final Map<int, int> capToPosition;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const D15ResultsScreen({
    super.key,
    required this.totalError,
    required this.totalCrossings,
    required this.diagnosis,
    required this.diagnosisColor,
    required this.protanErrors,
    required this.deutanErrors,
    required this.tritanErrors,
    required this.capToPosition,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  State<D15ResultsScreen> createState() => _D15ResultsScreenState();
}

class _D15ResultsScreenState extends State<D15ResultsScreen> {
  String _getSeverityFromErrors(int errors) {
    if (errors == 0) return 'Normal';
    if (errors <= 1) return 'Mild';
    if (errors <= 3) return 'Moderate';
    return 'Severe';
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

  Future<bool> _onWillPop() async {
    // Return to landscape when pressing back button
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return true; // Allow the pop to happen
  }

  @override
  Widget build(BuildContext context) {
    String protanStatus = _getSeverityFromErrors(widget.protanErrors);
    String deutanStatus = _getSeverityFromErrors(widget.deutanErrors);
    String tritanStatus = _getSeverityFromErrors(widget.tritanErrors);

    return WillPopScope(
      onWillPop: _onWillPop,
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
                            "Identify the shapes in each quadrant (Upper Left, Upper Right, Bottom Left, Bottom Right).\nSelect 'Nothing' if no shape is visible.\nSubmit when all quadrants are answered.",
                          ),
                        ),
                  );
                },
              ),
            ),
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
                onPressed: () {},
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
                    "Your D15 Color Vision Test Results",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Circular visualization - smaller for portrait
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

                // Results Table
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
                                "Errors",
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
                        // Protan row
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
                                "Red Region (Protan)",
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
                                "${widget.protanErrors}",
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
                                protanStatus,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Deutan row
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
                                "Green Region (Deutan)",
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
                                "${widget.deutanErrors}",
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
                                deutanStatus,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Tritan row
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
                                "Blue Region (Tritan)",
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
                                "${widget.tritanErrors}",
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
                                tritanStatus,
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
                        "Total Error Score: ${widget.totalError} / 15",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Crossings: ${widget.totalCrossings}",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.diagnosis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Interpretation:",
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

                // Buttons
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
                          // Return to landscape when quitting
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
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
      return 'Normal color vision. No restrictions.';
    } else if (totalError <= 5) {
      return 'Mild deficiency. Monitor for changes.';
    } else if (totalError <= 10) {
      return 'Moderate deficiency. May have difficulty with color-critical tasks.';
    } else {
      return 'Significant color vision deficiency. Occupational guidance recommended.';
    }
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

    final circlePaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, circlePaint);

    final dotPaint =
        Paint()
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

    final linePaint =
        Paint()
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

    final capDotPaint =
        Paint()
          ..color = diagnosisColor
          ..style = PaintingStyle.fill;

    final capBorderPaint =
        Paint()
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

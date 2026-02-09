import 'dart:math';
import 'package:flutter/material.dart';

enum ColorBlindType { redGreen, bluePurple, greenPurple }

class MosaicTestScreen extends StatefulWidget {
  const MosaicTestScreen({super.key});

  @override
  State<MosaicTestScreen> createState() => _MosaicTestScreenState();
}

class _MosaicTestScreenState extends State<MosaicTestScreen> {
  static const int gridSize = 12;
  static const int maxDifficulty = 10;

  final Random _random = Random();

  int difficulty = 1;
  ColorBlindType type = ColorBlindType.redGreen;

  Set<int> targetIndices = {};
  List<Color> tiles = [];
  int _attempts = 0;
  bool testEnded = false;

  final Map<ColorBlindType, int> correctTaps = {
    ColorBlindType.redGreen: 0,
    ColorBlindType.bluePurple: 0,
    ColorBlindType.greenPurple: 0,
  };

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  Set<int> _generate2x2Target() {
    final row = _random.nextInt(gridSize - 1);
    final col = _random.nextInt(gridSize - 1);
    final topLeft = row * gridSize + col;
    return {topLeft, topLeft + 1, topLeft + gridSize, topLeft + gridSize + 1};
  }

  void _generateRound() {
    targetIndices = _generate2x2Target();

    // Define base and target colors for each mode
    Color baseColor;
    Color targetColor;

    switch (type) {
      case ColorBlindType.redGreen:
        baseColor = const Color(0xff4caf50); // green
        targetColor = const Color(0xffe53935); // red
        break;
      case ColorBlindType.bluePurple:
        baseColor = const Color(0xff8e24aa); // blue 0xff8e24aa
        targetColor = const Color(0xff7986cb); // purple 0xff7986cb
        break;
      case ColorBlindType.greenPurple:
        baseColor = const Color(0xff8e24aa); // green 0xff4caf50
        targetColor = const Color(0xff4caf50); // purple 0xff8e24aa
        break;
    }

    tiles = List.generate(gridSize * gridSize, (index) {
      final bool isTarget = targetIndices.contains(index);
      Color color = isTarget ? targetColor : baseColor;

      // Apply slight brightness variation for mosaic effect
      double variation = (_random.nextDouble() * 0.2) + 0.9; // 0.9 ~ 1.1
      color = Color.fromARGB(
        color.alpha,
        (color.red * variation).clamp(0, 255).round(),
        (color.green * variation).clamp(0, 255).round(),
        (color.blue * variation).clamp(0, 255).round(),
      );

      return color;
    });
  }

  void _handleTap(int index) {
    if (testEnded) return;
    final bool isTarget = targetIndices.contains(index);

    if (isTarget) {
      correctTaps[type] = (correctTaps[type] ?? 0) + 1;

      if (difficulty >= maxDifficulty) {
        _attempts = 0;
        bool switched = _switchMode();
        if (!switched) {
          _endTest();
        } else {
          _resetTest();
        }
        return;
      }

      setState(() {
        difficulty++;
        _attempts = 0;
        _generateRound();
      });
    } else {
      _attempts++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Try again!"),
          duration: Duration(seconds: 1),
        ),
      );
      if (_attempts >= 2) {
        _attempts = 0;
        bool switched = _switchMode();
        if (!switched) {
          _endTest();
        } else {
          _resetTest();
        }
      }
    }
  }

  bool _switchMode() {
    switch (type) {
      case ColorBlindType.redGreen:
        type = ColorBlindType.bluePurple;
        return true;
      case ColorBlindType.bluePurple:
        type = ColorBlindType.greenPurple;
        return true;
      case ColorBlindType.greenPurple:
        return false;
    }
  }

  void _endTest() {
    setState(() {
      testEnded = true;
    });
  }

  double get progress => (difficulty - 1) / (maxDifficulty - 1);

  void _resetTest() {
    setState(() {
      difficulty = 1;
      _attempts = 0;
      _generateRound();
    });
  }

  void _changeType(ColorBlindType newType) {
    setState(() {
      type = newType;
      _resetTest();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (testEnded) return _buildResultScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF2F3238),
      // ───── APP BAR ─────
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
              color: const Color.fromARGB(255, 40, 50, 56),
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
              onPressed: () => Navigator.pop(context),
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),

      // ───── BODY ─────
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "Tap the different 2×2 square",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridSize * gridSize,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      color: tiles[index],
                    ),
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
                  "Progress: ${(progress * 100).round()}%",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(
                    Colors.lightGreenAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Level: $difficulty / $maxDifficulty",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _showTypeSelector(context),
                child: const Text("I don't see"),
              ),
              ElevatedButton(
                onPressed: _resetTest,
                child: const Text("Restart"),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int totalPossible = maxDifficulty;
    String getPercentage(ColorBlindType t) {
      final value = ((correctTaps[t] ?? 0) / totalPossible * 100).round();
      return "$value%";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2F3238),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 6,
        title: const Text(
          "Test Results",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Table(
                border: TableBorder.all(color: Colors.white),
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Mode",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Score",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Red–Green",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          getPercentage(ColorBlindType.redGreen),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Blue–Purple",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          getPercentage(ColorBlindType.bluePurple),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Green–Purple",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          getPercentage(ColorBlindType.greenPurple),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    testEnded = false;
                    difficulty = 1;
                    _attempts = 0;
                    correctTaps.updateAll((key, value) => 0);
                    _generateRound();
                  });
                },
                child: const Text("Restart"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _typeTile("Red–Green", ColorBlindType.redGreen),
              _typeTile("Blue–Purple", ColorBlindType.bluePurple),
              _typeTile("Green–Purple", ColorBlindType.greenPurple),
            ],
          ),
    );
  }

  ListTile _typeTile(String title, ColorBlindType t) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _changeType(t);
      },
    );
  }
}

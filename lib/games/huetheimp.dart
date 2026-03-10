import 'dart:math';
import 'package:flutter/material.dart';

enum Difficulty { easy, medium, hard }

class Whotheimp extends StatefulWidget {
  const Whotheimp({super.key});

  @override
  State<Whotheimp> createState() => _WhotheimpState();
}

class _WhotheimpState extends State<Whotheimp> {
  final Random _random = Random();

  bool _debugEasyMode = false; // ← set to false when done testing

  // ───── GAME STATE ─────
  int _stage = 1;
  int _lives = 5;
  int _score = 0;
  int _attempts = 0;
  int _correct = 0;

  int _impostorIndex = 0;
  List<Color> _colors = [];
  bool _shakeHearts = false;
  final int _maxLives = 5;

  Difficulty _difficulty = Difficulty.easy;

  // ───── STAGE SETTINGS ─────

  Difficulty _getDifficulty() {
    if (_stage <= 5) return Difficulty.easy;
    if (_stage <= 12) return Difficulty.medium;
    return Difficulty.hard; // stage 13+
  }

  // ───── TOTAL CARDS ─────
  int _gridSize() {
    final difficulty = _getDifficulty();

    switch (difficulty) {
      case Difficulty.easy:
        return _stage <= 5 ? 9 : 12; // 3x3 → 3x4
      case Difficulty.medium:
        return _stage <= 12 ? 12 : 16; // 3x4 → 4x4
      case Difficulty.hard:
        if (_stage <= 20) return 16; // 4x4
        if (_stage <= 39) return 20; // 4x5
        return 24; // 4x6
    }
  }

  // ───── COLUMNS ─────
  int _gridColumns() {
    final difficulty = _getDifficulty();

    switch (difficulty) {
      case Difficulty.easy:
        return 3;
      case Difficulty.medium:
        return 4;
      case Difficulty.hard:
        if (_stage <= 20) return 4; // 4x4
        if (_stage <= 39) return 4; // 4x5
        return 4; // 4x6 (4 columns, 6 rows)
    }
  }

  double _hueDifference() {
    // ✅ DEBUG MODE: make impostor VERY obvious
    if (_debugEasyMode) return 60;

    switch (_difficulty) {
      case Difficulty.easy:
        return max(18 - _stage * 2, 8);
      case Difficulty.medium:
        return max(12 - (_stage - 5), 4);
      case Difficulty.hard:
        return max(6 - (_stage - 12) * .5, 2);
    }
  }

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  // ───── GENERATE COLORS ─────
  // Keep track of previously used base hues per difficulty stage
  final Set<double> _usedBaseHues = {};

  void _generateRound() {
    _difficulty = _getDifficulty();

    double baseHue;
    int attempts = 0;

    // Generate a base hue that hasn't been used recently
    do {
      baseHue = _random.nextDouble() * 360;
      attempts++;
      // safety check to avoid infinite loop if all hues exhausted
      if (attempts > 50) break;
    } while (_usedBaseHues.any((hue) => (hue - baseHue).abs() < 15));

    // Add to used hues
    _usedBaseHues.add(baseHue);
    // Optional: keep only last N hues to prevent memory growth
    if (_usedBaseHues.length > 20) _usedBaseHues.remove(_usedBaseHues.first);

    // Adjusted intensity/value (avoid very light colors)
    final saturation = 0.7; // strong enough to see
    final value = 0.7; // not too light, not too dark

    final baseColor =
        HSVColor.fromAHSV(1, baseHue, saturation, value).toColor();

    final diff = _hueDifference();
    final impostorColor =
        HSVColor.fromAHSV(
          1,
          (baseHue + diff) % 360,
          saturation,
          value,
        ).toColor();

    int grid = _gridSize();
    _impostorIndex = _random.nextInt(grid);

    _colors = List.generate(
      grid,
      (i) => i == _impostorIndex ? impostorColor : baseColor,
    );

    setState(() {});
  }

  // ───── TAP ─────
  void _onTap(int index) {
    _attempts++;

    if (index == _impostorIndex) {
      _correct++;
      _score += 100;
      _stage++;

      _generateRound(); // continue forever
    } else {
      _lives--;

      // trigger shake animation
      setState(() => _shakeHearts = true);

      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _shakeHearts = false);
      });

      if (_lives == 0) {
        _showGameOver();
        return;
      }

      setState(() {});
    }
  }

  double get _accuracy =>
      _attempts == 0 ? 100 : min(100, (_correct / _attempts) * 100);

  // ───── GAME OVER ─────
  void _showGameOver() {
    _showEndDialog("Game Over!");
  }

  // ───── GAME OVER / END DIALOG ─────
  void _showEndDialog(String title) {
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
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ───── MESSAGE ─────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Stage reached: $_stage\n"
                      "Accuracy: ${_accuracy.toStringAsFixed(1)}%\n"
                      "Score: $_score",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
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
                      // Exit Button (RIGHT)
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
                            "Exit",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Restart Button (LEFT)
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
                            _restartGame();
                          },
                          child: const Text(
                            "Restart",
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

  void _restartGame() {
    _stage = 1;
    _lives = 5;
    _score = 0;
    _attempts = 0;
    _correct = 0;
    _generateRound();
  }

  /// ───── CONFIRM EXIT GAME ─────
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

  void _confirmRestartGame() {
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
                                FontWeight.w600, // slightly bolder for emphasis
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

  // ───── UI ─────
  @override
  Widget build(BuildContext context) {
    int grid = _gridSize();
    int cross = _gridColumns();

    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ MATCHES HUE HUNT HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.3),

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
                  color: Colors.black.withValues(alpha: 0.14),
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
              onPressed:
                  _openSettingsMenu, // you can rename to _openSettingsMenu later
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ───── TITLE ─────
            const SizedBox(height: 20),
            const Text(
              "Hue the Impostor",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

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
            const SizedBox(height: 20),

            /// ───── LIVES ─────
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              transform: Matrix4.translationValues(_shakeHearts ? 6 : -6, 0, 0),
              curve: Curves.easeInOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_maxLives, (i) {
                  bool lost = i >= _lives;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder:
                        (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                    child: Padding(
                      key: ValueKey(lost),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        lost ? Icons.favorite_border : Icons.favorite,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            /// 🎯 PREMIUM GAME BOARD CARD
            Center(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grid,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                ),
                itemBuilder:
                    (_, index) => GestureDetector(
                      onTap: () => _onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: _colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openSettingsMenu() {
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
                            "Settings",
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
                          "Accuracy: ${_accuracy.toStringAsFixed(1)}%",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Score: $_score",
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Lives Remaining: $_lives",
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
                        /*
                    DropdownButtonFormField<ColorblindType>(
                      value: _userColorblindType,
                      decoration: const InputDecoration(
                        labelText: "Colorblind Mode",
                        border: OutlineInputBorder(),
                      ),
                      items: ColorblindType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            setState(() => _userColorblindType = value);
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),
*/
                        /// ───── AUDIO ─────
                        const Text(
                          "Audio",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        /*
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Sound FX"),
                      value: _soundFX,
                      onChanged: (v) {
                        setStateDialog(() {
                          setState(() => _soundFX = v);
                        });
                      },
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Music"),
                      value: _music,
                      onChanged: (v) {
                        setStateDialog(() {
                          setState(() => _music = v);
                        });
                      },
                    ),
                     */
                        const SizedBox(height: 22),

                        /// ───── ACTION BUTTONS ─────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// 🔄 Restart Game
                            OutlinedButton.icon(
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

                            const SizedBox(height: 12),

                            /// ❌ Close Settings
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
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text(
                                "Close",
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
}

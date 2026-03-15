import 'package:flutter/material.dart';
import 'package:kulaidoverse/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ColorMixLab extends StatefulWidget {
  const ColorMixLab({super.key});

  @override
  State<ColorMixLab> createState() => _ColorMixLabState();
}

class _ColorMixLabState extends State<ColorMixLab> {
  final SyncService _syncService = SyncService();
  int points = 0;
  late Color leftColor;
  late Color rightColor;
  late Color correctAnswer;
  List<Color> choices = [];
  late Map<Set<Color>, Color> currentMixes;
  String stageLabel = "Easy";
  int _stage = 1;
  int _lives = 5; // current lives
  final int _maxLives = 5; // maximum hearts for the game
  bool _shakeHearts = false; // for wrong answer animation
  int _attempts = 0;
  int _score = 0; // total score

  double get accuracy {
    if (_attempts == 0) return 0;
    return (points / _attempts) * 100;
  }

  // Stage-based color mixes
  final Map<Set<Color>, Color> primaryMixes = {
    {Colors.blue, Colors.red}: Colors.purple,
    {Colors.red, Colors.yellow}: Colors.orange,
    {Colors.blue, Colors.yellow}: Colors.green,
  };

  final Map<Set<Color>, Color> secondaryMixes = {
    {Colors.purple, Colors.red}: Colors.deepPurple,
    {Colors.orange, Colors.red}: Colors.redAccent,
    {Colors.green, Colors.yellow}: Colors.lime,
    {Colors.green, Colors.blue}: Colors.cyan,
  };

  final Map<Set<Color>, Color> tertiaryMixes = {
    {Colors.purple, Colors.orange}: Colors.brown,
    {Colors.orange, Colors.green}: Colors.teal,
    {Colors.green, Colors.purple}: Colors.indigo,
  };

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void updateStage() {
    if (points < 6) {
      currentMixes = {...primaryMixes, ...secondaryMixes};
      stageLabel = "Easy";
    } else if (points < 13) {
      currentMixes = secondaryMixes;
      stageLabel = "Medium";
    } else {
      currentMixes = tertiaryMixes;
      stageLabel = "Hard";
    }
  }

  void generateQuestion() {
    updateStage();

    // Pick a random mix
    final mix = (currentMixes.keys.toList()..shuffle()).first;
    leftColor = mix.first;
    rightColor = mix.last;
    correctAnswer = currentMixes[mix]!;

    // Only 3 options
    choices = [correctAnswer];
    final otherOptions =
        currentMixes.values.toSet().toList()..remove(correctAnswer);
    otherOptions.shuffle();
    choices.addAll(otherOptions.take(2));
    choices.shuffle();

    setState(() {});
  }

  void checkAnswer(Color selected) {
    _attempts++;

    if (selected == correctAnswer) {
      points++;
      _score += 100; // add score
      _stage++;
      generateQuestion();
    } else {
      _lives--;

      // heart shake animation
      setState(() => _shakeHearts = true);

      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _shakeHearts = false);
      });

      if (_lives <= 0) {
        _showEndDialog("Game Over!");
        return;
      }

      generateQuestion();
    }

    setState(() {});
  }

  void _showEndDialog(String title) {
    final int totalQuestions = points + (_maxLives - _lives); // correct + wrong
    final double accuracy = _attempts == 0 ? 0 : (points / _attempts) * 100;
    _saveGameResult();

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
                      "Accuracy: ${accuracy.toStringAsFixed(1)}%\n"
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

  Future<void> _saveGameResult() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await _syncService.saveGameResult(
      userId: user.id,
      gameType: 'color mixing lab',
      stageReached: _stage,
      score: _score,
      accuracy: accuracy,
    );

    print('Game saved! Stage: $_stage, Score: $_score, Accuracy: $accuracy%');
  }

  Widget colorCircle(
    Color color, {
    double radius = 28,
    bool showBorder = false,
  }) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.black54, width: 2) : null,
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
                          "Accuracy: ${accuracy.toStringAsFixed(1)}%",
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
        backgroundColor: Colors.white,
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
                icon: const Icon(Icons.question_mark, color: Colors.white),
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
                onPressed: _openSettingsMenu,
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Color Mixing Lab",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_stage % 10) / 10,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Hearts
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              transform: Matrix4.translationValues(_shakeHearts ? 6 : -6, 0, 0),
              curve: Curves.easeInOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_maxLives, (i) {
                  bool lost = i >= _lives; // gray heart if lost
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

            /// Question Card
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color equation row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      colorCircle(leftColor, radius: 40, showBorder: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text("+", style: TextStyle(fontSize: 28)),
                      ),
                      colorCircle(rightColor, radius: 40, showBorder: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text("=", style: TextStyle(fontSize: 28)),
                      ),
                      colorCircle(
                        Colors.grey[300]!,
                        radius: 40,
                        showBorder: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Color choices
                  Wrap(
                    spacing: 28,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children:
                        choices
                            .map(
                              (c) => GestureDetector(
                                onTap: () => checkAnswer(c),
                                child: colorCircle(
                                  c,
                                  radius: 38,
                                  showBorder: true,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void _restartGame() {
    setState(() {
      points = 0;
      _stage = 1;
      _lives = _maxLives; // reset hearts to max
      generateQuestion();
    });
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
}

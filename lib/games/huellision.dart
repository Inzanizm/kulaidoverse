import 'dart:math';
import 'package:flutter/material.dart';

class Huellision extends StatefulWidget {
  const Huellision({super.key});

  @override
  State<Huellision> createState() => _HuellisionState();
}

enum Difficulty { easy, medium, hard }

class HuellisionQuestion {
  final List<String> choices;

  HuellisionQuestion({required this.choices});
}

class _HuellisionState extends State<Huellision> {
  final Random _random = Random();

  int _stage = 1;
  int _score = 0;
  int _lives = 3;
  int _attempts = 0;
  int _correct = 0;

  final int _maxLives = 3;

  HuellisionQuestion? currentQuestion;
  String? selectedAnswer;

  bool _shakeHearts = false;

  Color _backgroundColor = Colors.green;
  Color _wordColor = Colors.red;

  String? _correctWord;

  Difficulty _getDifficulty() {
    if (_stage <= 5) return Difficulty.easy;
    if (_stage <= 12) return Difficulty.medium;
    return Difficulty.hard;
  }

  // EASY
  final List<HuellisionQuestion> easyQuestions = [
    HuellisionQuestion(choices: ['Boat', 'Boar', 'Boot']),
    HuellisionQuestion(choices: ['Tree', 'Free', 'Three']),
    HuellisionQuestion(choices: ['Star', 'Scar', 'Stir']),
    HuellisionQuestion(choices: ['Ball', 'Bell', 'Bill']),
    HuellisionQuestion(choices: ['Seat', 'Seed', 'Said']),
    HuellisionQuestion(choices: ['Bake', 'Bike', 'Bark']),
  ];

  // MEDIUM
  final List<HuellisionQuestion> mediumQuestions = [
    HuellisionQuestion(choices: ['Plane', 'Plain', 'Plan']),
    HuellisionQuestion(choices: ['Sight', 'Site', 'Sigh']),
    HuellisionQuestion(choices: ['Stone', 'Shone', 'Stony']),
    HuellisionQuestion(choices: ['Brake', 'Break', 'Brick']),
    HuellisionQuestion(choices: ['Peace', 'Piece', 'Peach']),
    HuellisionQuestion(choices: ['Weather', 'Whether', 'Feather']),
  ];

  // HARD
  final List<HuellisionQuestion> hardQuestions = [
    HuellisionQuestion(choices: ['Desert', 'Dessert', 'Insert']),
    HuellisionQuestion(choices: ['Station', 'Nation', 'Caution']),
    HuellisionQuestion(choices: ['Vision', 'Division', 'Revision']),
    HuellisionQuestion(choices: ['Accept', 'Except', 'Expect']),
    HuellisionQuestion(choices: ['Affect', 'Effect', 'Defect']),
    HuellisionQuestion(choices: ['Complement', 'Compliment', 'Implement']),
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    Difficulty difficulty = _getDifficulty();

    List<HuellisionQuestion> pool = [];

    switch (difficulty) {
      case Difficulty.easy:
        pool.addAll(easyQuestions);
        break;

      case Difficulty.medium:
        pool.addAll(easyQuestions);
        pool.addAll(mediumQuestions);
        break;

      case Difficulty.hard:
        pool.addAll(easyQuestions);
        pool.addAll(mediumQuestions);
        pool.addAll(hardQuestions);
        break;
    }

    HuellisionQuestion base = pool[_random.nextInt(pool.length)];

    List<String> shuffledChoices = List.from(base.choices);
    shuffledChoices.shuffle();

    String correctWord =
        shuffledChoices[_random.nextInt(shuffledChoices.length)];

    currentQuestion = HuellisionQuestion(choices: shuffledChoices);

    selectedAnswer = null;

    // Save the correct word
    _correctWord = correctWord;

    // COLORS
    double baseHue = _random.nextDouble() * 360;
    double diff = _hueDifference();

    HSVColor bgHSV = HSVColor.fromAHSV(1, baseHue, 0.65, 0.65);
    HSVColor wordHSV = HSVColor.fromAHSV(1, (baseHue + diff) % 360, 0.65, 0.65);

    _backgroundColor = bgHSV.toColor();
    _wordColor = wordHSV.toColor();

    setState(() {});
  }

  double get _accuracy =>
      _attempts == 0 ? 100 : min(100, (_correct / _attempts) * 100);

  void _submitAnswer() {
    if (selectedAnswer == null) return;

    _attempts++;

    if (selectedAnswer == _correctWord) {
      _correct++;
      _score += 100;
      _stage++;

      selectedAnswer = null;

      _generateQuestion();
    } else {
      _lives--;

      setState(() => _shakeHearts = true);

      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _shakeHearts = false);
      });

      if (_lives == 0) {
        _showGameOver();
        return;
      }

      selectedAnswer = null;
    }

    setState(() {});
  }

  void _showGameOver() {
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
                children: [
                  const Text(
                    "Game Over!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text("Stage reached: $_stage"),
                  Text("Score: $_score"),
                  Text("Accuracy: ${_accuracy.toStringAsFixed(1)}%"),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text("Exit"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _restartGame();
                          },
                          child: const Text("Restart"),
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
    _score = 0;
    _lives = 3;
    _attempts = 0;
    _correct = 0;

    _generateQuestion();
  }

  double _hueDifference() {
    final difficulty = _getDifficulty();

    switch (difficulty) {
      case Difficulty.easy:
        return max(120 - _stage * 10, 60);
      // VERY different colors (easy to see)

      case Difficulty.medium:
        return max(60 - (_stage - 5) * 5, 25);

      case Difficulty.hard:
        return max(25 - (_stage - 12) * 1.5, 6);
      // almost same color
    }
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

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) return const SizedBox();

    return PopScope<Object?>(
      // Add generic type <Object?>
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // New callback with result parameter
        if (didPop) return;
        _confirmExitGame();
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff2f2f2),
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                const Text(
                  'Huellision',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text("Stage $_stage"),

                const SizedBox(height: 16),

                LinearProgressIndicator(
                  value: (_stage % 10) / 10,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  color: Colors.black,
                ),

                const SizedBox(height: 18),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  transform: Matrix4.translationValues(
                    _shakeHearts ? 6 : -6,
                    0,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_maxLives, (i) {
                      bool lost = i >= _lives;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          lost ? Icons.favorite_border : Icons.favorite,
                          color: Colors.black,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 24),

                _buildCard(),

                const SizedBox(height: 24),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
                        "A word appears inside the colored circle.\n"
                        "Choose the matching word from the options.\n"
                        "Words are similar and colors get harder each stage.\n"
                        "You have 3 lives.",
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
    );
  }

  Widget _buildCard() {
    final question = currentQuestion!;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff3c3f45),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'What is the word inside the circle',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildIshiharaCircle(_correctWord!),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: question.choices.map(_answerButton).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIshiharaCircle(String word) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColor,
      ),
      alignment: Alignment.center,
      child: Text(
        word,
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: _wordColor,
        ),
      ),
    );
  }

  Widget _answerButton(String text) {
    final isSelected = selectedAnswer == text;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : const Color(0xff4a4d52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () => setState(() => selectedAnswer = text),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff3c3f45),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: _submitAnswer,
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}

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
  int _lives = 5;
  int _attempts = 0;
  int _correct = 0;

  final int _maxLives = 5;

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

  // WORD POOLS
  final List<HuellisionQuestion> easyQuestions = [
    HuellisionQuestion(choices: ['Boat', 'Boar', 'Boot']),
    HuellisionQuestion(choices: ['Tree', 'Free', 'Three']),
    HuellisionQuestion(choices: ['Star', 'Scar', 'Stir']),
  ];

  final List<HuellisionQuestion> mediumQuestions = [
    HuellisionQuestion(choices: ['Plane', 'Plain', 'Plan']),
    HuellisionQuestion(choices: ['Sight', 'Site', 'Sigh']),
    HuellisionQuestion(choices: ['Stone', 'Shone', 'Stony']),
  ];

  final List<HuellisionQuestion> hardQuestions = [
    HuellisionQuestion(choices: ['Desert', 'Dessert', 'Insert']),
    HuellisionQuestion(choices: ['Station', 'Nation', 'Caution']),
    HuellisionQuestion(choices: ['Vision', 'Division', 'Revision']),
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    Difficulty difficulty = _getDifficulty();

    List<HuellisionQuestion> pool;

    switch (difficulty) {
      case Difficulty.easy:
        pool = easyQuestions;
        break;
      case Difficulty.medium:
        pool = mediumQuestions;
        break;
      case Difficulty.hard:
        pool = hardQuestions;
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
    _lives = 5;
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

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) return const SizedBox();

    return Scaffold(
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
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 40, 50, 56),
            borderRadius: BorderRadius.circular(10),
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
      title: const Text(
        'KULAIDOVERSE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
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

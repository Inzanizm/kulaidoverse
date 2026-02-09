import 'package:flutter/material.dart';

class ColorMixLab extends StatefulWidget {
  const ColorMixLab({super.key});

  @override
  State<ColorMixLab> createState() => _ColorMixLabState();
}

class _ColorMixLabState extends State<ColorMixLab> {
  int points = 0;
  int lives = 3;

  late Color leftColor;
  late Color rightColor;
  late Color correctAnswer;

  List<Color> choices = [];

  final Map<Set<Color>, Color> colorMixes = {
    {Colors.blue, Colors.red}: Colors.purple,
    {Colors.red, Colors.yellow}: Colors.orange,
    {Colors.blue, Colors.yellow}: Colors.green,
  };

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    final mix = (colorMixes.keys.toList()..shuffle()).first;

    leftColor = mix.first;
    rightColor = mix.last;
    correctAnswer = colorMixes[mix]!;

    choices = colorMixes.values.toSet().toList();
    choices.shuffle();

    if (!choices.contains(correctAnswer)) {
      choices[0] = correctAnswer;
    }

    setState(() {});
  }

  void checkAnswer(Color selected) {
    if (selected == correctAnswer) {
      points++;
    } else {
      lives--;
    }

    if (lives == 0) {
      showGameOver();
    } else {
      generateQuestion();
    }
  }

  void showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("Game Over"),
            content: Text("Final Score: $points"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    points = 0;
                    lives = 3;
                    generateQuestion();
                  });
                },
                child: const Text("Play Again"),
              ),
            ],
          ),
    );
  }

  Widget colorCircle(Color color) {
    return CircleAvatar(radius: 28, backgroundColor: color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Color Mixing Lab",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            "$points points",
            style: TextStyle(fontSize: 20, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, color: Colors.black26),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Guess the outcome",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      colorCircle(leftColor),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "+",
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      colorCircle(rightColor),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "=",
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    children:
                        choices
                            .map(
                              (c) => GestureDetector(
                                onTap: () => checkAnswer(c),
                                child: colorCircle(c),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Icon(
                Icons.favorite,
                color: index < lives ? Colors.red : Colors.grey,
                size: 32,
              );
            }),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

class Whotheimp extends StatefulWidget {
  const Whotheimp({super.key});

  @override
  State<Whotheimp> createState() => _WhotheimpState();
}

class _WhotheimpState extends State<Whotheimp> {
  final Random _random = Random();

  int score = 0;
  int impostorIndex = 0;
  List<Color> colors = [];

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    final baseHue = _random.nextDouble() * 360;
    final difficulty = max(4, 40 - score * 2);

    final baseColor = HSVColor.fromAHSV(1, baseHue, 0.65, 0.9).toColor();
    final impostorHue = (baseHue + difficulty) % 360;
    final impostorColor =
        HSVColor.fromAHSV(1, impostorHue, 0.65, 0.9).toColor();

    impostorIndex = _random.nextInt(4);

    colors = List.generate(
      4,
      (i) => i == impostorIndex ? impostorColor : baseColor,
    );

    setState(() {});
  }

  void _onTap(int index) {
    if (index == impostorIndex) {
      score++;
      _generateRound();
    } else {
      _showGameOver();
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text("Game Over"),
            content: Text("Your score: $score"),
            actions: [
              TextButton(
                onPressed: () {
                  score = 0; // reset score
                  _generateRound();
                  Navigator.of(context).pop(); // close dialog
                },
                child: const Text("Retry"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // exit "Hue the Impostor" screen
                },
                child: const Text("Exit"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "Hue the Impostor",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text("$score points"),
          const SizedBox(height: 12),
          const Text("Find the impostor"),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 260, // 👈 slightly bigger
              height: 260,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xff2b2f33),
                borderRadius: BorderRadius.circular(18),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

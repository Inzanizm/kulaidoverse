import 'package:flutter/material.dart';

class Lanterntest extends StatefulWidget {
  const Lanterntest({super.key});

  @override
  State<Lanterntest> createState() => _LanterntestState();
}

class _LanterntestState extends State<Lanterntest> {
  String upAnswer = "";
  String downAnswer = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.5),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 40, 50, 56),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Colors.white,
              ),
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
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 16),

              const Text(
                "Lantern Test",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // MAIN CARD
              Container(
                width: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 40, 50, 56),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // INSTRUCTION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            "Instruction",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "The test consists of showing 9 pairs of vertically "
                            "oriented lights. Combinations of either red, green "
                            "or yellow. Identify the colors up and down.\n\n"
                            "The colors are shown for only two seconds.\n\n"
                            "Example:\nUp - red, Down - green\n\n"
                            "Click submit to continue.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "1/9",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // BLURRED LANTERN LIGHTS
                    Column(
                      children: [
                        _lanternLight(Colors.red),
                        const SizedBox(height: 30),
                        _lanternLight(Colors.yellow),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // UP BUTTONS
                    Row(
                      children: [
                        const Text(
                          "UP:",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        _colorButton("Red", true),
                        _colorButton("Green", true),
                        _colorButton("Yellow", true),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // DOWN BUTTONS
                    Row(
                      children: [
                        const Text(
                          "DOWN:",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 2),
                        _colorButton("Red", false),
                        _colorButton("Green", false),
                        _colorButton("Yellow", false),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: 140,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          debugPrint("UP: $upAnswer | DOWN: $downAnswer");
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LANTERN LIGHT WITH BLUR
  Widget _lanternLight(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 14,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }

  // COLOR BUTTON
  Widget _colorButton(String text, bool isUp) {
    bool selected = isUp ? upAnswer == text : downAnswer == text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 34,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? Colors.blue : Colors.white,
            foregroundColor: selected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            setState(() {
              if (isUp) {
                upAnswer = text;
              } else {
                downAnswer = text;
              }
            });
          },
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}

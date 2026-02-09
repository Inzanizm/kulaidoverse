import 'package:flutter/material.dart';

class Tonetrail extends StatefulWidget {
  const Tonetrail({super.key});

  @override
  State<Tonetrail> createState() => _TonetrailState();
}

class _TonetrailState extends State<Tonetrail> {
  // Correct gradient order (Red → Orange)
  final List<Color> correctOrder = [
    const Color(0xFFFF3B30),
    const Color(0xFFFF5E3A),
    const Color(0xFFFF7A45),
    const Color(0xFFFF9F1C),
    const Color(0xFFFFB347),
    const Color(0xFFFFC971),
  ];

  late List<Color> draggableColors;
  List<Color?> slots = List.filled(6, null);

  @override
  void initState() {
    super.initState();
    draggableColors = List.from(correctOrder)..shuffle();
  }

  void checkAnswer() {
    if (slots.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Fill all slots first 👀", textAlign: TextAlign.center),
        ),
      );
      return;
    }

    bool correct = true;
    for (int i = 0; i < slots.length; i++) {
      if (slots[i] != correctOrder[i]) {
        correct = false;
        break;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: correct ? Colors.green : Colors.red,
        content: Text(
          correct ? "Perfect Gradient! 🎉" : "Try Again 👀",
          textAlign: TextAlign.center,
        ),
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
            decoration: BoxDecoration(
              color: const Color(0xFF283238),
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text("1 / 12", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),

          // ───── GAME CARD ─────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2F33),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Arrange the color by gradient",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Red – Orange",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ───── DROP SLOTS (ONE COLOR ONLY) ─────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(slots.length, (index) {
                    return DragTarget<Color>(
                      onWillAccept: (_) => slots[index] == null,
                      onAccept: (color) {
                        setState(() {
                          slots[index] = color;
                          draggableColors.remove(color);
                        });
                      },
                      builder: (_, candidateData, __) {
                        return GestureDetector(
                          // Tap to remove color (undo)
                          onTap: () {
                            if (slots[index] != null) {
                              setState(() {
                                draggableColors.add(slots[index]!);
                                slots[index] = null;
                              });
                            }
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                                  slots[index] ??
                                  (candidateData.isNotEmpty
                                      ? Colors.white54
                                      : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // ───── DRAGGABLE COLORS (CENTERED, 2 ROWS MAX) ─────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        draggableColors.map((color) {
                          return Draggable<Color>(
                            data: color,
                            feedback: colorTile(color, dragging: true),
                            childWhenDragging: colorTile(Colors.grey.shade300),
                            child: colorTile(color),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ───── SUBMIT BUTTON ─────
          ElevatedButton(
            onPressed: checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2F33),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget colorTile(Color color, {bool dragging = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            dragging
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
      ),
    );
  }
}

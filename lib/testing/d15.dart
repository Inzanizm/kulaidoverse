import 'package:flutter/material.dart';

class D15TestScreen extends StatefulWidget {
  const D15TestScreen({super.key});

  @override
  State<D15TestScreen> createState() => _D15TestScreenState();
}

class _D15TestScreenState extends State<D15TestScreen> {
  bool isSaturated = true;

  final List<Color> baseColors = [
    const Color(0xFFB7C8A1),
    const Color(0xFF9ED0C1),
    const Color(0xFFE7B7D4),
    const Color(0xFFE6C4A2),
    const Color(0xFFB4D3B2),
    const Color(0xFFF1B8C8),
    const Color(0xFFAED9DF),
    const Color(0xFFF0B3B0),
    const Color(0xFFD4C1E8),
    const Color(0xFFADD6E2),
    const Color(0xFFE6B8D0),
    const Color(0xFFE4D1A3),
    const Color(0xFFADD6E2),
    const Color(0xFFB3E0CC),
    const Color(0xFFF1B9A8),
  ];

  List<Color?> placedColors = List.generate(15, (_) => null);

  Color _applyMode(Color color) {
    if (isSaturated) return color;
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(0.2).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.5),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      backgroundColor: const Color(0xFF2E3035),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 900,
            decoration: BoxDecoration(
              color: const Color(0xFF2E3035),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "D15 colorblindness test",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "1. Select a color from the top row.\n"
                  "2. Tap a spot on the bottom line to place it.\n"
                  "3. Continue until all colors are arranged.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),

                /// MODE TOGGLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _modeButton("Saturated", true),
                    const SizedBox(width: 12),
                    _modeButton("Desaturated", false),
                  ],
                ),

                const SizedBox(height: 30),

                /// TOP ROW (DRAGGABLE COLORS)
                Wrap(
                  spacing: 10,
                  children:
                      baseColors.map((color) {
                        final displayColor = _applyMode(color);
                        return Draggable<Color>(
                          data: displayColor,
                          feedback: _colorBox(displayColor),
                          childWhenDragging: _colorBox(
                            displayColor.withOpacity(0.3),
                          ),
                          child: _colorBox(displayColor),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 20),

                /// BOTTOM ROW (DROP TARGETS)
                Wrap(
                  spacing: 10,
                  children: List.generate(15, (index) {
                    return DragTarget<Color>(
                      onAcceptWithDetails: (details) {
                        setState(() {
                          placedColors[index] = details.data;
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return _colorBox(
                          placedColors[index] ?? const Color(0xFFE0E0E0),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 30),

                /// SUBMIT BUTTON
                ElevatedButton(
                  onPressed: () {
                    // TODO: Evaluate result logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    child: Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String text, bool value) {
    final isActive = isSaturated == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isSaturated = value;
          placedColors = List.generate(15, (_) => null);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.white : Colors.grey[700],
        foregroundColor: isActive ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text),
    );
  }

  Widget _colorBox(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

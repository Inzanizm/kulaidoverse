import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'd15.dart';

class D15TestMenuScreen extends StatefulWidget {
  const D15TestMenuScreen({super.key});

  @override
  State<D15TestMenuScreen> createState() => _D15TestMenuScreenState();
}

class _D15TestMenuScreenState extends State<D15TestMenuScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }


void _confirmExitTest() {
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
                  const Center(
                    child: Text(
                      "Quit Test?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  Row(
                    children: [
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
                            Navigator.pop(context);
                            Navigator.pop(context);
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
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),

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
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final fontSize = (width + height) / 80;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3035),
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
                color: const Color(0xFF283238),
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
                onPressed: _confirmExitTest,
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF283238),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
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
                          title: Text("Tutorial:"),
                          content: Text(
                            "A pair of colored lights will appear on the screen. Carefully observe the colors shown and select the correct color combination from the given options. Continue until all light pairs have been identified.",
                          ),
                        ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF283238),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
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
                          title: Text("Disclaimer and Purpose"),
                          content: Text(
                            "Disclaimer:\n"
                            "The color vision tests in KulaidoVerse are for screening and educational purposes only and are not intended to provide a medical diagnosis. Results may vary depending on device display, brightness, and lighting conditions. For an accurate assessment, please consult a qualified eye care professional or ophthalmologist.\n\n"
                            "Purpose:\n"
                            "The Lantern Test assesses a person's ability to recognize and distinguish colored signal lights, usually red, green, and white. By identifying these lights correctly, the test helps determine whether an individual can reliably recognize colors used in transportation and safety signaling.",
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Select D-15 Test Type",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize + 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose a specific color region to evaluate",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Protan Test Card
               // Protan Test Card - Black & White UI
_buildTestCard(
  context,
  testType: D15TestType.protan,
  title: "Protan Test",
  subtitle: "Red Vision",
  description: "Evaluates ability to distinguish red hues. Detects L-cone (red) deficiencies.",
  icon: Icons.visibility,
  fontSize: fontSize,
  accentColor: const Color(0xFF8B2635), // Subtle red accent
),

const SizedBox(height: 16),

// Deutan Test Card - Black & White UI
_buildTestCard(
  context,
  testType: D15TestType.deutan,
  title: "Deutan Test",
  subtitle: "Green Vision",
  description: "Evaluates ability to distinguish green hues. Detects M-cone (green) deficiencies.",
  icon: Icons.visibility,
  fontSize: fontSize,
  accentColor: const Color(0xFF006400), // Subtle green accent
),

const SizedBox(height: 16),

// Tritan Test Card - Black & White UI
_buildTestCard(
  context,
  testType: D15TestType.tritan,
  title: "Tritan Test",
  subtitle: "Blue Vision",
  description: "Evaluates ability to distinguish blue hues. Detects S-cone (blue) deficiencies.",
  icon: Icons.visibility,
  fontSize: fontSize,
  accentColor: const Color(0xFF191970), // Subtle blue accent
),

                // Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3F4B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Why three separate tests?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Each test isolates a specific color region for precise diagnosis. "
                        "Protan and Deutan are the most common deficiencies (red-green), "
                        "while Tritan is rarer but important for complete assessment.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: fontSize - 2,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildTestCard(
  BuildContext context, {
  required D15TestType testType,
  required String title,
  required String subtitle,
  required String description,
  required IconData icon,
  required double fontSize,
  required Color accentColor, // Subtle accent color for the test type
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: Colors.white, // White background
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => D15TestScreen(testType: testType),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon container with subtle accent color
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1), // Very subtle accent
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.black, // Black icon
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black, // Black text
                        fontSize: fontSize + 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtitle with accent color instead of black
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: accentColor, // Accent color for subtitle
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.black54, // Gray text for description
                        fontSize: fontSize - 2,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white, // White arrow on black background
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
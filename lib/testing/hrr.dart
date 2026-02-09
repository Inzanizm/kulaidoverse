import 'package:flutter/material.dart';

class HRRScreen extends StatefulWidget {
  const HRRScreen({super.key});

  @override
  State<HRRScreen> createState() => _HRRScreenState();
}

class _HRRScreenState extends State<HRRScreen> {
  String? topLeft;
  String? topRight;
  String? bottomLeft;
  String? bottomRight;

  final List<String> choices = ["Nothing", "Triangle", "Circle", "<", ">"];

  bool get allSelected =>
      topLeft != null &&
      topRight != null &&
      bottomLeft != null &&
      bottomRight != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ───── APP BAR ─────
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

      // ───── BODY ─────
      body: Column(
        children: [
          const SizedBox(height: 12),

          const Text(
            "What do you see?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // ───── IMAGE ─────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F3238), // dark card background
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/logo/hrrt.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Choose an answer",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          // ───── DROPDOWNS ─────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _dropdownBox(
                        label: "Top left",
                        value: topLeft,
                        onChanged: (v) => setState(() => topLeft = v),
                        items: choices,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _dropdownBox(
                        label: "Top right",
                        value: topRight,
                        onChanged: (v) => setState(() => topRight = v),
                        items: choices,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _dropdownBox(
                        label: "Bottom left",
                        value: bottomLeft,
                        onChanged: (v) => setState(() => bottomLeft = v),
                        items: choices,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _dropdownBox(
                        label: "Bottom right",
                        value: bottomRight,
                        onChanged: (v) => setState(() => bottomRight = v),
                        items: choices,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ───── SUBMIT ─────
          SizedBox(
            width: 220,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  allSelected
                      ? () {
                        debugPrint("""
Top Left: $topLeft
Top Right: $topRight
Bottom Left: $bottomLeft
Bottom Right: $bottomRight
""");
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F3238),
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ───── DROPDOWN BOX ─────
  Widget _dropdownBox({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text("Nothing"),
              isExpanded: true,
              items:
                  items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

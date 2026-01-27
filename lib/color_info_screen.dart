import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorInfoScreen extends StatelessWidget {
  final Color color;
  final String name;
  final String hex;
  final String rgb;
  final String cmyk;

  const ColorInfoScreen({
    super.key,
    required this.color,
    required this.name,
    required this.hex,
    required this.rgb,
    required this.cmyk,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Info'),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color preview
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),

            _infoRow(context, 'Name', name),
            _infoRow(context, 'HEX', hex),
            _infoRow(context, 'RGB', rgb),
            _infoRow(context, 'CMYK', cmyk),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // LEFT: Label
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),

          // Push everything else to the far right
          const Spacer(),

          // RIGHT: Value + Copy icon grouped
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: Colors.white70,
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied'),
                      duration: const Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

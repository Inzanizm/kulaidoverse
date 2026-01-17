import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ColorCameraScreen extends StatefulWidget {
  const ColorCameraScreen({super.key});

  @override
  State<ColorCameraScreen> createState() => _ColorCameraScreenState();
}

class _ColorCameraScreenState extends State<ColorCameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _processingFrame = false;
  bool _isSwitching = false;
  Timer? _throttleTimer;

  // Live values
  Color _currentColor = Colors.white;
  String _colorName = 'White';
  String _hex = '#FFFFFF';
  String _rgb = '(255, 255, 255)';
  String _cmyk = '(0, 0, 0, 0)';

  /// Base named color palette
  final List<Map<String, dynamic>> _namedColors = [
    // Primary & basic
    {'name': 'Red', 'r': 255, 'g': 0, 'b': 0},
    {'name': 'Orange', 'r': 255, 'g': 165, 'b': 0},
    {'name': 'Yellow', 'r': 255, 'g': 255, 'b': 0},
    {'name': 'Green', 'r': 0, 'g': 128, 'b': 0},
    {'name': 'Cyan', 'r': 0, 'g': 255, 'b': 255},
    {'name': 'Blue', 'r': 0, 'g': 0, 'b': 255},
    {'name': 'Magenta', 'r': 255, 'g': 0, 'b': 255},

    // Purple family
    {'name': 'Purple', 'r': 128, 'g': 0, 'b': 128},
    {'name': 'Lavender', 'r': 230, 'g': 230, 'b': 250},
    {'name': 'Lilac', 'r': 200, 'g': 162, 'b': 200},
    {'name': 'Indigo', 'r': 75, 'g': 0, 'b': 130},
    {'name': 'Violet', 'r': 143, 'g': 0, 'b': 255},

    // Neutrals & metallic
    {'name': 'White', 'r': 255, 'g': 255, 'b': 255},
    {'name': 'Black', 'r': 0, 'g': 0, 'b': 0},
    {'name': 'Grey', 'r': 128, 'g': 128, 'b': 128},
    {'name': 'Silver', 'r': 192, 'g': 192, 'b': 192},

    // Warm colors
    {'name': 'Pink', 'r': 255, 'g': 192, 'b': 203},
    {'name': 'Maroon', 'r': 128, 'g': 0, 'b': 0},
    {'name': 'Brown', 'r': 139, 'g': 69, 'b': 19},
    {'name': 'Beige', 'r': 245, 'g': 245, 'b': 220},
    {'name': 'Tan', 'r': 210, 'g': 180, 'b': 140},
    {'name': 'Peach', 'r': 255, 'g': 218, 'b': 185},

    // Greens & blues
    {'name': 'Lime', 'r': 0, 'g': 255, 'b': 0},
    {'name': 'Olive', 'r': 128, 'g': 128, 'b': 0},
    {'name': 'Turquoise', 'r': 64, 'g': 224, 'b': 208},
    {'name': 'Teal', 'r': 0, 'g': 128, 'b': 128},
    {'name': 'Navy Blue', 'r': 0, 'g': 0, 'b': 128},
    {'name': 'Chartreuse', 'r': 127, 'g': 255, 'b': 0},
  ];

  /// Precomputed LAB palette (fast lookup)
  late final List<Map<String, dynamic>> _namedColorsLab;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    // Precompute LAB values once
    _namedColorsLab =
        _namedColors.map((c) {
          final lab = _rgbToLab(c['r'], c['g'], c['b']);
          return {'name': c['name'], 'l': lab[0], 'a': lab[1], 'b': lab[2]};
        }).toList();
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      back,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (!mounted) return;

    setState(() => _isReady = true);
    _controller!.startImageStream(_processCameraImage);
  }

  void _processCameraImage(CameraImage image) {
    if (_processingFrame) return;
    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer = Timer(const Duration(milliseconds: 200), () {});
    _processingFrame = true;

    try {
      final rgb = _getCenterPixelColorFromImage(image);
      if (rgb == null) return;

      final r = rgb[0], g = rgb[1], b = rgb[2];
      final name = _nearestColorName(r, g, b);

      setState(() {
        _currentColor = Color.fromARGB(255, r, g, b);
        _hex = _rgbToHex(r, g, b);
        _rgb = '($r, $g, $b)';
        _cmyk = _rgbToCmyk(r, g, b).map((v) => v.toStringAsFixed(0)).join(', ');
        _colorName = name;
      });
    } finally {
      _processingFrame = false;
    }
  }

  Future<void> _switchCamera() async {
    if (_isSwitching) return;
    _isSwitching = true;

    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        _isSwitching = false;
        return;
      }

      final cameras = await availableCameras();
      if (cameras.length < 2) {
        _isSwitching = false;
        return;
      }

      final current = _controller!.description;

      // Switch front <-> back
      final newDescription = cameras.firstWhere(
        (c) => c.lensDirection != current.lensDirection,
        orElse: () => current,
      );

      if (newDescription == current) {
        _isSwitching = false;
        return;
      }

      // Stop stream
      try {
        await _controller!.stopImageStream();
      } catch (_) {}

      // Dispose old controller
      final old = _controller;
      _controller = null; // prevents preview rebuild on disposed controller
      setState(() {});

      await old?.dispose();

      // Initialize new controller
      final cam = CameraController(
        newDescription,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
      );

      await cam.initialize();
      if (!mounted) return;

      _controller = cam;
      setState(() {});

      // Restart stream
      await _controller!.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint("Camera switch error: $e");
    } finally {
      _isSwitching = false;
    }
  }

  /// -------- LAB COLOR MATCHING --------

  List<double> _rgbToHsl(int r, int g, int b) {
    double rf = r / 255.0;
    double gf = g / 255.0;
    double bf = b / 255.0;

    double maxVal = max(rf, max(gf, bf));
    double minVal = min(rf, min(gf, bf));
    double delta = maxVal - minVal;

    double h = 0.0;
    if (delta != 0) {
      if (maxVal == rf) {
        h = 60 * (((gf - bf) / delta) % 6);
      } else if (maxVal == gf) {
        h = 60 * (((bf - rf) / delta) + 2);
      } else {
        h = 60 * (((rf - gf) / delta) + 4);
      }
    }
    if (h < 0) h += 360;

    double l = (maxVal + minVal) / 2;

    double s = (delta == 0) ? 0 : delta / (1 - (2 * l - 1).abs());

    return [h, s, l]; // H in degrees, S and L are 0–1
  }

  String _nearestColorName(int r, int g, int b) {
    // Normalize
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final maxVal = max(rf, max(gf, bf));
    final minVal = min(rf, min(gf, bf));
    final delta = maxVal - minVal;

    // 1️⃣ ABSOLUTE BLACK (camera noise safe)
    if (maxVal < 0.05) {
      return 'Black';
    }

    // 2️⃣ ABSOLUTE WHITE
    if (minVal > 0.95) {
      return 'White';
    }

    // 3️⃣ GRAYS (low chroma)
    if (delta < 0.08) {
      if (maxVal < 0.2) return 'Very Dark Gray';
      if (maxVal < 0.4) return 'Dark Gray';
      if (maxVal < 0.7) return 'Gray';
      return 'Light Gray';
    }

    // 4️⃣ REAL COLOR MATCHING (ignore grays)
    double minDist = double.infinity;
    String nearest = 'Unknown';

    for (final c in _namedColors) {
      // Skip grayscale palette entries
      if (c['r'] == c['g'] && c['g'] == c['b']) continue;

      final dr = r - c['r'];
      final dg = g - c['g'];
      final db = b - c['b'];

      final dist = dr * dr + dg * dg + db * db;

      if (dist < minDist) {
        minDist = dist.toDouble();
        nearest = c['name'] as String;
      }
    }

    return nearest;
  }

  List<double> _rgbToLab(int r, int g, int b) {
    double rf = _pivotRgb(r / 255);
    double gf = _pivotRgb(g / 255);
    double bf = _pivotRgb(b / 255);

    double x = rf * 0.4124 + gf * 0.3576 + bf * 0.1805;
    double y = rf * 0.2126 + gf * 0.7152 + bf * 0.0722;
    double z = rf * 0.0193 + gf * 0.1192 + bf * 0.9505;

    x /= 0.95047;
    y /= 1.00000;
    z /= 1.08883;

    x = _pivotXyz(x);
    y = _pivotXyz(y);
    z = _pivotXyz(z);

    return [max(0, 116 * y - 16), 500 * (x - y), 200 * (y - z)];
  }

  double _pivotRgb(double n) =>
      n > 0.04045 ? pow((n + 0.055) / 1.055, 2.4).toDouble() : n / 12.92;

  double _pivotXyz(double n) =>
      n > 0.008856 ? pow(n, 1 / 3).toDouble() : (7.787 * n) + 16 / 116;

  /// -------- UTILITIES --------

  String _rgbToHex(int r, int g, int b) =>
      '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  List<double> _rgbToCmyk(int r, int g, int b) {
    double rf = r / 255, gf = g / 255, bf = b / 255;
    double k = 1 - max(rf, max(gf, bf));
    if (k >= 1) return [0, 0, 0, 100];
    return [
      (1 - rf - k) / (1 - k) * 100,
      (1 - gf - k) / (1 - k) * 100,
      (1 - bf - k) / (1 - k) * 100,
      k * 100,
    ];
  }

  List<int>? _getCenterPixelColorFromImage(CameraImage image) {
    // Only handle YUV420 here (typical on Android)
    if (image.format.group != ImageFormatGroup.yuv420) return null;

    final width = image.width;
    final height = image.height;
    final cx = width ~/ 2;
    final cy = height ~/ 2;

    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];

    // Y plane row stride and bytes
    final yRowStride = planeY.bytesPerRow;
    final yIndex = cy * yRowStride + cx;
    if (yIndex >= planeY.bytes.length) return null;
    final y = planeY.bytes[yIndex];

    // For u/v planes we must consider pixelStride and rowStride (subsampled)
    final uvRowStride = planeU.bytesPerRow;
    final uvPixelStride = planeU.bytesPerPixel ?? 1;

    final uvx = cx ~/ 2;
    final uvy = cy ~/ 2;

    final uvIndex = uvy * uvRowStride + uvx * uvPixelStride;
    if (uvIndex >= planeU.bytes.length || uvIndex >= planeV.bytes.length) {
      return null;
    }
    final u = planeU.bytes[uvIndex];
    final v = planeV.bytes[uvIndex];

    // YUV -> RGB conversion (BT.601)
    final yf = y & 0xff;
    final uf = u & 0xff;
    final vf = v & 0xff;

    // Convert using common formulas
    double r = yf + 1.370705 * (vf - 128);
    double g = yf - 0.337633 * (uf - 128) - 0.698001 * (vf - 128);
    double b = yf + 1.732446 * (uf - 128);

    int ri = r.round().clamp(0, 255);
    int gi = g.round().clamp(0, 255);
    int bi = b.round().clamp(0, 255);

    return [ri, gi, bi];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _isReady && _controller != null
              ? Center(
                child: FittedBox(
                  fit: BoxFit.cover, // fills the screen without stretching
                  child: SizedBox(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              )
              : Container(color: Colors.black), // <── black screen fallback
          // Crosshair overlay
          Center(
            child: CustomPaint(
              painter: _CrosshairPainter(),
              child: SizedBox(width: 240, height: 240),
            ),
          ),
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    onPressed: () {
                      // optionally toggle flash using controller.setFlashMode(...)
                    },
                  ),
                ],
              ),
            ),
          ),

          // TWO-PANEL BOTTOM UI
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ───────────────────────────────
                // TOP PANEL — Color Info (transparent, NO rounded corners)
                // ───────────────────────────────
                Container(
                  width: double.infinity,
                  height: 160,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  child: Row(
                    children: [
                      // Color swatch
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _currentColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Color Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _colorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("HEX: $_hex"),
                            Text("RGB: $_rgb"),
                            Text("CMYK: $_cmyk"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ───────────────────────────────
                // BOTTOM PANEL — Camera Buttons
                // Black background, white icons, rounded top corners
                // ───────────────────────────────
                Container(
                  width: double.infinity,
                  height: 160,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Info button
                      IconButton(
                        iconSize: 40,
                        color: Colors.white,
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {},
                      ),

                      // Capture button (big)
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: Colors.white),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 35),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),

                      // Switch camera (front ↔ back)
                      IconButton(
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                        ),
                        onPressed: _isSwitching ? null : _switchCamera,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Crosshair painter draws a square focus box and cross lines
class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // focus square centered
    final sq = Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: min(w, h) * 0.5,
      height: min(w, h) * 0.5,
    );
    canvas.drawRect(sq, paint);

    // short crosshair lines in middle
    final cx = w / 2;
    final cy = h / 2;
    final len = 12.0;
    canvas.drawLine(Offset(cx - len, cy), Offset(cx + len, cy), paint);
    canvas.drawLine(Offset(cx, cy - len), Offset(cx, cy + len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

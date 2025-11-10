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
  Timer? _throttleTimer;

  // Live values
  Color _currentColor = Colors.white;
  String _colorName = 'White';
  String _hex = '#FFFFFF';
  String _rgb = '(255, 255, 255)';
  String _cmyk = '(0, 0, 0, 0)';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Prefer back camera
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

      // Start image stream
      _controller!.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  // Throttle so we don't process every frame (expensive)
  void _processCameraImage(CameraImage image) {
    if (_processingFrame) return;

    // process at most once every 200ms
    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer = Timer(const Duration(milliseconds: 200), () {});

    _processingFrame = true;
    try {
      final centerColor = _getCenterPixelColorFromImage(image);
      if (centerColor != null) {
        final r = centerColor[0], g = centerColor[1], b = centerColor[2];
        final color = Color.fromARGB(255, r, g, b);

        final hex = _rgbToHex(r, g, b);
        final cmyk = _rgbToCmyk(r, g, b);
        final name = _nearestColorName(r, g, b);

        if (mounted) {
          setState(() {
            _currentColor = color;
            _hex = hex;
            _rgb = '($r, $g, $b)';
            _cmyk = '(${cmyk.map((v) => v.toStringAsFixed(0)).join(', ')})';
            _colorName = name;
          });
        }
      }
    } catch (e) {
      debugPrint('Frame processing error: $e');
    } finally {
      _processingFrame = false;
    }
  }

  /// Returns [r,g,b] for the center pixel, or null if cannot compute.
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

  String _rgbToHex(int r, int g, int b) {
    String toHex(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#${toHex(r)}${toHex(g)}${toHex(b)}';
  }

  List<double> _rgbToCmyk(int r, int g, int b) {
    double rf = r / 255.0;
    double gf = g / 255.0;
    double bf = b / 255.0;

    double k = 1 - max(rf, max(gf, bf));
    if (k >= 1.0 - 1e-9) {
      return [0, 0, 0, 100];
    }
    double c = (1 - rf - k) / (1 - k);
    double m = (1 - gf - k) / (1 - k);
    double y = (1 - bf - k) / (1 - k);
    return [c * 100, m * 100, y * 100, k * 100];
  }

  // Small palette of named colors; expand as needed
  static const List<Map<String, dynamic>> _namedColors = [
    {'name': 'Black', 'r': 0, 'g': 0, 'b': 0},
    {'name': 'White', 'r': 255, 'g': 255, 'b': 255},
    {'name': 'Red', 'r': 255, 'g': 0, 'b': 0},
    {'name': 'Green', 'r': 0, 'g': 128, 'b': 0},
    {'name': 'Blue', 'r': 0, 'g': 0, 'b': 255},
    {'name': 'Yellow', 'r': 255, 'g': 255, 'b': 0},
    {'name': 'Cyan', 'r': 0, 'g': 255, 'b': 255},
    {'name': 'Magenta', 'r': 255, 'g': 0, 'b': 255},
    {'name': 'Gray', 'r': 128, 'g': 128, 'b': 128},
    {'name': 'Orange', 'r': 255, 'g': 165, 'b': 0},
    {'name': 'Brown', 'r': 165, 'g': 42, 'b': 42},
    {'name': 'Pink', 'r': 255, 'g': 192, 'b': 203},
  ];

  String _nearestColorName(int r, int g, int b) {
    double minDist = double.infinity;
    String nearest = 'Unknown';
    for (final c in _namedColors) {
      final dr = r - (c['r'] as int);
      final dg = g - (c['g'] as int);
      final db = b - (c['b'] as int);
      final dist = sqrt(dr * dr + dg * dg + db * db);
      if (dist < minDist) {
        minDist = dist;
        nearest = c['name'] as String;
      }
    }
    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isReady && _controller != null
              ? Stack(
                children: [
                  SizedBox.expand(child: CameraPreview(_controller!)),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // optionally toggle flash using controller.setFlashMode(...)
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom info panel
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxHeight: 160, // limits the panel height
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white, // solid background
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000), // subtle shadow
                            offset: Offset(0, -2),
                            blurRadius: 8,
                          ),
                        ],
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

                          // Color info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _colorName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('HEX: $_hex'),
                                Text('RGB: $_rgb'),
                                Text('CMYK: $_cmyk'),
                              ],
                            ),
                          ),

                          // Buttons
                          // Column(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     IconButton(
                          //       icon: const Icon(Icons.info_outline),
                          //       onPressed: () {},
                          //     ),
                          //     IconButton(
                          //       icon: const Icon(Icons.camera_alt),
                          //       onPressed: () {},
                          //     ),
                          //     IconButton(
                          //       icon: const Icon(Icons.refresh),
                          //       onPressed: () {},
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
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

import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:kulaidoverse/color_info_screen.dart';

enum CameraMode { colorPicker, colorBlindSimulation, colorFilter }

enum ColorBlindType { normal, protanopia, deuteranopia, tritanopia }

const Map<ColorBlindType, List<double>> colorBlindMatrices = {
  ColorBlindType.normal: [
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],

  // 🔴 Protanopia (red-blind)
  ColorBlindType.protanopia: [
    0.567,
    0.433,
    0.000,
    0,
    0,
    0.558,
    0.442,
    0.000,
    0,
    0,
    0.000,
    0.242,
    0.758,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],

  // 🟢 Deuteranopia (green-blind)
  ColorBlindType.deuteranopia: [
    0.625,
    0.375,
    0.000,
    0,
    0,
    0.700,
    0.300,
    0.000,
    0,
    0,
    0.000,
    0.300,
    0.700,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],

  // 🔵 Tritanopia (blue-blind)
  ColorBlindType.tritanopia: [
    0.950,
    0.050,
    0.000,
    0,
    0,
    0.000,
    0.433,
    0.567,
    0,
    0,
    0.000,
    0.475,
    0.525,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],
};

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
  bool _isFrozen = false;
  Uint8List? _frozenFrame;
  Timer? _throttleTimer;

  // Live values
  Color _currentColor = Colors.white;
  String _colorName = 'White';
  String _hex = '#FFFFFF';
  String _rgb = '(255, 255, 255)';
  String _cmyk = '(0, 0, 0, 0)';

  CameraMode _currentMode = CameraMode.colorPicker;
  ColorBlindType _colorBlindType = ColorBlindType.normal;

  String get _modeLabel {
    switch (_currentMode) {
      case CameraMode.colorPicker:
        return 'Color Picker';
      case CameraMode.colorBlindSimulation:
        return 'Colorblind Simulation';
      case CameraMode.colorFilter:
        return 'Color Filter';
    }
  }

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
    if (_isFrozen) return; // ⬅️ FREEZE HERE
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

  Widget _cameraView() {
    final size = _controller!.value.previewSize!;
    final isFront =
        _controller!.description.lensDirection == CameraLensDirection.front;

    return Center(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // LIVE CAMERA
              CameraPreview(_controller!),

              // FROZEN FRAME (perfect overlay)
              if (_isFrozen && _frozenFrame != null)
                Transform(
                  alignment: Alignment.center,
                  transform:
                      isFront
                          ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0))
                          : Matrix4.identity(),

                  child: Image.memory(_frozenFrame!, fit: BoxFit.cover),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<CameraMode> _modeItem(CameraMode mode, String label) {
    final bool selected = _currentMode == mode;

    return PopupMenuItem<CameraMode>(
      value: mode,
      child: Row(
        children: [
          Icon(
            selected ? Icons.check : null,
            color: selected ? Colors.greenAccent : Colors.transparent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.greenAccent : Colors.white,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    switch (_currentMode) {
      case CameraMode.colorPicker:
        return _colorPickerControls();

      case CameraMode.colorBlindSimulation:
        return _colorBlindControls();

      case CameraMode.colorFilter:
        return _colorFilterControls();
    }
  }

  Widget _colorPickerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 40,
          color: Colors.white,
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ColorInfoScreen(
                      color: _currentColor,
                      hex: _hex,
                      rgb: _rgb,
                      cmyk: _cmyk,
                      name: _colorName,
                    ),
              ),
            );
          },
        ),

        // Freeze / Unfreeze
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 4, color: Colors.white),
          ),
          child: IconButton(
            icon: Icon(
              _isFrozen ? Icons.play_arrow_rounded : Icons.stop_rounded,
              size: 35,
            ),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isFrozen = !_isFrozen;
              });
            },
          ),
        ),

        IconButton(
          icon: const Icon(Icons.cameraswitch, color: Colors.white),
          onPressed: (_isSwitching || _isFrozen) ? null : _switchCamera,
        ),
      ],
    );
  }

  Widget _colorBlindControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dropdown
        Expanded(
          child: PopupMenuButton<ColorBlindType>(
            color: const Color(0xFF222222),
            initialValue: _colorBlindType,
            onSelected: (type) {
              setState(() {
                _colorBlindType = type;
              });
            },
            itemBuilder:
                (context) =>
                    ColorBlindType.values.map((type) {
                      final selected = type == _colorBlindType;
                      return PopupMenuItem(
                        value: type,
                        child: Text(
                          type.name.toUpperCase(),
                          style: TextStyle(
                            color: selected ? Colors.greenAccent : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _colorBlindType.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        IconButton(
          icon: const Icon(Icons.cameraswitch, color: Colors.white),
          onPressed: _isSwitching ? null : _switchCamera,
        ),
      ],
    );
  }

  Widget _colorFilterControls() {
    return const Center(
      child: Text('Color Filter Mode', style: TextStyle(color: Colors.white54)),
    );
  }

  Widget _cameraWithFilters() {
    Widget camera = _cameraView();

    if (_currentMode == CameraMode.colorBlindSimulation) {
      return ColorFiltered(
        colorFilter: ColorFilter.matrix(colorBlindMatrices[_colorBlindType]!),
        child: camera,
      );
    }

    return camera;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isReady && _controller != null)
            _cameraWithFilters()
          else
            Container(color: Colors.black),

          // Crosshair overlay
          if (_currentMode == CameraMode.colorPicker)
            Center(
              child: CustomPaint(
                painter: _CrosshairPainter(),
                child: const SizedBox(width: 240, height: 240),
              ),
            ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ⬅ Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // 🎛 Mode dropdown
                  PopupMenuButton<CameraMode>(
                    color: const Color(0xFF222222),
                    initialValue: _currentMode,
                    onSelected: (mode) {
                      setState(() {
                        _currentMode = mode;
                      });
                    },
                    itemBuilder:
                        (context) => [
                          _modeItem(CameraMode.colorPicker, 'Color Picker'),
                          _modeItem(
                            CameraMode.colorBlindSimulation,
                            'Colorblind Simulation',
                          ),
                          _modeItem(CameraMode.colorFilter, 'Color Filter'),
                        ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _modeLabel,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
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
                if (_currentMode == CameraMode.colorPicker)
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
                  child: _buildBottomControls(),
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

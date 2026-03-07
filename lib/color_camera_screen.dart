import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:kulaidoverse/color_info_screen.dart';
import 'dart:ui' as ui;

enum CameraMode { colorPicker, colorBlindSimulation, colorFilter }

enum ColorBlindType {
  normal,
  protanopia,
  protanomaly,
  deuteranopia,
  deuteranomaly,
  tritanopia,
  tritanomaly,
  achromatopsia,
  achromatomaly,
}

enum FilterColor { red, orange, yellow, green, cyan, blue, purple, pink, brown }

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

  // 🔴 Protanopia (Red-Blind)
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

  // 🔴 Protanomaly (Red-Weak)
  ColorBlindType.protanomaly: [
    0.817,
    0.183,
    0.000,
    0,
    0,
    0.333,
    0.667,
    0.000,
    0,
    0,
    0.000,
    0.125,
    0.875,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],

  // 🟢 Deuteranopia (Green-Blind)
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

  // 🟢 Deuteranomaly (Green-Weak)
  ColorBlindType.deuteranomaly: [
    0.800,
    0.200,
    0.000,
    0,
    0,
    0.258,
    0.742,
    0.000,
    0,
    0,
    0.000,
    0.142,
    0.858,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],

  // 🔵 Tritanopia (Blue-Blind)
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

  // 🔵 Tritanomaly (Blue-Weak)
  ColorBlindType.tritanomaly: [
    0.967,
    0.033,
    0.000,
    0,
    0,
    0.000,
    0.733,
    0.267,
    0,
    0,
    0.000,
    0.183,
    0.817,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],

  // ⚫ Achromatopsia (Total Color Blind)
  ColorBlindType.achromatopsia: [
    0.299,
    0.587,
    0.114,
    0,
    0,
    0.299,
    0.587,
    0.114,
    0,
    0,
    0.299,
    0.587,
    0.114,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],

  // ⚫ Achromatomaly (Blue Cone Monochromacy)
  ColorBlindType.achromatomaly: [
    0.618,
    0.320,
    0.062,
    0,
    0,
    0.163,
    0.775,
    0.062,
    0,
    0,
    0.163,
    0.320,
    0.516,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ],
};

// Color filter reference values in HSV
const Map<FilterColor, Map<String, dynamic>> filterColorData = {
  FilterColor.red: {
    'name': 'Red',
    'hueRanges': [
      [0, 20],
      [340, 360],
    ], // red wraps around
    'satMin': 0.3,
    'valMin': 0.2,
  },
  FilterColor.orange: {
    'name': 'Orange',
    'hueRanges': [
      [15, 45],
    ],
    'satMin': 0.3,
    'valMin': 0.2,
  },
  FilterColor.yellow: {
    'name': 'Yellow',
    'hueRanges': [
      [45, 75],
    ],
    'satMin': 0.3,
    'valMin': 0.3,
  },
  FilterColor.green: {
    'name': 'Green',
    'hueRanges': [
      [75, 165],
    ],
    'satMin': 0.25,
    'valMin': 0.2,
  },
  FilterColor.cyan: {
    'name': 'Cyan',
    'hueRanges': [
      [165, 200],
    ],
    'satMin': 0.25,
    'valMin': 0.2,
  },
  FilterColor.blue: {
    'name': 'Blue',
    'hueRanges': [
      [200, 260],
    ],
    'satMin': 0.3,
    'valMin': 0.2,
  },
  FilterColor.purple: {
    'name': 'Purple',
    'hueRanges': [
      [260, 300],
    ],
    'satMin': 0.25,
    'valMin': 0.2,
  },
  FilterColor.pink: {
    'name': 'Pink',
    'hueRanges': [
      [300, 340],
    ],
    'satMin': 0.25,
    'valMin': 0.3,
  },
  FilterColor.brown: {
    'name': 'Brown',
    'hueRanges': [
      [15, 35],
    ],
    'satMin': 0.3,
    'satMax': 0.8,
    'valMin': 0.2,
    'valMax': 0.6,
  },
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
  FilterColor _selectedFilterColor = FilterColor.red;
  FlashMode _flashMode = FlashMode.off;

  // For color filter mode
  ui.Image? _filteredImage;
  Timer? _filterTimer;
  bool _processingFilter = false;

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
    _filterTimer?.cancel();
    _controller?.dispose();
    _filteredImage?.dispose();
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
    // Color picker mode - just get center pixel
    if (_currentMode == CameraMode.colorPicker) {
      if (_isFrozen) return;
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
          _cmyk = _rgbToCmyk(
            r,
            g,
            b,
          ).map((v) => v.toStringAsFixed(0)).join(', ');
          _colorName = name;
        });
      } finally {
        _processingFrame = false;
      }
    }
    // Color filter mode - process entire frame
    else if (_currentMode == CameraMode.colorFilter) {
      if (_processingFilter) return;
      if (_filterTimer?.isActive ?? false) return;

      _filterTimer = Timer(const Duration(milliseconds: 180), () {});

      _processingFilter = true;

      _processColorFilterFrame(image);
    }
  }

  Future<void> _processColorFilterFrame(CameraImage image) async {
    try {
      // Convert YUV to RGB and apply color filter
      final rgbaBytes = await _convertYUVtoRGBwithFilter(image, step: 3);
      if (rgbaBytes == null) return;

      // Create image from raw RGBA bytes
      final completer = Completer<ui.Image>();
      const step = 3;
      final outWidth = image.width ~/ step;
      final outHeight = image.height ~/ step;

      // ⚠️ SWAP WIDTH & HEIGHT HERE
      ui.decodeImageFromPixels(
        rgbaBytes,
        outHeight, // swapped
        outWidth, // swapped

        ui.PixelFormat.rgba8888,
        (ui.Image img) {
          completer.complete(img);
        },
      );

      ui.Image img = await completer.future;

      final filteredImg = img;

      if (mounted) {
        setState(() {
          _filteredImage?.dispose();
          _filteredImage = filteredImg;
        });
      }
    } catch (e) {
      debugPrint('Error processing filter frame: $e');
    } finally {
      _processingFilter = false;
    }
  }

  Future<Uint8List?> _convertYUVtoRGBwithFilter(
    CameraImage image, {
    int step = 3, // <-- ADD THIS
  }) async {
    if (image.format.group != ImageFormatGroup.yuv420) return null;

    final width = image.width;
    final height = image.height;

    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];

    final yRowStride = planeY.bytesPerRow;
    final uvRowStride = planeU.bytesPerRow;
    final uvPixelStride = planeU.bytesPerPixel ?? 1;

    // Create RGBA output
    final outWidth = width ~/ step;
    final outHeight = height ~/ step;
    final rgbaBytes = Uint8List(outWidth * outHeight * 4);

    for (int y = 0; y < height; y += step) {
      final outY = y ~/ step;

      for (int x = 0; x < width; x += step) {
        final outX = x ~/ step;

        final yIndex = y * yRowStride + x;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        if (yIndex >= planeY.bytes.length ||
            uvIndex >= planeU.bytes.length ||
            uvIndex >= planeV.bytes.length) {
          continue;
        }

        final yValue = planeY.bytes[yIndex];
        final uValue = planeU.bytes[uvIndex];
        final vValue = planeV.bytes[uvIndex];

        // YUV to RGB conversion
        final yf = yValue & 0xff;
        final uf = uValue & 0xff;
        final vf = vValue & 0xff;

        double r = yf + 1.370705 * (vf - 128);
        double g = yf - 0.337633 * (uf - 128) - 0.698001 * (vf - 128);
        double b = yf + 1.732446 * (uf - 128);

        int ri = r.round().clamp(0, 255);
        int gi = g.round().clamp(0, 255);
        int bi = b.round().clamp(0, 255);

        // Check if this pixel matches the selected color
        final matches = _isColorMatch(ri, gi, bi, _selectedFilterColor);

        final rotatedX = outHeight - 1 - outY;
        final rotatedY = outX;

        final pixelIndex = (rotatedY * outHeight + rotatedX) * 4;

        if (matches) {
          // Keep original color
          rgbaBytes[pixelIndex] = ri;
          rgbaBytes[pixelIndex + 1] = gi;
          rgbaBytes[pixelIndex + 2] = bi;
          rgbaBytes[pixelIndex + 3] = 255;
        } else {
          // Convert to grayscale
          final gray = (0.299 * ri + 0.587 * gi + 0.114 * bi).round();
          rgbaBytes[pixelIndex] = gray;
          rgbaBytes[pixelIndex + 1] = gray;
          rgbaBytes[pixelIndex + 2] = gray;
          rgbaBytes[pixelIndex + 3] = 255;
        }
      }
    }

    return rgbaBytes;
  }

  bool _isColorMatch(int r, int g, int b, FilterColor filterColor) {
    final colorData = filterColorData[filterColor]!;

    // Convert RGB to HSV
    final hsv = _rgbToHsv(r, g, b);
    final h = hsv[0]; // 0-360
    final s = hsv[1]; // 0-1
    final v = hsv[2]; // 0-1

    // Check saturation and value constraints
    final satMin = colorData['satMin'] ?? 0.0;
    final valMin = colorData['valMin'] ?? 0.0;

    if (s < satMin || v < valMin) {
      return false;
    }

    // Special handling for brown (has satMax and valMax)
    if (filterColor == FilterColor.brown) {
      final satMax = colorData['satMax'] ?? 1.0;
      final valMax = colorData['valMax'] ?? 1.0;
      if (s > satMax || v > valMax) {
        return false;
      }
    }

    // Check hue ranges
    final hueRanges = colorData['hueRanges'] as List;
    for (final range in hueRanges) {
      final hueMin = range[0];
      final hueMax = range[1];
      if (h >= hueMin && h <= hueMax) {
        return true;
      }
    }

    return false;
  }

  List<double> _rgbToHsv(int r, int g, int b) {
    double rf = r / 255.0;
    double gf = g / 255.0;
    double bf = b / 255.0;

    double max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    double min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    double delta = max - min;

    double h = 0;
    double s = max == 0 ? 0 : delta / max;
    double v = max;

    if (delta != 0) {
      if (max == rf) {
        h = 60 * (((gf - bf) / delta) % 6);
      } else if (max == gf) {
        h = 60 * (((bf - rf) / delta) + 2);
      } else {
        h = 60 * (((rf - gf) / delta) + 4);
      }
    }

    if (h < 0) h += 360;

    return [h, s, v];
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
      _controller = null;
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

      // Disable flash if front camera
      if (newDescription.lensDirection == CameraLensDirection.front) {
        await cam.setFlashMode(FlashMode.off);
        _flashMode = FlashMode.off;
      }

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
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final controller = _controller!;
    final isFront =
        controller.description.lensDirection == CameraLensDirection.front;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        final previewSize = controller.value.previewSize!;
        final isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;

        final previewW = isPortrait ? previewSize.height : previewSize.width;
        final previewH = isPortrait ? previewSize.width : previewSize.height;

        final screenRatio = screenW / screenH;
        final previewRatio = previewW / previewH;

        double scaleX = 1.0;
        double scaleY = 1.0;

        // BoxFit.cover math
        if (previewRatio > screenRatio) {
          scaleX = previewRatio / screenRatio;
        } else {
          scaleY = screenRatio / previewRatio;
        }

        return Transform(
          alignment: Alignment.center,
          transform:
              Matrix4.identity()..scale(isFront ? scaleX : scaleX, scaleY),

          child: Stack(
            fit: StackFit.expand,
            children: [
              // LIVE CAMERA
              if (_currentMode != CameraMode.colorFilter)
                CameraPreview(controller),

              // FILTERED FRAME
              if (_currentMode == CameraMode.colorFilter &&
                  _filteredImage != null)
                RawImage(image: _filteredImage, fit: BoxFit.cover),

              // FROZEN FRAME
              if (_isFrozen && _frozenFrame != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: previewW,
                    height: previewH,
                    child: Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()..scale(
                            controller.description.lensDirection ==
                                    CameraLensDirection.front
                                ? -1.0
                                : 1.0,
                            1.0,
                          ),
                      child: Image.memory(
                        _frozenFrame!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
            onPressed: () async {
              if (_controller == null || !_controller!.value.isInitialized) {
                return;
              }

              if (!_isFrozen) {
                // Capture one frame
                final image = await _controller!.takePicture();
                final bytes = await image.readAsBytes();

                final codec = await ui.instantiateImageCodec(bytes);
                final frame = await codec.getNextFrame();
                ui.Image img = frame.image;

                final data = await img.toByteData(
                  format: ui.ImageByteFormat.png,
                );

                setState(() {
                  _frozenFrame = data!.buffer.asUint8List();
                  _isFrozen = true;
                });
              } else {
                // Unfreeze
                setState(() {
                  _frozenFrame = null;
                  _isFrozen = false;
                });
              }
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Color Filter Dropdown ONLY
        Expanded(
          child: PopupMenuButton<FilterColor>(
            color: const Color(0xFF222222),
            initialValue: _selectedFilterColor,
            onSelected: (color) {
              setState(() {
                _selectedFilterColor = color;
                _filteredImage?.dispose();
                _filteredImage = null;
              });
            },
            itemBuilder:
                (context) =>
                    FilterColor.values.map((color) {
                      final selected = color == _selectedFilterColor;
                      final colorData = filterColorData[color]!;
                      return PopupMenuItem(
                        value: color,
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.check : null,
                              color:
                                  selected
                                      ? Colors.greenAccent
                                      : Colors.transparent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              colorData['name'],
                              style: TextStyle(
                                color:
                                    selected
                                        ? Colors.greenAccent
                                        : Colors.white,
                                fontWeight:
                                    selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
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
                    filterColorData[_selectedFilterColor]!['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cameraWithFilters() {
    Widget camera = _cameraView();

    // Apply colorblind simulation
    if (_currentMode == CameraMode.colorBlindSimulation) {
      return ColorFiltered(
        colorFilter: ColorFilter.matrix(colorBlindMatrices[_colorBlindType]!),
        child: camera,
      );
    }

    // Color filter mode handles its own rendering in _cameraView()
    return camera;
  }

  Future<void> _ensureBackCamera() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_controller!.description.lensDirection == CameraLensDirection.back) {
      return; // already back camera
    }

    await _switchCamera();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Prevent flash on front camera
    if (_controller!.description.lensDirection == CameraLensDirection.front) {
      return;
    }

    try {
      FlashMode newMode;

      if (_flashMode == FlashMode.off) {
        newMode = FlashMode.torch;
      } else {
        newMode = FlashMode.off;
      }

      await _controller!.setFlashMode(newMode);

      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      debugPrint("Flash error: $e");
    }
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    children: [
                      // TOP ROW (mode + flash)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // MODE DROPDOWN (LEFT)
                          PopupMenuButton<CameraMode>(
                            color: const Color(0xFF222222),
                            initialValue: _currentMode,
                            onSelected: (mode) async {
                              if (mode == CameraMode.colorFilter) {
                                await _ensureBackCamera();
                              }

                              setState(() {
                                _currentMode = mode;

                                _isFrozen = false;
                                _frozenFrame = null;

                                if (mode != CameraMode.colorFilter) {
                                  _filteredImage?.dispose();
                                  _filteredImage = null;
                                }
                              });
                            },

                            itemBuilder:
                                (context) => [
                                  _modeItem(
                                    CameraMode.colorPicker,
                                    'Color Picker',
                                  ),
                                  _modeItem(
                                    CameraMode.colorBlindSimulation,
                                    'Colorblind Simulation',
                                  ),
                                  _modeItem(
                                    CameraMode.colorFilter,
                                    'Color Filter',
                                  ),
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

                          // FLASH BUTTON (RIGHT)
                          Builder(
                            builder: (context) {
                              final isFront =
                                  _controller?.description.lensDirection ==
                                  CameraLensDirection.front;

                              return IconButton(
                                icon: Icon(
                                  _flashMode == FlashMode.off
                                      ? Icons.flash_off
                                      : Icons.flash_on,
                                  color:
                                      isFront
                                          ? Colors.grey
                                          : (_flashMode == FlashMode.off
                                              ? Colors.white
                                              : Colors.yellow),
                                ),
                                onPressed: isFront ? null : _toggleFlash,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // CAMERA CONTROLS
                      Expanded(child: _buildBottomControls()),
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

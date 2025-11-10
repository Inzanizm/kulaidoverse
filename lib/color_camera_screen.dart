import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ColorCameraScreen extends StatefulWidget {
  const ColorCameraScreen({super.key});

  @override
  State<ColorCameraScreen> createState() => _ColorCameraScreenState();
}

class _ColorCameraScreenState extends State<ColorCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras!.first, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Color Camera'),
        backgroundColor: Colors.black,
      ),
      body:
          _isInitialized
              ? CameraPreview(_controller!)
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

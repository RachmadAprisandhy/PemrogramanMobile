import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kamera App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  XFile? _lastCapturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera(_selectedCameraIndex);
  }

  Future<void> _initCamera(int cameraIndex) async {
    controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
    );
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } on CameraException catch (e) {
      debugPrint('Error kamera: ${e.code}');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitialized = false);
    await controller.dispose();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initCamera(_selectedCameraIndex);
  }

  Future<void> _takePicture() async {
    if (!controller.value.isInitialized || controller.value.isTakingPicture) {
      return;
    }
    try {
      final XFile file = await controller.takePicture();
      setState(() => _lastCapturedImage = file);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PreviewScreen(imageFile: file)),
      );
    } on CameraException catch (e) {
      debugPrint('Gagal ambil foto: ${e.code}');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kamera'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: !_isInitialized
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Preview kamera memenuhi layar
                  Positioned.fill(child: CameraPreview(controller)),

                  // Tombol ganti kamera depan/belakang
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: IconButton(
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                        ),
                        onPressed: _switchCamera,
                      ),
                    ),
                  ),

                  // Panel kontrol bawah
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Thumbnail foto terakhir
                          _lastCapturedImage == null
                              ? const SizedBox(width: 48, height: 48)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_lastCapturedImage!.path),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                          // Tombol jepret
                          FloatingActionButton(
                            onPressed: _takePicture,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final XFile imageFile;
  const PreviewScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Foto')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          child: Image.file(File(imageFile.path)),
        ),
      ),
    );
  }
}
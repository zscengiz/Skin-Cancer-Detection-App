import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/reports/pdf.dart';

class CameraScreen extends StatefulWidget {
  final String bodyPart;
  const CameraScreen({super.key, required this.bodyPart});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;
  double _zoomLevel = 1.0;

  final GlobalKey _boxKey = GlobalKey();
  Rect? _boxRect;
  final double _boxSize = 250;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
      context.pop();
      return;
    }
    await _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _startCamera(_cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back));
  }

  void _startCamera(CameraDescription description) {
    _controller = CameraController(
      description,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
      _getBoxRect();
    });
  }

  void _toggleCamera() {
    final newLensDirection =
        _isFrontCamera ? CameraLensDirection.back : CameraLensDirection.front;
    final newCamera = _cameras
        .firstWhere((camera) => camera.lensDirection == newLensDirection);
    _isFrontCamera = !_isFrontCamera;
    _startCamera(newCamera);
  }

  void _getBoxRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _boxKey.currentContext?.findRenderObject() as RenderBox?;
      final position = renderBox?.localToGlobal(Offset.zero);
      if (renderBox != null && position != null) {
        setState(() {
          _boxRect = position & renderBox.size;
        });
      }
    });
  }

  Future<Map<String, dynamic>?> _runDetection(File imageFile) async {
    try {
      final uri = Uri.parse("http://192.168.0.10:8000/detect");
      final request = http.MultipartRequest('POST', uri);
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      if (data['predictions'] != null && data['predictions'].isNotEmpty) {
        return data['predictions'][0];
      }
      return null;
    } catch (e) {
      debugPrint("Detection API error: $e");
      return null;
    }
  }

  void _capturePhoto() async {
    if (!_controller.value.isInitialized || _controller.value.isTakingPicture) {
      debugPrint("Camera not ready or already taking a picture");
      return;
    }

    try {
      final image = await _controller.takePicture();
      final croppedPath = await _cropToBox(image.path);
      final croppedFile = File(croppedPath);

      final prediction = await _runDetection(croppedFile);
      if (prediction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No lesion detected.")),
        );
        return;
      }

      final label = prediction['class'];
      final confidence = (prediction['confidence'] * 100).toDouble();

      final riskLevels = {
        'MEL': 'High risk',
        'NV': 'Low risk',
        'BCC': 'Medium risk',
        'AKIEC': 'High risk',
        'BKL': 'Low risk',
        'DF': 'Low risk',
        'VASC': 'Low risk',
      };

      final adviceTexts = {
        'MEL': 'Consult a dermatologist immediately.',
        'NV': 'Monitor occasionally and visit dermatologist annually.',
        'BCC': 'Visit dermatologist soon for potential treatment.',
        'AKIEC': 'Consult dermatologist urgently.',
        'BKL': 'Usually harmless. No intervention needed unless changes occur.',
        'DF': 'Benign. Treatment is rarely needed.',
        'VASC': 'Benign condition. Cosmetic treatment optional.',
      };

      final risk = riskLevels[label] ?? 'Unknown';
      final advice = adviceTexts[label] ?? 'No advice available.';

      final pdfPath = await generatePdfReport(
        imageFile: croppedFile,
        label: label,
        confidence: confidence,
        risk: risk,
        advice: advice,
        fullNames: riskLevels,
      );

      await ApiService.uploadReport(
        imageFile: croppedFile,
        pdfFile: File(pdfPath),
        label: label,
        confidence: confidence,
        riskLevel: risk,
        advice: advice,
      );

      if (!mounted) return;
      context.go('/detection-result', extra: croppedFile);
    } catch (e) {
      debugPrint("Photo capture failed: $e");
    }
  }

  Future<String> _cropToBox(String imagePath) async {
    final original = File(imagePath);
    final bytes = await original.readAsBytes();

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final screenSize = MediaQuery.of(context).size;
    final scaleX = image.width / screenSize.width;
    final scaleY = image.height / screenSize.height;

    final cropRect = Rect.fromLTWH(
      _boxRect!.left * scaleX,
      _boxRect!.top * scaleY,
      _boxRect!.width * scaleX,
      _boxRect!.height * scaleY,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    canvas.drawImageRect(
      image,
      cropRect,
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      paint,
    );

    final croppedImage = await recorder
        .endRecording()
        .toImage(cropRect.width.toInt(), cropRect.height.toInt());

    final byteData =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);

    final directory = await getTemporaryDirectory();
    final croppedPath =
        '${directory.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';

    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(byteData!.buffer.asUint8List());

    return croppedPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.previewSize!.height,
                    height: _controller.value.previewSize!.width,
                    child: CameraPreview(_controller),
                  ),
                ),
                if (_boxRect != null)
                  CustomPaint(
                    painter: _OverlayPainter(boxRect: _boxRect!),
                    size: MediaQuery.of(context).size,
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Take a photo\n5–10 cm from the object\nThe photo must be well-defined",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      key: _boxKey,
                      width: _boxSize,
                      height: _boxSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 32),
                        onPressed: () => context.go('/scan-select'),
                      ),
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cameraswitch,
                            color: Colors.white, size: 32),
                        onPressed: _toggleCamera,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 24,
                  right: 24,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.lightBlueAccent,
                      inactiveTrackColor:
                          Colors.lightBlueAccent.withOpacity(0.3),
                      thumbColor: Colors.lightBlueAccent,
                      overlayColor: Colors.lightBlueAccent.withOpacity(0.125),
                    ),
                    child: Slider(
                      value: _zoomLevel,
                      min: 1.0,
                      max: 5.0,
                      onChanged: (val) {
                        setState(() => _zoomLevel = val);
                        _controller.setZoomLevel(val);
                      },
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect boxRect;
  _OverlayPainter({required this.boxRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final boxPath = Path()..addRRect(RRect.fromRectXY(boxRect, 8, 8));
    final mask = Path.combine(PathOperation.difference, fullPath, boxPath);
    canvas.drawPath(mask, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

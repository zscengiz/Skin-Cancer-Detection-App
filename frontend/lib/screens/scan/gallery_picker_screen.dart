import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/reports/pdf.dart';

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen>
    with SingleTickerProviderStateMixin {
  File? _croppedFile;
  String bodyPart = '';
  late AnimationController _controller;

  final double boxSize = 250;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final uri = GoRouterState.of(context).uri;
    bodyPart = uri.queryParameters['bodyPart'] ?? 'Gallery';

    final permission = await Permission.photos.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
      context.pop();
      return;
    }

    await _pickImageAndCrop();
  }

  Future<void> _pickImageAndCrop() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (picked == null) {
        if (mounted) context.pop();
        return;
      }

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
            hideBottomControls: true,
            cropFrameStrokeWidth: 2,
            showCropGrid: false,
            cropFrameColor: Colors.white,
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (cropped != null && mounted) {
        _croppedFile = File(cropped.path);
        setState(() {});

        const label = 'NV';
        const confidence = 90.0;
        const risk = 'Low risk';
        const advice = 'Monitor occasionally and visit dermatologist annually.';

        final pdfPath = await generatePdfReport(
          imageFile: _croppedFile!,
          label: label,
          confidence: confidence,
          risk: risk,
          advice: advice,
          fullNames: {
            'MEL': 'Melanoma',
            'NV': 'Melanocytic Nevi',
            'BCC': 'Basal Cell Carcinoma',
            'AKIEC': 'Actinic Keratoses',
            'BKL': 'Benign Keratosis',
            'DF': 'Dermatofibroma',
            'VASC': 'Vascular Lesion',
          },
        );

        await ApiService.uploadReport(
          imageFile: _croppedFile!,
          pdfFile: File(pdfPath),
          label: label,
          confidence: confidence,
          riskLevel: risk,
          advice: advice,
        );

        await Future.delayed(const Duration(seconds: 1));
        context.go('/detection-result', extra: _croppedFile!);
      } else if (mounted) {
        context.pop();
      }
    } catch (e) {
      debugPrint('Cropper error: $e');
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: _croppedFile == null
            ? const CircularProgressIndicator(color: Colors.white)
            : Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _croppedFile!,
                      width: boxSize,
                      height: boxSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final position = _controller.value * boxSize;
                      return Positioned(
                        left: position,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          height: boxSize,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

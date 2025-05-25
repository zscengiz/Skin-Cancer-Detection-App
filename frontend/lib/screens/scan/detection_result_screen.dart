import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DetectionResultScreen extends StatefulWidget {
  final File file;

  const DetectionResultScreen({super.key, required this.file});

  @override
  State<DetectionResultScreen> createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>>? _predictions;
  bool _loading = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _pdfPath;

  static const Map<String, String> fullNames = {
    'MEL': 'Melanoma',
    'NV': 'Melanocytic Nevi',
    'BCC': 'Basal Cell Carcinoma',
    'AKIEC': 'Actinic Keratoses and Intraepithelial Carcinoma',
    'BKL': 'Benign Keratosis-like Lesions',
    'DF': 'Dermatofibroma',
    'VASC': 'Vascular Lesions',
  };

  static const Map<String, String> riskLevels = {
    'MEL': 'High risk',
    'NV': 'Low risk',
    'BCC': 'Medium risk',
    'AKIEC': 'High risk',
    'BKL': 'Low risk',
    'DF': 'Low risk',
    'VASC': 'Low risk',
  };

  static const Map<String, String> adviceTexts = {
    'MEL': 'Consult a dermatologist immediately.',
    'NV': 'Monitor occasionally and visit dermatologist annually.',
    'BCC': 'Visit dermatologist soon for potential treatment.',
    'AKIEC': 'Consult dermatologist urgently.',
    'BKL': 'Usually harmless. No intervention needed unless changes occur.',
    'DF': 'Benign. Treatment is rarely needed.',
    'VASC': 'Benign condition. Cosmetic treatment optional.',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _detect();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _detect() async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.0.10:8000/detect"),
      );
      request.files
          .add(await http.MultipartFile.fromPath('file', widget.file.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      final predictions = List<Map<String, dynamic>>.from(data['predictions']);
      setState(() {
        _predictions = predictions;
        _loading = false;
      });

      if (predictions.isNotEmpty) {
        final label = predictions.first['class'];
        final riskText = riskLevels[label] ?? 'Unknown';
        await _saveReport(label, riskText);
      }
    } catch (e) {
      debugPrint("Detection error: $e");
      setState(() {
        _predictions = [];
        _loading = false;
      });
    }
  }

  Future<void> _saveReport(String label, String risk) async {
    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reports');
    final previewsDir = Directory('${dir.path}/previews');
    if (!await reportsDir.exists()) await reportsDir.create(recursive: true);
    if (!await previewsDir.exists()) await previewsDir.create(recursive: true);

    final now = DateTime.now();
    final timestamp =
        "${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}";

    final riskLevel = risk.toLowerCase().contains('high')
        ? 'High'
        : risk.toLowerCase().contains('medium')
            ? 'Medium'
            : 'Low';

    final fileName = "${timestamp}_${riskLevel}_$label.pdf";
    final filePath = "${reportsDir.path}/$fileName";
    final previewPath =
        "${previewsDir.path}/${fileName.replaceAll(".pdf", ".jpg")}";

    final file = File(filePath);
    await file.writeAsBytes([0x25, 0x50, 0x44, 0x46]);

    final previewFile = File(previewPath);
    await previewFile.writeAsBytes(await widget.file.readAsBytes());

    setState(() {
      _pdfPath = filePath;
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Detection Result'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[600],
        elevation: 4,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_pdfPath != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'download') {
                  await Share.shareXFiles([XFile(_pdfPath!)]);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 8),
                      Text('PDF olarak indir'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 20),
                      SizedBox(width: 8),
                      Text('İptal'),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
      body: SafeArea(
        child: _loading ? _buildLoadingView() : _buildResult(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(
          widget.file,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              left: MediaQuery.of(context).size.width * _animation.value,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                color: Colors.greenAccent,
              ),
            );
          },
        ),
        const Positioned(
          bottom: 40,
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text(
                'Analyzing your photo...',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildResult() {
    if (_predictions == null || _predictions!.isEmpty) {
      return const Center(
        child: Text(
          "No lesion detected.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final pred = _predictions!.first;
    final label = pred['class'];
    final confidence = (pred['confidence'] * 100).toStringAsFixed(1);
    final fullLabel = fullNames[label] ?? label;
    final risk = riskLevels[label] ?? 'Unknown';
    final advice = adviceTexts[label] ?? 'No advice available.';
    final Color riskColor = _getRiskColor(risk);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                widget.file,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            label: fullLabel,
            confidence: confidence,
            risk: risk,
            riskColor: riskColor,
            advice: advice,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String confidence,
    required String risk,
    required Color riskColor,
    required String advice,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(),
            const Divider(height: 30),
            _buildField("Diagnosis", label),
            _buildField("Confidence", "$confidence %"),
            _buildField("Risk Level", risk, riskColor),
            _buildField("Advice", advice),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 28),
        const SizedBox(width: 8),
        Text(
          "The photo is suitable",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String title, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high risk':
        return Colors.red;
      case 'medium risk':
        return Colors.orange;
      case 'low risk':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frontend/screens/reports/pdf.dart';

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
        final confidence = predictions.first['confidence'] * 100;
        final risk = riskLevels[label] ?? 'Unknown';
        final advice = adviceTexts[label] ?? '-';

        final path = await generatePdfReport(
          imageFile: widget.file,
          label: label,
          confidence: confidence,
          risk: risk,
          advice: advice,
          fullNames: fullNames,
        );

        setState(() {
          _pdfPath = path;
        });
      }
    } catch (e) {
      debugPrint("Detection error: $e");
      setState(() {
        _predictions = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF0F6FF);
    final textColor = isDark ? Colors.white : const Color(0xFF4991FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: textColor,
              onPressed: () => context.go('/home'),
              tooltip: 'Go to Home',
            ),
            const SizedBox(width: 8),
            Text(
              'Detection Result',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (_pdfPath != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: textColor),
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
                      Text('Download as PDF'),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
      body: SafeArea(
        child: _loading ? _buildLoadingView() : _buildResult(isDark),
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

  Widget _buildResult(bool isDark) {
    if (_predictions == null || _predictions!.isEmpty) {
      return Center(
        child: Text(
          "No lesion detected.",
          style: TextStyle(
              fontSize: 16, color: isDark ? Colors.white : Colors.black),
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
              fullLabel, confidence, risk, riskColor, advice, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String confidence, String risk,
      Color riskColor, String advice, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(isDark),
            const Divider(height: 30),
            _buildField("Diagnosis", label, isDark),
            _buildField("Confidence", "$confidence %", isDark),
            _buildField("Risk Level", risk, isDark, riskColor),
            _buildField("Advice", advice, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(bool isDark) {
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

  Widget _buildField(String title, String value, bool isDark,
      [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
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

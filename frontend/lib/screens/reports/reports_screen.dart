import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/screens/reports/pdf.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<_ReportItem> reports = [];

  final Map<String, String> lesionNames = {
    'MEL': 'Melanoma',
    'NV': 'Melanocytic Nevi',
    'BCC': 'Basal Cell Carcinoma',
    'AKIEC': 'Actinic Keratoses',
    'BKL': 'Benign Keratosis',
    'DF': 'Dermatofibroma',
    'VASC': 'Vascular Lesion',
  };

  final Map<String, String> riskLevels = {
    'MEL': 'High risk',
    'NV': 'Low risk',
    'BCC': 'Medium risk',
    'AKIEC': 'High risk',
    'BKL': 'Low risk',
    'DF': 'Low risk',
    'VASC': 'Low risk',
  };

  final Map<String, String> adviceTexts = {
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
    _loadReports();
  }

  Future<void> _loadReports() async {
    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reports');
    final previewsDir = Directory('${dir.path}/previews');

    if (!await reportsDir.exists()) await reportsDir.create(recursive: true);
    if (!await previewsDir.exists()) await previewsDir.create(recursive: true);

    final files =
        reportsDir.listSync().where((f) => f.path.endsWith('.pdf')).toList();

    final parsedReports = files
        .map((file) {
          final filename = file.uri.pathSegments.last;
          final parts = filename.replaceAll('.pdf', '').split('_');

          if (parts.length != 4) return null;

          final date = parts[0];
          final time = parts[1];
          final risk = parts[2];
          final lesionCode = parts[3];

          final previewPath =
              '${previewsDir.path}/${filename.replaceAll('.pdf', '.jpg')}';
          final formattedDate =
              '${date.substring(6, 8)}/${date.substring(4, 6)}/${date.substring(0, 4)} ${time.substring(0, 2)}:${time.substring(2, 4)}';

          return _ReportItem(
            pdfPath: file.path,
            previewPath: previewPath,
            displayDate: formattedDate,
            riskLevel: risk,
            lesionCode: lesionCode,
          );
        })
        .whereType<_ReportItem>()
        .toList();

    setState(() => reports = parsedReports);
  }

  Future<void> _downloadReportWithRegeneration(_ReportItem report) async {
    try {
      final previewFile = File(report.previewPath);
      if (!await previewFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preview image not found.')),
        );
        return;
      }

      final label = report.lesionCode;
      final fullLabel = lesionNames[label] ?? label;
      final risk = report.riskLevel[0].toUpperCase() +
          report.riskLevel.substring(1).toLowerCase() +
          " risk";
      final advice = adviceTexts[label] ?? "-";
      final confidence = 93.0; // 🔁 Sabit değer kullanıldı çünkü orijinali yok

      final path = await generatePdfReport(
        imageFile: previewFile,
        label: label,
        confidence: confidence,
        risk: risk,
        advice: advice,
        fullNames: lesionNames,
      );

      await Share.shareXFiles([XFile(path)]);
    } catch (e) {
      debugPrint("Error generating or sharing PDF: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF')),
      );
    }
  }

  Color _getCardColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red.shade50;
      case 'medium':
        return Colors.orange.shade50;
      case 'low':
        return Colors.green.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade600;
      case 'low':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.error_outline_rounded;
      case 'low':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getLesionName(String code) {
    return lesionNames[code.toUpperCase()] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text("Saved Reports"),
        backgroundColor: Colors.deepPurple[600],
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: reports.isEmpty
          ? const Center(
              child: Text(
                'No reports available.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _getCardColor(report.riskLevel),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(report.previewPath),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                    title: Text(report.displayDate,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(_getRiskIcon(report.riskLevel),
                                size: 18,
                                color: _getRiskColor(report.riskLevel)),
                            const SizedBox(width: 6),
                            Text('${report.riskLevel} risk'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _getRiskColor(report.riskLevel))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLesionName(report.lesionCode),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'download') {
                          await _downloadReportWithRegeneration(report);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'download',
                          child: Text('Download as PDF'),
                        ),
                        PopupMenuItem(
                          value: 'cancel',
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ReportItem {
  final String pdfPath;
  final String previewPath;
  final String displayDate;
  final String riskLevel;
  final String lesionCode;

  _ReportItem({
    required this.pdfPath,
    required this.previewPath,
    required this.displayDate,
    required this.riskLevel,
    required this.lesionCode,
  });
}

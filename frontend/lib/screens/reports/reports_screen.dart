/// GÖRSEL GÖSTERME VE PDF KAYDETME + 3 NOKTA MENÜLÜ TAM HAL

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> _openReport(String path) async {
    await OpenFile.open(path);
  }

  Future<void> _shareReport(String path) async {
    await Share.shareXFiles([XFile(path)]);
  }

  Color _getCardColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red[100]!;
      case 'medium':
        return Colors.orange[100]!;
      case 'low':
        return Colors.green[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red[700]!;
      case 'medium':
        return Colors.orange[700]!;
      case 'low':
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Icons.warning_amber;
      case 'medium':
        return Icons.error_outline;
      case 'low':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getLesionName(String code) {
    return lesionNames[code.toUpperCase()] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text("Saved Reports"),
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: Colors.black87,
        elevation: 1,
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
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(report.previewPath),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                          ),
                        ),
                      ),
                    ),
                    title: Text(report.displayDate,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getRiskIcon(report.riskLevel),
                                size: 16,
                                color: _getRiskColor(report.riskLevel)),
                            const SizedBox(width: 6),
                            Text('${report.riskLevel} risk'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _getRiskColor(report.riskLevel))),
                          ],
                        ),
                        Text(
                          _getLesionName(report.lesionCode),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'download') {
                          _shareReport(report.pdfPath);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'download',
                          child: Text('PDF olarak indir'),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('İptal'),
                        ),
                      ],
                    ),
                    onTap: () => _openReport(report.pdfPath),
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

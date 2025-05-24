import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:go_router/go_router.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<_ReportItem> reports = [];

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

          if (parts.length != 3) return null;

          final date = parts[0];
          final time = parts[1];
          final risk = parts[2];

          final previewPath =
              '${previewsDir.path}/${filename.replaceAll('.pdf', '.jpg')}';
          final formattedDate =
              '${date.substring(6, 8)}/${date.substring(4, 6)}/${date.substring(0, 4)} ${time.substring(0, 2)}:${time.substring(2, 4)}';

          return _ReportItem(
            pdfPath: file.path,
            previewPath: previewPath,
            displayDate: formattedDate,
            riskStatus: risk,
          );
        })
        .whereType<_ReportItem>()
        .toList();

    setState(() => reports = parsedReports);
  }

  Future<void> _openReport(String path) async {
    await OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Saved Reports"),
        backgroundColor: Colors.blueAccent,
      ),
      body: reports.isEmpty
          ? const Center(child: Text('No reports available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return GestureDetector(
                  onTap: () => _openReport(report.pdfPath),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(report.previewPath),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.displayDate,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                report.riskStatus == 'RISKY'
                                    ? 'Risky'
                                    : 'Non-Risky',
                                style: TextStyle(
                                  color: report.riskStatus == 'RISKY'
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Back to Home',
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _ReportItem {
  final String pdfPath;
  final String previewPath;
  final String displayDate;
  final String riskStatus;

  _ReportItem({
    required this.pdfPath,
    required this.previewPath,
    required this.displayDate,
    required this.riskStatus,
  });
}

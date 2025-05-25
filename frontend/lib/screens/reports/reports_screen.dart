import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/api_endpoints.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:frontend/models/report_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ReportModel> reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final data = await ApiService.getReports();
      for (final r in data) {
        debugPrint(
            "REPORT LOADED: ${r.label} | ${r.confidence} | ${r.riskLevel} | ${r.advice}");
      }
      setState(() {
        reports = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _downloadPdf(String reportId) async {
    final url = ApiEndpoints.getPdf(reportId);
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await ApiService.getAccessToken()}'
    });

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$reportId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(file.path)]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF download failed')),
      );
    }
  }

  Future<Uint8List> _fetchImageWithAuth(String url) async {
    final token = await ApiService.getAccessToken();
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Image load failed');
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high risk':
        return Colors.red.shade100;
      case 'medium risk':
        return Colors.orange.shade100;
      case 'low risk':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Reports"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(child: Text("No reports found."))
              : ListView.builder(
                  itemCount: reports.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final imageUrl = ApiEndpoints.getImage(report.id);
                    return Card(
                      color: _getRiskColor(report.riskLevel),
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FutureBuilder<Uint8List>(
                            future: _fetchImageWithAuth(imageUrl),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                );
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                return const Icon(Icons.image_not_supported);
                              } else {
                                return Image.memory(
                                  snapshot.data!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          ),
                        ),
                        title: Text(
                          report.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Confidence: ${report.confidence.toStringAsFixed(1)}%"),
                            Text("Risk: ${report.riskLevel}"),
                            Text("Advice: ${report.advice}"),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'download') {
                              await _downloadPdf(report.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'download',
                              child: Text("Download PDF"),
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

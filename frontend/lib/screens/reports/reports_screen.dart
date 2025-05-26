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

  Color _getRiskCardColor(String risk, bool isDark) {
    if (isDark) return Colors.grey[850]!;
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

  Color _getRiskTextColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high risk':
        return Colors.red;
      case 'medium risk':
        return Colors.orange;
      case 'low risk':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const lightBg = Color(0xFFF0F6FF);
    const lightText = Color(0xFF4991FF);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : lightBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? Colors.black : lightBg,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: isDark ? Colors.white : lightText,
              onPressed: () => context.go('/home'),
              tooltip: 'Go to Home',
            ),
            const SizedBox(width: 8),
            Text(
              "Saved Reports",
              style: TextStyle(
                color: isDark ? Colors.white : lightText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                  color: isDark ? Colors.white : lightText))
          : reports.isEmpty
              ? Center(
                  child: Text(
                    "No reports found.",
                    style: TextStyle(
                        color: isDark ? Colors.white : lightText, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: reports.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final imageUrl = ApiEndpoints.getImage(report.id);
                    return Card(
                      color: _getRiskCardColor(report.riskLevel, isDark),
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
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
                                      strokeWidth: 2,
                                    ),
                                  ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                isDark ? Colors.white : const Color(0xFF333333),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Confidence: ${report.confidence.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Risk: ${report.riskLevel}",
                              style: TextStyle(
                                fontSize: 14,
                                color: _getRiskTextColor(report.riskLevel),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

class ReportModel {
  final String id;
  final String label;
  final double confidence;
  final String riskLevel;
  final String advice;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.label,
    required this.confidence,
    required this.riskLevel,
    required this.advice,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      label: json['label'],
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: json['risk_level'],
      advice: json['advice'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

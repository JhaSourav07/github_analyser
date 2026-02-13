class ReportModel {
  final String username;
  final int score;
  final String grade; // A, B, C, D, F
  final String summary;
  final Map<String, dynamic> details;

  ReportModel({
    required this.username,
    required this.score,
    required this.grade,
    required this.summary,
    required this.details,
  });

  // Factory constructor to parse JSON
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      username: json['username'] ?? '',
      score: json['score'] ?? 0,
      grade: json['grade'] ?? 'F',
      summary: json['summary'] ?? 'No summary available.',
      details: json['details'] ?? {},
    );
  }
}
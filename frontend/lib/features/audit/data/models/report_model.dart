class ReportModel {
  final String username;
  final String avatarUrl; // New
  final int score;
  final String grade;
  final String summary;
  final List<String> strengths;   // New
  final List<String> weaknesses;  // New
  final List<String> suggestions; // New
  final Map<String, dynamic> details;

  ReportModel({
    required this.username,
    required this.avatarUrl,
    required this.score,
    required this.grade,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
    required this.details,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      score: json['score'] ?? 0,
      grade: json['grade'] ?? 'F',
      summary: json['summary'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      details: json['details'] ?? {},
    );
  }
}
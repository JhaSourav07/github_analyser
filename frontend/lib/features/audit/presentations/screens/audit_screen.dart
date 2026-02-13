import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/audit/data/datasources/audit_api.dart';
import 'package:frontend/features/audit/data/models/report_model.dart';

// --- LOGIC ---
final auditStateProvider = StateNotifierProvider<AuditNotifier, AsyncValue<ReportModel?>>((ref) {
  return AuditNotifier(ref.read(auditApiProvider));
});

class AuditNotifier extends StateNotifier<AsyncValue<ReportModel?>> {
  final AuditApi _api;
  AuditNotifier(this._api) : super(const AsyncData(null));

  Future<void> submitAnalysis(String input) async {
    if (input.isEmpty) return;
    state = const AsyncLoading();
    try {
      final report = await _api.analyzeUser(input);
      state = AsyncData(report);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

// --- UI ---
class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});
  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auditState = ref.watch(auditStateProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('GitHub Portfolio Enhancer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Input Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'GitHub Profile URL or Username',
                        hintText: 'https://github.com/octocat',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auditState.isLoading
                            ? null
                            : () => ref.read(auditStateProvider.notifier).submitAnalysis(_controller.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: auditState.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Analyze Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Results Section
            auditState.when(
              data: (report) {
                if (report == null) return const Center(child: Text("Enter a URL to detect red flags & strengths."));
                return _buildReport(report);
              },
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReport(ReportModel report) {
    return Column(
      children: [
        // Header Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(report.avatarUrl),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.username,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        report.summary,
                        style: TextStyle(color: Colors.grey[700], height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getScoreColor(report.score).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${report.score}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(report.score),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Metrics Grid
        Row(
          children: [
            _buildMetricCard("Original Repos", "${report.details['original_repos']}"),
            const SizedBox(width: 12),
            _buildMetricCard("Stars Earned", "${report.details['stars']}"),
            const SizedBox(width: 12),
            _buildMetricCard("Fork Ratio", "${report.details['fork_ratio']}%"),
          ],
        ),
        const SizedBox(height: 24),

        // Strengths & Weaknesses
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildListSection("Strengths 🟢", report.strengths, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildListSection("Red Flags 🚩", report.weaknesses, Colors.red)),
          ],
        ),
        const SizedBox(height: 24),

        // Actionable Suggestions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🚀 Action Plan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              ...report.suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(s, style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text("None detected", style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text("• $item", style: TextStyle(color: Colors.grey[800], height: 1.3)),
                )),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
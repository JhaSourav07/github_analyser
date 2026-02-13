import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/audit/data/datasources/audit_api.dart';
import 'package:frontend/features/audit/data/models/report_model.dart';

// --- LOGIC (Keep as is) ---
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

// --- ENHANCED UI ---
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
      backgroundColor: const Color(0xFFF8FAFC), // Modern soft slate background
      appBar: AppBar(
        title: const Text(
          'GitHub Portfolio Enhancer',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.1), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(auditState),
            const SizedBox(height: 32),
            auditState.when(
              data: (report) {
                if (report == null) return _buildEmptyState();
                return _buildAnimatedReport(report);
              },
              error: (err, _) => _buildErrorState(err.toString()),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(AsyncValue auditState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter GitHub username or URL',
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: const Icon(Icons.alternate_email_rounded, color: Colors.blueAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: auditState.isLoading
                  ? null
                  : () => ref.read(auditStateProvider.notifier).submitAnalysis(_controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: auditState.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Analyze Impact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          "Ready to scan for red flags?",
          style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAnimatedReport(ReportModel report) {
    return Column(
      children: [
        // Profile Header with Gradient Score
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [_getScoreColor(report.score), Colors.blueAccent]),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(report.avatarUrl),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.username,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.summary,
                          style: TextStyle(color: Colors.grey[600], height: 1.3, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricIcon(Icons.code, "${report.details['original_repos']}", "Repos"),
                  _buildMetricIcon(Icons.star_outline_rounded, "${report.details['stars']}", "Stars"),
                  _buildMetricIcon(Icons.alt_route, "${report.details['fork_ratio']}%", "Forks"),
                  _buildScoreIndicator(report.score),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Strengths & Weaknesses (Vertical stack for better mobile readability)
        _buildSectionCard("Key Strengths", report.strengths, Colors.green, Icons.verified_user_rounded),
        const SizedBox(height: 16),
        _buildSectionCard("Potential Red Flags", report.weaknesses, Colors.redAccent, Icons.report_problem_rounded),
        const SizedBox(height: 20),

        // Action Plan
        _buildActionPlan(report.suggestions),
      ],
    );
  }

  Widget _buildMetricIcon(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }

  Widget _buildScoreIndicator(int score) {
    Color color = _getScoreColor(score);
    return Column(
      children: [
        Text(
          "$score",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
        ),
        Text("SCORE", style: TextStyle(color: color.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<String> items, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text("Perfect! Nothing found.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: CircleAvatar(radius: 2, backgroundColor: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item, style: TextStyle(color: Colors.grey[800], fontSize: 14))),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildActionPlan(List<String> suggestions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🚀 Optimization Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 14))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // Emerald
    if (score >= 50) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }
}
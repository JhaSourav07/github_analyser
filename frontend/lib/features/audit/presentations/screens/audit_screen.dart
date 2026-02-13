import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/audit/data/datasources/audit_api.dart';
import 'package:frontend/features/audit/data/models/report_model.dart';

// --- STATE MANAGEMENT (Logic) ---

// 1. Defines the state of the UI (Loading, Data, or Error)
final auditStateProvider = StateNotifierProvider<AuditNotifier, AsyncValue<ReportModel?>>((ref) {
  return AuditNotifier(ref.read(auditApiProvider));
});

class AuditNotifier extends StateNotifier<AsyncValue<ReportModel?>> {
  final AuditApi _api;

  AuditNotifier(this._api) : super(const AsyncData(null));

  Future<void> submitAnalysis(String username) async {
    if (username.isEmpty) return;

    state = const AsyncLoading(); // Set UI to loading
    try {
      final report = await _api.analyzeUser(username);
      state = AsyncData(report); // Success
    } catch (e, stack) {
      state = AsyncError(e, stack); // Failure
    }
  }
  
  void reset() {
    state = const AsyncData(null);
  }
}

// --- UI CODE (Presentation) ---

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Watch the state from our provider
    final auditState = ref.watch(auditStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Portfolio Analyzer'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            const Text(
              'Enter GitHub Username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'e.g., octocat',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            
            // Action Button
            ElevatedButton(
              onPressed: auditState.isLoading
                  ? null
                  : () {
                      ref
                          .read(auditStateProvider.notifier)
                          .submitAnalysis(_controller.text.trim());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: auditState.isLoading
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Text('Analyze Profile'),
            ),

            const SizedBox(height: 40),

            // Result Section (Handles Loading, Error, and Data states)
            Expanded(
              child: auditState.when(
                data: (report) {
                  if (report == null) {
                    return const Center(
                      child: Text('Enter a username to begin analysis.'),
                    );
                  }
                  return _buildReportView(report);
                },
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Analyzing repositories..."),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to display the results nicely
  Widget _buildReportView(ReportModel report) {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Score Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: report.score / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: _getScoreColor(report.score),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${report.score}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Grade ${report.grade}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(report.score),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Summary
              Text(
                "Recruiter Verdict",
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.grey.shade600
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.summary,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
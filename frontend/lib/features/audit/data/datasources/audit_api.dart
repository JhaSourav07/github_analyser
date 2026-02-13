import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/report_model.dart';

// 1. The Provider for this Repository
final auditApiProvider = Provider<AuditApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuditApi(dio);
});

// 2. The Class containing the methods
class AuditApi {
  final Dio _dio;

  AuditApi(this._dio);

  Future<ReportModel> analyzeUser(String username) async {
    try {
      // Calls POST /api/v1/audit/{username} (Adjust based on your backend routes)
      final response = await _dio.post('/api/v1/audit', data: {
        'username': username,
      });

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      // Simple error handling for the hackathon
      throw Exception(e.response?.data['detail'] ?? 'Failed to analyze user');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/report_model.dart';

final auditApiProvider = Provider<AuditApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuditApi(dio);
});

class AuditApi {
  final Dio _dio;

  AuditApi(this._dio);

  Future<ReportModel> analyzeUser(String input) async {
    try {
      // Changed key to match backend Pydantic model
      final response = await _dio.post('/api/v1/audit', data: {
        'profile_url_or_username': input,
      });

      return ReportModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to analyze user');
      }
      throw Exception('Connection error. Is the backend running?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
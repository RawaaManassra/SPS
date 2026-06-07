import 'dart:async';
import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/admin/complaints/models/admin_complaint.dart';

class AdminComplaintService {
  AdminComplaintService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<AdminComplaint>> getComplaints({String? status}) async {
    final accessToken = await _readAccessToken();
    final url = status == null || status.isEmpty
        ? ApiConstants.complaintsUrl
        : '${ApiConstants.complaintsUrl}?status=$status';

    try {
      final response = await _apiClient
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 15));

      final decoded = response.body.isEmpty ? <dynamic>[] : jsonDecode(response.body);
      final items = decoded is List ? decoded : <dynamic>[];

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(AdminComplaint.fromJson)
            .toList();
      }

      throw AdminComplaintException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const AdminComplaintException(
        'استغرق تحميل الشكاوى وقتاً أطول من المتوقع. حاولي مرة أخرى.',
      );
    } catch (error) {
      if (error is AdminComplaintException) rethrow;
      throw const AdminComplaintException(
        'تعذر تحميل الشكاوى حالياً.',
      );
    }
  }

  Future<void> updateComplaintStatus({
    required int complaintId,
    required String status,
  }) async {
    final accessToken = await _readAccessToken();
    final url =
        '${ApiConstants.complaintsUrl}$complaintId/status?status=$status';

    try {
      final response = await _apiClient
          .patchJson(
            url,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw AdminComplaintException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const AdminComplaintException(
        'استغرق تحديث حالة الشكوى وقتاً أطول من المتوقع. حاولي مرة أخرى.',
      );
    } catch (error) {
      if (error is AdminComplaintException) rethrow;
      throw const AdminComplaintException(
        'تعذر تحديث حالة الشكوى حالياً.',
      );
    }
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const AdminComplaintException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) return 'تعذر تنفيذ الطلب حالياً.';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {
      return 'تعذر تنفيذ الطلب حالياً.';
    }
    return 'تعذر تنفيذ الطلب حالياً.';
  }
}

class AdminComplaintException implements Exception {
  const AdminComplaintException(this.message);

  final String message;
}

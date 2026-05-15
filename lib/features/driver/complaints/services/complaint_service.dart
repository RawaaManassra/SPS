import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/complaints/models/driver_complaint.dart';

class ComplaintService {
  ComplaintService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<DriverComplaint>> getComplaints({String? status}) async {
    final accessToken = await _readAccessToken();
    final query = status == null || status.isEmpty ? '' : '?status=$status';
    final response = await _apiClient.get(
      '${ApiConstants.complaintsUrl}$query',
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as List<dynamic>;
      return jsonBody
          .map((item) => DriverComplaint.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ComplaintException(_readErrorMessage(response.body));
  }

  Future<void> createComplaint({
    required String complaintType,
    required String description,
  }) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.postJson(
      ApiConstants.createComplaintUrl,
      body: {
        'complaint_type': complaintType,
        'description': description,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ComplaintException(_readErrorMessage(response.body));
  }

  Future<void> deleteComplaint(int complaintId) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.delete(
      ApiConstants.deleteComplaintUrl(complaintId),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ComplaintException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ComplaintException('تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.');
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تنفيذ طلب الشكاوى حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    } catch (_) {
      return 'تعذر تنفيذ طلب الشكاوى حالياً.';
    }

    return 'تعذر تنفيذ طلب الشكاوى حالياً.';
  }
}

class ComplaintException implements Exception {
  const ComplaintException(this.message);

  final String message;
}

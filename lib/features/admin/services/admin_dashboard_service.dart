import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/admin/models/admin_dashboard_data.dart';

class AdminDashboardService {
  AdminDashboardService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<AdminDashboardData> getDashboard() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.adminDashboardUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final jsonBody = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminDashboardData.fromJson(jsonBody);
    }

    throw AdminDashboardException(_readErrorMessage(jsonBody));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const AdminDashboardException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(Map<String, dynamic> jsonBody) {
    final detail = jsonBody['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    return 'تعذر تحميل بيانات لوحة البلدية حالياً.';
  }
}

class AdminDashboardException implements Exception {
  const AdminDashboardException(this.message);

  final String message;
}

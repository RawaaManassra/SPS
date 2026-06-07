import 'dart:async';
import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/admin/inspectors/models/admin_add_inspector_request.dart';

class AdminInspectorService {
  AdminInspectorService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> addInspector(AdminAddInspectorRequest request) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .postJson(
            ApiConstants.adminAddInspectorUrl,
            body: request.toJson(),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 20));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw AdminInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const AdminInspectorException(
        'استغرق حفظ بيانات المفتش وقتاً أطول من المتوقع. تأكد من أن الباك اند يعمل ثم حاول مرة أخرى.',
      );
    } catch (error) {
      if (error is AdminInspectorException) rethrow;
      throw const AdminInspectorException(
        'تعذر حفظ بيانات المفتش حالياً. حاول مرة أخرى أو راجع الباك اند.',
      );
    }
  }

  Future<void> deleteInspector(int inspectorId) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .delete(
            ApiConstants.adminDeleteInspectorUrl(inspectorId),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 20));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw AdminInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const AdminInspectorException(
        'استغرق حذف المفتش وقتاً أطول من المتوقع. تأكد من أن الباك اند يعمل ثم حاول مرة أخرى.',
      );
    } catch (error) {
      if (error is AdminInspectorException) rethrow;
      throw const AdminInspectorException(
        'تعذر حذف المفتش حالياً. حاول مرة أخرى أو راجع الباك اند.',
      );
    }
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const AdminInspectorException(
        'تعذر التحقق من الجلسة الحالية. سجل الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(Map<String, dynamic> jsonBody) {
    final detail = jsonBody['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      switch (detail) {
        case 'Inspector is already registered':
          return 'يوجد مفتش مسجل مسبقاً بهذا الرقم.';
        case 'Email already exists':
          return 'البريد الإلكتروني مستخدم مسبقاً.';
        case 'Admin access required':
          return 'هذا الحساب لا يملك صلاحية إدارة البلدية.';
        case "Inspector doesn't exist":
          return 'المفتش غير موجود.';
        default:
          return detail;
      }
    }
    return 'تعذر تنفيذ الطلب على المفتش حالياً.';
  }

  Map<String, dynamic> _decodeJsonMap(String responseBody) {
    if (responseBody.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return <String, dynamic>{'detail': responseBody};
    }

    return <String, dynamic>{};
  }
}

class AdminInspectorException implements Exception {
  const AdminInspectorException(this.message);

  final String message;
}

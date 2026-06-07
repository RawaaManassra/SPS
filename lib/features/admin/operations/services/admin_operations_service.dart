import 'dart:async';
import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/admin/clamps/models/admin_clamp_event.dart';
import 'package:flut/features/admin/fines/models/admin_fine.dart';
import 'package:flut/features/admin/violations/models/admin_violation_type.dart';

class AdminOperationsService {
  AdminOperationsService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<AdminFine>> getFines({String? status}) async {
    final accessToken = await _readAccessToken();
    final url = status == null || status.isEmpty
        ? '${ApiConstants.baseUrl}/admins/fines'
        : '${ApiConstants.baseUrl}/admins/fines?status=$status';

    try {
      final response = await _apiClient
          .get(url, headers: {'Authorization': 'Bearer $accessToken'})
          .timeout(const Duration(seconds: 15));

      final items = _decodeList(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(AdminFine.fromJson)
            .toList();
      }
      throw AdminOperationsException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const AdminOperationsException(
        'استغرق تحميل المخالفات وقتاً أطول من المتوقع.',
      );
    } catch (error) {
      if (error is AdminOperationsException) rethrow;
      throw const AdminOperationsException('تعذر تحميل المخالفات حالياً.');
    }
  }

  Future<List<AdminClampEvent>> getClampEvents({String? status}) async {
    final accessToken = await _readAccessToken();
    final url = status == null || status.isEmpty
        ? '${ApiConstants.baseUrl}/admins/clamp_events'
        : '${ApiConstants.baseUrl}/admins/clamp_events?status=$status';

    try {
      final response = await _apiClient
          .get(url, headers: {'Authorization': 'Bearer $accessToken'})
          .timeout(const Duration(seconds: 15));

      final items = _decodeList(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(AdminClampEvent.fromJson)
            .toList();
      }
      throw AdminOperationsException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const AdminOperationsException(
        'استغرق تحميل سجلات الكلبشة وقتاً أطول من المتوقع.',
      );
    } catch (error) {
      if (error is AdminOperationsException) rethrow;
      throw const AdminOperationsException(
        'تعذر تحميل سجلات الكلبشة حالياً.',
      );
    }
  }

  Future<List<AdminViolationType>> getViolationTypes() async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .get(
            ApiConstants.inspectorViolationTypesUrl,
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(const Duration(seconds: 15));

      final items = _decodeList(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(AdminViolationType.fromJson)
            .toList();
      }
      throw AdminOperationsException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const AdminOperationsException(
        'استغرق تحميل أنواع المخالفات وقتاً أطول من المتوقع.',
      );
    } catch (error) {
      if (error is AdminOperationsException) rethrow;
      throw const AdminOperationsException(
        'تعذر تحميل أنواع المخالفات حالياً.',
      );
    }
  }

  Future<void> addViolationType({
    required String name,
    required double amount,
  }) async {
    final accessToken = await _readAccessToken();
    final encodedName = Uri.encodeQueryComponent(name);
    final url =
        '${ApiConstants.baseUrl}/admins/violation_types?name=$encodedName&amount=$amount';

    try {
      final response = await _apiClient
          .postJson(
            url,
            body: const {},
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }
      throw AdminOperationsException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const AdminOperationsException(
        'استغرق حفظ نوع المخالفة وقتاً أطول من المتوقع.',
      );
    } catch (error) {
      if (error is AdminOperationsException) rethrow;
      throw const AdminOperationsException(
        'تعذر حفظ نوع المخالفة حالياً.',
      );
    }
  }

  Future<void> updateViolationType({
    required int violationId,
    required String name,
    required double amount,
  }) async {
    final accessToken = await _readAccessToken();
    final encodedName = Uri.encodeQueryComponent(name);
    final url =
        '${ApiConstants.baseUrl}/admins/violation_types/$violationId?name=$encodedName&amount=$amount';

    try {
      final response = await _apiClient
          .putJson(
            url,
            body: const {},
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }
      throw AdminOperationsException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const AdminOperationsException(
        'استغرق تحديث نوع المخالفة وقتاً أطول من المتوقع.',
      );
    } catch (error) {
      if (error is AdminOperationsException) rethrow;
      throw const AdminOperationsException(
        'تعذر تحديث نوع المخالفة حالياً.',
      );
    }
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const AdminOperationsException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  List<dynamic> _decodeList(String body) {
    if (body.isEmpty) return <dynamic>[];
    try {
      final decoded = jsonDecode(body);
      return decoded is List ? decoded : <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
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

class AdminOperationsException implements Exception {
  const AdminOperationsException(this.message);

  final String message;
}

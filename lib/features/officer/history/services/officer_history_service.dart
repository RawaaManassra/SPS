import 'dart:async';
import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/officer/history/models/officer_history_item.dart';

class OfficerHistoryService {
  OfficerHistoryService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<OfficerHistoryItem>> getHistory() async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .get(
            ApiConstants.inspectorHistoryUrl,
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(const Duration(seconds: 15));

      final decoded =
          response.body.isEmpty ? <dynamic>[] : jsonDecode(response.body);
      final items = decoded is List ? decoded : <dynamic>[];

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(OfficerHistoryItem.fromJson)
            .toList();
      }

      throw OfficerHistoryException(_readErrorMessage(response.body));
    } on TimeoutException {
      throw const OfficerHistoryException(
        'استغرق تحميل سجل الشرطي وقتاً أطول من المتوقع. حاولي مرة أخرى.',
      );
    } catch (error) {
      if (error is OfficerHistoryException) rethrow;
      throw const OfficerHistoryException(
        'تعذر تحميل سجل الشرطي حالياً.',
      );
    }
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const OfficerHistoryException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تحميل سجل الشرطي حالياً.';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {
      return 'تعذر تحميل سجل الشرطي حالياً.';
    }

    return 'تعذر تحميل سجل الشرطي حالياً.';
  }
}

class OfficerHistoryException implements Exception {
  const OfficerHistoryException(this.message);

  final String message;
}

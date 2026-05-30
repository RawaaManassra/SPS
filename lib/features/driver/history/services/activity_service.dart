import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/history/models/driver_activity_item.dart';

class ActivityService {
  ActivityService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<DriverActivityItem>> getActivity() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.activityUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as List<dynamic>;
      return jsonBody
          .map((item) => DriverActivityItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ActivityException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ActivityException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تحميل سجل النشاط حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        if (detail == 'Invalid token') {
          return 'الجلسة الحالية غير صالحة. سجلي الدخول مرة أخرى.';
        }
        return detail;
      }
    } catch (_) {
      return 'تعذر تحميل سجل النشاط حالياً.';
    }

    return 'تعذر تحميل سجل النشاط حالياً.';
  }
}

class ActivityException implements Exception {
  const ActivityException(this.message);

  final String message;
}

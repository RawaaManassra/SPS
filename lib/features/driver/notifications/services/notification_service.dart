import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/notifications/models/driver_notification.dart';

class NotificationService {
  NotificationService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<DriverNotification>> getNotifications() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.notificationsUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as List<dynamic>;
      return jsonBody
          .map((item) => DriverNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw NotificationException(_readErrorMessage(response.body));
  }

  Future<void> markAsRead(int notificationId) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.patchJson(
      ApiConstants.markNotificationReadUrl(notificationId),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw NotificationException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const NotificationException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تنفيذ طلب الإشعارات حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        switch (detail) {
          case 'Notification not found':
            return 'تعذر العثور على هذا الإشعار.';
          case 'Invalid token':
            return 'الجلسة الحالية غير صالحة. سجلي الدخول مرة أخرى.';
          default:
            return detail;
        }
      }
    } catch (_) {
      return 'تعذر تنفيذ طلب الإشعارات حالياً.';
    }

    return 'تعذر تنفيذ طلب الإشعارات حالياً.';
  }
}

class NotificationException implements Exception {
  const NotificationException(this.message);

  final String message;
}

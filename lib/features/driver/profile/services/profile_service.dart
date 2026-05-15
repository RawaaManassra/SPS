import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/profile/models/driver_user_profile.dart';

class ProfileService {
  ProfileService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<DriverUserProfile> getCurrentUser() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.authMeUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return DriverUserProfile.fromJson(jsonBody);
    }

    throw ProfileException(_readErrorMessage(response.body));
  }

  Future<void> updateProfile({
    required String username,
    required String fullName,
    required String phoneNumber,
    String? email,
  }) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.putJson(
      ApiConstants.updateProfileUrl,
      body: {
        'username': username,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ProfileException(_readErrorMessage(response.body));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.postJson(
      ApiConstants.changePasswordUrl,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ProfileException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ProfileException('تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.');
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تنفيذ طلب الحساب حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return _translateBackendMessage(detail);
      }
    } catch (_) {
      return 'تعذر تنفيذ طلب الحساب حالياً.';
    }

    return 'تعذر تنفيذ طلب الحساب حالياً.';
  }

  String _translateBackendMessage(String detail) {
    switch (detail) {
      case 'Current password is incorrect':
        return 'كلمة المرور الحالية غير صحيحة.';
      case 'Invalid token':
        return 'الجلسة الحالية غير صالحة. سجلي الدخول مرة أخرى.';
      case 'User not found':
        return 'تعذر العثور على بيانات المستخدم الحالية.';
      default:
        return detail;
    }
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;
}

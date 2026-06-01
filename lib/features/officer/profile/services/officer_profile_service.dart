import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/officer/profile/models/officer_user_profile.dart';

class OfficerProfileService {
  OfficerProfileService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<OfficerUserProfile> getCurrentUser() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.authMeUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return OfficerUserProfile.fromJson(jsonBody);
    }

    throw OfficerProfileException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const OfficerProfileException(
        'تعذر التحقق من الجلسة الحالية. سجل الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تحميل بيانات الحساب حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    } catch (_) {
      return 'تعذر تحميل بيانات الحساب حالياً.';
    }

    return 'تعذر تحميل بيانات الحساب حالياً.';
  }
}

class OfficerProfileException implements Exception {
  const OfficerProfileException(this.message);

  final String message;
}

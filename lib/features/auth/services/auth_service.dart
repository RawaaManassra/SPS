import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/auth/models/login_result.dart';

class AuthService {
  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<LoginResult> login({
    required String nationalId,
    required String password,
  }) async {
    final response = await _apiClient.postForm(
      ApiConstants.loginUrl,
      body: {
        'username': nationalId,
        'password': password,
      },
    );

    final jsonBody = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final result = LoginResult.fromJson(jsonBody);
      await _tokenStorage.save(
        accessToken: result.accessToken,
        tokenType: result.tokenType,
      );
      return result;
    }

    final detail = jsonBody['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      throw AuthException(detail);
    }

    throw const AuthException('تعذر تسجيل الدخول حالياً. حاولي مرة أخرى.');
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

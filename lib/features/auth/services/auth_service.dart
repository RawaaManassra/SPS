import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/auth/models/login_result.dart';
import 'package:flut/features/auth/models/register_request.dart';

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

    throw AuthException(_readErrorMessage(jsonBody));
  }

  Future<void> register(RegisterRequest request) async {
    final response = await _apiClient.postJson(
      ApiConstants.registerUrl,
      body: request.toJson(),
    );

    final jsonBody = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw AuthException(_readErrorMessage(jsonBody));
  }

  Future<void> clearSession() {
    return _tokenStorage.clear();
  }

  String _readErrorMessage(Map<String, dynamic> jsonBody) {
    final detail = jsonBody['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return _translateBackendMessage(detail);
    }

    return 'تعذر إكمال الطلب حالياً. حاولي مرة أخرى.';
  }

  String _translateBackendMessage(String detail) {
    switch (detail) {
      case "User doesn't exist":
        return 'لا يوجد حساب مرتبط برقم الهوية المدخل.';
      case 'Password is not correct':
        return 'كلمة المرور غير صحيحة.';
      case 'User already exists':
        return 'يوجد حساب مسجل مسبقاً بهذا الرقم.';
      case 'Passwords do not match':
        return 'كلمتا المرور غير متطابقتين.';
      default:
        return detail;
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

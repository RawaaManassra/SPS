import 'dart:async';
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
    final response = await _apiClient
        .postForm(
          ApiConstants.loginUrl,
          body: {
            'username': nationalId,
            'password': password,
          },
        )
        .timeout(const Duration(seconds: 20));

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

  Future<String> getCurrentRole() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient
        .get(
          ApiConstants.authMeUrl,
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        )
        .timeout(const Duration(seconds: 15));

    final jsonBody = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final role = (jsonBody['role'] ?? '').toString().trim();
      if (role.isEmpty) {
        throw const AuthException('تعذر تحديد نوع الحساب الحالي.');
      }
      return role;
    }

    throw AuthException(_readErrorMessage(jsonBody));
  }

  Future<void> register(RegisterRequest request) async {
    final response = await _apiClient
        .postJson(
          ApiConstants.registerUrl,
          body: request.toJson(),
        )
        .timeout(const Duration(seconds: 20));

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

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.');
    }
    return accessToken;
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
      case 'Invalid token':
        return 'الجلسة الحالية غير صالحة. سجلي الدخول مرة أخرى.';
      case 'User not found':
        return 'تعذر العثور على بيانات المستخدم الحالية.';
      default:
        return detail;
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

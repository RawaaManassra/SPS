import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/violations/models/driver_fine.dart';

class FineService {
  FineService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<DriverFine>> getDriverFines() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.driverFinesUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as List<dynamic>;
      return jsonBody
          .map((item) => DriverFine.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw FineException(_readErrorMessage(response.body));
  }

  Future<void> payFine(int fineId) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.postJson(
      ApiConstants.payFineUrl(fineId),
      body: const {},
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw FineException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const FineException('تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.');
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تنفيذ طلب المخالفات حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return _translateBackendMessage(detail);
      }
    } catch (_) {
      return 'تعذر تنفيذ طلب المخالفات حالياً.';
    }

    return 'تعذر تنفيذ طلب المخالفات حالياً.';
  }

  String _translateBackendMessage(String detail) {
    switch (detail) {
      case 'Fine not found':
        return 'تعذر العثور على هذه المخالفة.';
      case 'Fine already paid':
        return 'هذه المخالفة مدفوعة بالفعل.';
      case 'Violation type not found':
        return 'تعذر قراءة نوع المخالفة.';
      case 'Insufficient balance':
        return 'رصيد المحفظة غير كافٍ لدفع هذه المخالفة.';
      case 'Invalid token':
        return 'الجلسة الحالية غير صالحة. سجلي الدخول مرة أخرى.';
      default:
        return detail;
    }
  }
}

class FineException implements Exception {
  const FineException(this.message);

  final String message;
}

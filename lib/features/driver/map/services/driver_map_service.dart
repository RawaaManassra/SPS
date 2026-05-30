import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/map/models/driver_map_data.dart';

class DriverMapService {
  DriverMapService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<DriverMapData> getMapData() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.mapUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return DriverMapData.fromJson(jsonBody);
    }

    throw DriverMapException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const DriverMapException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تحميل بيانات الخريطة حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    } catch (_) {
      return 'تعذر تحميل بيانات الخريطة حالياً.';
    }

    return 'تعذر تحميل بيانات الخريطة حالياً.';
  }
}

class DriverMapException implements Exception {
  const DriverMapException(this.message);

  final String message;

  @override
  String toString() => message;
}

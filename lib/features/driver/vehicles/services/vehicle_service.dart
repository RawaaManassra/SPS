import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';

class VehicleService {
  VehicleService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> addVehicle({
    required String licensePlate,
    required String vehicleType,
    required bool isDefault,
    String color = 'غير محدد',
  }) async {
    final accessToken = await _tokenStorage.readAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw const VehicleException(
        'تعذر التحقق من الجلسة بعد إنشاء الحساب.',
      );
    }

    final response = await _apiClient.postJson(
      ApiConstants.vehiclesUrl,
      body: {
        'license_plate': licensePlate,
        'vehicle_type': vehicleType,
        'color': color,
        'is_default': isDefault,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final jsonBody = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    final detail = jsonBody['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      throw VehicleException(detail);
    }

    throw const VehicleException('تعذر حفظ بيانات المركبة حالياً.');
  }
}

class VehicleException implements Exception {
  const VehicleException(this.message);

  final String message;
}

import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/vehicles/models/driver_vehicle.dart';

class VehicleService {
  VehicleService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<DriverVehicle>> getVehicles() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.vehiclesListUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as List<dynamic>;
      return jsonBody
          .map((item) => DriverVehicle.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw VehicleException(_readErrorMessage(response.body));
  }

  Future<void> addVehicle({
    required String licensePlate,
    required String vehicleType,
    String color = 'غير محدد',
  }) async {
    final accessToken = await _readAccessToken();

    final response = await _apiClient.postJson(
      ApiConstants.addVehicleUrl,
      body: {
        'license_plate': licensePlate,
        'vehicle_type': vehicleType,
        'color': color,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw VehicleException(_readErrorMessage(response.body));
  }

  Future<void> updateVehicle({
    required int vehicleId,
    required String licensePlate,
    required String vehicleType,
    required String color,
  }) async {
    final accessToken = await _readAccessToken();

    final response = await _apiClient.putJson(
      ApiConstants.updateVehicleUrl(vehicleId),
      body: {
        'license_plate': licensePlate,
        'vehicle_type': vehicleType,
        'color': color,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw VehicleException(_readErrorMessage(response.body));
  }

  Future<void> setDefaultVehicle(int vehicleId) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.patchJson(
      ApiConstants.setDefaultVehicleUrl(vehicleId),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw VehicleException(_readErrorMessage(response.body));
  }

  Future<void> deleteVehicle(int vehicleId) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.delete(
      ApiConstants.deleteVehicleUrl(vehicleId),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw VehicleException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw const VehicleException('تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.');
    }

    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تنفيذ طلب المركبات حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return _translateBackendMessage(detail);
      }
    } catch (_) {
      return 'تعذر تنفيذ طلب المركبات حالياً.';
    }

    return 'تعذر تنفيذ طلب المركبات حالياً.';
  }

  String _translateBackendMessage(String detail) {
    switch (detail) {
      case "Vehicle doesn't exist":
        return 'المركبة غير موجودة.';
      case 'Vehicle not found':
        return 'تعذر العثور على المركبة المطلوبة.';
      case 'Cannot delete vehicle with active session':
        return 'لا يمكن حذف مركبة لديها جلسة وقوف نشطة.';
      default:
        return detail;
    }
  }
}

class VehicleException implements Exception {
  const VehicleException(this.message);

  final String message;
}

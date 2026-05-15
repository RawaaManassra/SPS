import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/parking/driver_parking_session.dart';
import 'package:flut/features/driver/vehicles/models/driver_vehicle.dart';

class ParkingService {
  ParkingService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> startSession({
    required int vehicleId,
    required int durationMinutes,
    required double lat,
    required double lng,
  }) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.postJson(
      ApiConstants.startSessionUrl,
      body: {
        'vehicle_id': vehicleId,
        'duration_minutes': durationMinutes,
        'lat': lat,
        'lng': lng,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ParkingException(_readErrorMessage(response.body));
  }

  Future<void> endSession({
    required int vehicleId,
  }) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.postJson(
      ApiConstants.endSessionUrl,
      body: {
        'vehicle_id': vehicleId,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ParkingException(_readErrorMessage(response.body));
  }

  Future<void> extendSession({
    required int vehicleId,
    required int durationMinutes,
  }) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.postJson(
      ApiConstants.extendSessionUrl,
      body: {
        'vehicle_id': vehicleId,
        'duration_minutes': durationMinutes,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ParkingException(_readErrorMessage(response.body));
  }

  Future<DriverParkingSession?> getActiveSession(List<DriverVehicle> vehicles) async {
    if (vehicles.isEmpty) {
      return null;
    }

    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.activeSessionsUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ParkingException(_readErrorMessage(response.body));
    }

    final jsonBody = jsonDecode(response.body) as List<dynamic>;
    final vehiclesById = {
      for (final vehicle in vehicles) vehicle.id: vehicle,
    };

    Map<String, dynamic> matchingSession = const {};
    for (final rawItem in jsonBody) {
      final item = rawItem as Map<String, dynamic>;
      final vehicleId = item['vehicle_id'] as int?;
      final status = item['status'] as String? ?? '';
      if (status == 'active' && vehicleId != null && vehiclesById.containsKey(vehicleId)) {
        matchingSession = item;
        break;
      }
    }

    if (matchingSession.isEmpty) {
      return null;
    }

    final vehicle = vehiclesById[matchingSession['vehicle_id'] as int]!;
    return DriverParkingSession.fromBackendJson(
      matchingSession,
      vehicle: vehicle,
    );
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ParkingException('تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.');
    }

    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تنفيذ طلب جلسة الوقوف حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return _translateBackendMessage(detail);
      }
    } catch (_) {
      return 'تعذر تنفيذ طلب جلسة الوقوف حالياً.';
    }

    return 'تعذر تنفيذ طلب جلسة الوقوف حالياً.';
  }

  String _translateBackendMessage(String detail) {
    switch (detail) {
      case 'Duration must be in 30-minute intervals':
        return 'يجب أن تكون مدة الوقوف من مضاعفات 30 دقيقة.';
      case 'Vehicle already has an active session':
        return 'هذه المركبة لديها جلسة وقوف نشطة بالفعل.';
      case 'Insufficient balance':
        return 'الرصيد غير كافٍ لبدء أو تمديد الجلسة.';
      case 'There is no active session to end':
        return 'لا توجد جلسة نشطة يمكن إنهاؤها.';
      case 'There is no active session to extend':
        return 'لا توجد جلسة نشطة يمكن تمديدها.';
      default:
        return detail;
    }
  }
}

class ParkingException implements Exception {
  const ParkingException(this.message);

  final String message;
}

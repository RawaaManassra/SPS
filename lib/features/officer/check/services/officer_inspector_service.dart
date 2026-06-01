import 'dart:async';
import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/officer/check/models/officer_vehicle_check_result.dart';
import 'package:flut/features/officer/check/models/officer_violation_type.dart';

class OfficerInspectorService {
  OfficerInspectorService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<OfficerVehicleCheckResult> checkVehicle(String licensePlate) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .get(
            ApiConstants.inspectorCheckVehicleUrl(
              Uri.encodeComponent(licensePlate),
            ),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 15));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final normalizedBody = <String, dynamic>{
          ...jsonBody,
          'license_plate': (jsonBody['license_plate'] ?? licensePlate).toString(),
        };
        return OfficerVehicleCheckResult.fromJson(normalizedBody);
      }

      throw OfficerInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const OfficerInspectorException(
        'استغرق فحص المركبة وقتاً أطول من المتوقع. تأكدي من أن الباك اند يعمل ثم حاولي مرة أخرى.',
      );
    }
  }

  Future<String> extractPlateFromImage(String imagePath) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .postMultipartFile(
            ApiConstants.extractPlateUrl,
            fieldName: 'file',
            filePath: imagePath,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 20));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final plate = (jsonBody['plate'] ?? '').toString().trim();
        if (plate.isEmpty) {
          throw const OfficerInspectorException(
            'لم يتم استخراج رقم اللوحة من الصورة.',
          );
        }
        return plate;
      }

      throw OfficerInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const OfficerInspectorException(
        'استغرق استخراج رقم اللوحة وقتاً أطول من المتوقع. حاولي مرة أخرى.',
      );
    }
  }

  Future<String> uploadEvidenceImage(String imagePath) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .postMultipartFile(
            ApiConstants.uploadImageUrl,
            fieldName: 'file',
            filePath: imagePath,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 20));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final url = (jsonBody['url'] ?? '').toString().trim();
        if (url.isEmpty) {
          throw const OfficerInspectorException(
            'تعذر رفع صورة الدليل حالياً.',
          );
        }
        return url;
      }

      throw OfficerInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const OfficerInspectorException(
        'استغرق رفع صورة الدليل وقتاً أطول من المتوقع. حاولي مرة أخرى.',
      );
    }
  }

  Future<List<OfficerViolationType>> getViolationTypes() async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .get(
            ApiConstants.inspectorViolationTypesUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 15));

      final decoded = response.body.isEmpty ? <dynamic>[] : jsonDecode(response.body);
      final jsonBody = decoded is List ? decoded : <dynamic>[];

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonBody
            .whereType<Map<String, dynamic>>()
            .map(OfficerViolationType.fromJson)
            .toList();
      }

      throw const OfficerInspectorException(
        'تعذر تحميل أنواع المخالفات حالياً.',
      );
    } on TimeoutException {
      throw const OfficerInspectorException(
        'استغرق تحميل أنواع المخالفات وقتاً أطول من المتوقع. حاولي مرة أخرى.',
      );
    }
  }

  Future<void> issueFine({
    required int vehicleId,
    required int violationTypeId,
    required double latitude,
    required double longitude,
    String? photoUrl,
  }) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .postJson(
            ApiConstants.inspectorSetFineUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
            body: {
              'inspector_id': 0,
              'vehicle_id': vehicleId,
              'photo_url': photoUrl,
              'violation_type_id': violationTypeId,
              'lat': latitude,
              'lng': longitude,
            },
          )
          .timeout(const Duration(seconds: 20));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw OfficerInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const OfficerInspectorException(
        'استغرق إصدار المخالفة وقتاً أطول من المتوقع. تأكدي من أن الباك اند يعمل ثم حاولي مرة أخرى.',
      );
    } catch (error) {
      if (error is OfficerInspectorException) rethrow;
      throw const OfficerInspectorException(
        'تعذر إصدار المخالفة حالياً. راجعي الباك اند أو حاولي مرة أخرى.',
      );
    }
  }

  Future<void> setClamp({
    required String licensePlate,
    required String reason,
    required String vehicleType,
    required String color,
    required double latitude,
    required double longitude,
    String? photoUrl,
  }) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .postJson(
            ApiConstants.inspectorSetClampUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
            body: {
              'vehicle_id': 0,
              'inspector_id': 0,
              'license_plate': licensePlate,
              'reason': reason,
              'photo_url': photoUrl,
              'vehicle_type': vehicleType,
              'color': color,
              'lat': latitude,
              'lng': longitude,
            },
          )
          .timeout(const Duration(seconds: 20));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw OfficerInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const OfficerInspectorException(
        'استغرق تنفيذ طلب الكلبشة وقتاً أطول من المتوقع. تأكدي من أن الباك اند يعمل ثم حاولي مرة أخرى.',
      );
    } catch (error) {
      if (error is OfficerInspectorException) rethrow;
      throw const OfficerInspectorException(
        'تعذر تسجيل كلبشة السيارة حالياً. راجعي الباك اند أو حاولي مرة أخرى.',
      );
    }
  }

  Future<void> unclamp({
    required String licensePlate,
  }) async {
    final accessToken = await _readAccessToken();

    try {
      final response = await _apiClient
          .postJson(
            ApiConstants.inspectorUnclampUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
            body: {
              'license_plate': licensePlate,
            },
          )
          .timeout(const Duration(seconds: 20));

      final jsonBody = _decodeJsonMap(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      throw OfficerInspectorException(_readErrorMessage(jsonBody));
    } on TimeoutException {
      throw const OfficerInspectorException(
        'استغرق تنفيذ طلب إزالة الكلبشة وقتاً أطول من المتوقع. تأكدي من أن الباك اند يعمل ثم حاولي مرة أخرى.',
      );
    } catch (error) {
      if (error is OfficerInspectorException) rethrow;
      throw const OfficerInspectorException(
        'تعذر إزالة الكلبشة حالياً. راجعي الباك اند أو حاولي مرة أخرى.',
      );
    }
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const OfficerInspectorException(
        'تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.',
      );
    }
    return accessToken;
  }

  String _readErrorMessage(Map<String, dynamic> jsonBody) {
    final detail = jsonBody['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      switch (detail) {
        case 'Could not validate credentials':
          return 'بيانات الدخول الحالية غير صالحة لهذا الطلب.';
        case 'Not authorized':
        case 'Inspector access required':
          return 'هذا الحساب لا يملك صلاحية موظف التفتيش.';
        default:
          return detail;
      }
    }

    return 'تعذر تنفيذ الطلب حالياً.';
  }

  Map<String, dynamic> _decodeJsonMap(String responseBody) {
    if (responseBody.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return <String, dynamic>{
        'detail': responseBody,
      };
    }

    return <String, dynamic>{};
  }
}

class OfficerInspectorException implements Exception {
  const OfficerInspectorException(this.message);

  final String message;
}

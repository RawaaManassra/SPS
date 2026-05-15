import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    return 'http://10.0.2.2:8000';
  }

  static String get loginUrl => '$baseUrl/auth/login';
  static String get registerUrl => '$baseUrl/auth/register';
  static String get authMeUrl => '$baseUrl/auth/me';
  static String get vehiclesListUrl => '$baseUrl/vehicles/';
  static String get addVehicleUrl => '$baseUrl/vehicles/add-vehicle';
  static String deleteVehicleUrl(int vehicleId) => '$baseUrl/vehicles/$vehicleId';
  static String updateVehicleUrl(int vehicleId) => '$baseUrl/vehicles/$vehicleId';
  static String setDefaultVehicleUrl(int vehicleId) => '$baseUrl/vehicles/$vehicleId/set-default';
  static String get walletUrl => '$baseUrl/wallets/';
  static String get walletTransactionsUrl => '$baseUrl/wallets/transactions';
  static String get walletTopUpUrl => '$baseUrl/wallets/top_up';
  static String get updateProfileUrl => '$baseUrl/users/me';
  static String get changePasswordUrl => '$baseUrl/users/change-password';
  static String get activeSessionsUrl => '$baseUrl/sessions/active_sessions';
  static String get startSessionUrl => '$baseUrl/sessions/start_session';
  static String get endSessionUrl => '$baseUrl/sessions/end_session';
  static String get extendSessionUrl => '$baseUrl/sessions/extend_session';
  static String get driverFinesUrl => '$baseUrl/fines/driver_fines';
  static String payFineUrl(int fineId) => '$baseUrl/fines/$fineId/pay';
  static String get complaintsUrl => '$baseUrl/complaints/';
  static String get createComplaintUrl => '$baseUrl/complaints/create_complaint';
  static String deleteComplaintUrl(int complaintId) => '$baseUrl/complaints/delete_complaint/$complaintId';
}

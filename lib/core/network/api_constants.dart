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
  static String get vehiclesUrl => '$baseUrl/vehicles/add-vehicle';
}

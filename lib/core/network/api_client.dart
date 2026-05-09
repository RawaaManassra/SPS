import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  const ApiClient();

  Future<http.Response> postForm(
    String url, {
    required Map<String, String> body,
    Map<String, String>? headers,
  }) {
    return http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        ...?headers,
      },
      body: body,
      encoding: utf8,
    );
  }

  Future<http.Response> postJson(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    return http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
      encoding: utf8,
    );
  }
}

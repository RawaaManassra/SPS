import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  const ApiClient();

  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
  }) {
    return http.get(
      Uri.parse(url),
      headers: <String, String>{
        ...?headers,
      },
    );
  }

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

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) {
    return http.delete(
      Uri.parse(url),
      headers: <String, String>{
        ...?headers,
      },
    );
  }

  Future<http.Response> putJson(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    return http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
      encoding: utf8,
    );
  }

  Future<http.Response> patchJson(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    return http.patch(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body == null ? null : jsonEncode(body),
      encoding: utf8,
    );
  }

  Future<http.Response> postMultipartFile(
    String url, {
    required String fieldName,
    required String filePath,
    Map<String, String>? headers,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(<String, String>{
      ...?headers,
    });
    if (fields != null) {
      request.fields.addAll(fields);
    }
    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        filename: File(filePath).uri.pathSegments.last,
      ),
    );

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}

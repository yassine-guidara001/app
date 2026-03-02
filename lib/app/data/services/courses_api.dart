import 'dart:convert';

import 'package:flutter_getx_app/app/core/service/storage_service.dart';
import 'package:flutter_getx_app/app/data/models/course_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CoursesApi {
  static const String baseUrl = 'http://193.111.250.244:3046/api';

  final StorageService _storageService;

  CoursesApi({StorageService? storageService})
      : _storageService = storageService ?? Get.find<StorageService>();

  Future<String> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/local'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier.trim(),
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = _decodeMap(response.body);
      final token = (decoded['jwt'] ?? '').toString().trim();
      if (token.isEmpty) {
        throw Exception('LOGIN Error: JWT manquant');
      }

      await _storageService.saveToken(token);
      await _storageService.write('jwt', token);
      await _storageService.write('token', token);
      return token;
    }

    throw _buildHttpException('LOGIN', response);
  }

  Future<List<Course>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses?sort=createdAt:desc'),
      headers: _headersJson(),
    );

    if (_isSuccess(response.statusCode)) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final items = decoded['data'] as List<dynamic>;
        return items
            .whereType<Map>()
            .map((e) => Course.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Course.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      return <Course>[];
    }

    throw _buildHttpException('GET_COURSES', response);
  }

  Future<Course> getCourseById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$id'),
      headers: _headersJson(),
    );

    if (_isSuccess(response.statusCode)) {
      return Course.fromJson(_decodeMap(response.body));
    }

    throw _buildHttpException('GET_COURSE_BY_ID', response);
  }

  Future<Course> createCourse(Course course) async {
    final payload =
        _sanitizeCoursePayload(course.toJson(withDataWrapper: false));

    print('📤 [CREATE_COURSE] Payload: $payload');

    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: _headersJson(),
      body: jsonEncode({'data': payload}),
    );

    if (_isSuccess(response.statusCode)) {
      return Course.fromJson(_decodeMap(response.body));
    }

    throw _buildHttpException('CREATE_COURSE', response);
  }

  Future<Course> updateCourse(Course course) async {
    final payload =
        _sanitizeCoursePayload(course.toJson(withDataWrapper: false));

    print('📤 [UPDATE_COURSE] Payload: $payload');

    final candidateUris = <Uri>[
      if (course.documentId.trim().isNotEmpty)
        Uri.parse(
            '$baseUrl/courses/${Uri.encodeComponent(course.documentId.trim())}'),
      if (course.id > 0) Uri.parse('$baseUrl/courses/${course.id}'),
    ];

    if (candidateUris.isEmpty) {
      throw Exception('UPDATE_COURSE Error: identifiant manquant');
    }

    http.Response? lastResponse;

    for (final uri in candidateUris) {
      final response = await http.put(
        uri,
        headers: _headersJson(),
        body: jsonEncode({'data': payload}),
      );

      lastResponse = response;

      if (_isSuccess(response.statusCode)) {
        if (response.body.trim().isEmpty) {
          return course;
        }
        return Course.fromJson(_decodeMap(response.body));
      }

      if (response.statusCode == 404) {
        continue;
      }

      break;
    }

    if (lastResponse != null) {
      throw _buildHttpException('UPDATE_COURSE', lastResponse);
    }

    throw Exception('UPDATE_COURSE Error: aucune réponse serveur');
  }

  Future<void> deleteCourse({required int id, String? documentId}) async {
    final trimmedDocumentId = documentId?.trim() ?? '';

    final candidateUris = <Uri>[
      if (trimmedDocumentId.isNotEmpty)
        Uri.parse('$baseUrl/courses/${Uri.encodeComponent(trimmedDocumentId)}'),
      if (id > 0) Uri.parse('$baseUrl/courses/$id'),
    ];

    if (candidateUris.isEmpty) {
      throw Exception('DELETE_COURSE Error: identifiant manquant');
    }

    http.Response? lastResponse;

    for (final uri in candidateUris) {
      final response = await http.delete(
        uri,
        headers: _headersJson(),
      );

      lastResponse = response;

      if (_isSuccess(response.statusCode)) {
        return;
      }

      if (response.statusCode == 404) {
        continue;
      }

      break;
    }

    if (lastResponse != null) {
      throw _buildHttpException('DELETE_COURSE', lastResponse);
    }

    throw Exception('DELETE_COURSE Error: aucune réponse serveur');
  }

  Map<String, String> _headersJson() {
    final token = _readToken();
    if (token == null || token.isEmpty) {
      throw Exception('Auth Error: token JWT manquant');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  String? _readToken() {
    final token = _storageService.getToken() ??
        _storageService.read<String>('jwt') ??
        _storageService.read<String>('token');

    if (token == null) return null;

    final normalized = token.trim();
    if (normalized.toLowerCase().startsWith('bearer ')) {
      return normalized.substring(7).trim();
    }

    return normalized;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> _sanitizeCoursePayload(Map<String, dynamic> source) {
    final payload = Map<String, dynamic>.from(source);

    final rawStatus = payload['status']?.toString().trim();
    payload['mystatus'] =
        (rawStatus == null || rawStatus.isEmpty) ? 'Brouillon' : rawStatus;

    // Strapi renvoie 400: Invalid key "status" => on envoie mystatus uniquement.
    payload.remove('status');

    return payload;
  }

  Exception _buildHttpException(String action, http.Response response) {
    final code = response.statusCode;
    final message = _extractErrorMessage(response.body);

    if (code == 401) {
      print('❌ [$action] 401 Unauthorized: $message');
      return Exception('401 Unauthorized: $message');
    }

    if (code == 403) {
      print('❌ [$action] 403 Forbidden: $message');
      return Exception('403 Forbidden: $message');
    }

    if (code >= 500) {
      print('❌ [$action] 500 Server Error: $message');
      return Exception('500 Server Error: $message');
    }

    print('❌ [$action] HTTP $code: $message');
    return Exception('HTTP $code: $message');
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message != null) return message.toString();
        }

        final message = decoded['message'];
        if (message != null) return message.toString();
      }
    } catch (_) {
      // ignore
    }

    return body;
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Format JSON inattendu');
  }
}

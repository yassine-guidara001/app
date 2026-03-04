import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_getx_app/app/core/service/auth_service.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:flutter_getx_app/models/assignment_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AssignmentsApi {
  static const String _baseApiUrl = 'http://193.111.250.244:3046/api';
  static const String _serverBaseUrl = 'http://193.111.250.244:3046';
  static const Duration _requestTimeout = Duration(seconds: 20);

  final AuthService _authService;

  AssignmentsApi({AuthService? authService})
      : _authService = authService ?? Get.find<AuthService>();

  Future<List<Assignment>> getAssignments() async {
    final userId = _authService.currentUserId;

    final populateQuery = [
      'populate=course',
      'populate=submissions',
      'populate=attachment',
    ].join('&');

    final filteredUri = Uri.parse(
      userId == null
          ? '$_baseApiUrl/assignments?$populateQuery'
          : '$_baseApiUrl/assignments?filters[course][instructor][id][\$eq]=$userId&$populateQuery',
    );

    final fallbackUri = Uri.parse('$_baseApiUrl/assignments?$populateQuery');

    final candidateUris = <Uri>[
      filteredUri,
      if (filteredUri.toString() != fallbackUri.toString()) fallbackUri,
    ];

    http.Response? lastResponse;

    for (final uri in candidateUris) {
      debugPrint('[AssignmentsAPI] GET $uri');

      final response = await http
          .get(uri, headers: _authService.authHeaders)
          .timeout(_requestTimeout);

      _logResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = _decodeMap(response.body);
        final data = decoded['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map(
                (item) => Assignment.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
        return const <Assignment>[];
      }

      lastResponse = response;

      if (response.statusCode == 400 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        continue;
      }

      _throwIfError(response);
    }

    if (lastResponse != null) {
      _throwIfError(lastResponse);
    }

    return const <Assignment>[];
  }

  Future<Assignment> getAssignmentById(
    int id, {
    String? documentId,
  }) async {
    final trimmedDocumentId = documentId?.trim() ?? '';
    final candidateUris = <Uri>[
      if (trimmedDocumentId.isNotEmpty)
        Uri.parse(
            '$_baseApiUrl/assignments/${Uri.encodeComponent(trimmedDocumentId)}?populate=*'),
      Uri.parse('$_baseApiUrl/assignments/$id?populate=*'),
    ];

    http.Response? lastResponse;

    for (final uri in candidateUris) {
      debugPrint('[AssignmentsAPI] GET $uri');

      final response = await http
          .get(uri, headers: _authService.authHeaders)
          .timeout(_requestTimeout);

      _logResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Assignment.fromJson(_decodeMap(response.body));
      }

      lastResponse = response;

      if (response.statusCode == 404) {
        continue;
      }

      _throwIfError(response);
    }

    if (lastResponse != null) {
      _throwIfError(lastResponse);
    }

    throw Exception('Ressource introuvable');
  }

  Future<Assignment> createAssignment(Map data) async {
    final uri = Uri.parse('$_baseApiUrl/assignments');
    final payload = {'data': _sanitizePayload(Map<String, dynamic>.from(data))};

    debugPrint('[AssignmentsAPI] POST $uri');
    debugPrint('[AssignmentsAPI] Payload: $payload');

    final response = await http
        .post(
          uri,
          headers: _authService.authHeaders,
          body: jsonEncode(payload),
        )
        .timeout(_requestTimeout);

    _logResponse(response);
    _throwIfError(response);

    return Assignment.fromJson(_decodeMap(response.body));
  }

  Future<Assignment> updateAssignment(int id, Map data,
      {String? documentId}) async {
    final identifier = (documentId != null && documentId.trim().isNotEmpty)
        ? documentId.trim()
        : '$id';
    final uri = Uri.parse('$_baseApiUrl/assignments/$identifier');
    final payload = {'data': _sanitizePayload(Map<String, dynamic>.from(data))};

    debugPrint('[AssignmentsAPI] PUT $uri');
    debugPrint('[AssignmentsAPI] Payload: $payload');

    http.Response response = await http
        .put(
          uri,
          headers: _authService.authHeaders,
          body: jsonEncode(payload),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 405) {
      debugPrint('[AssignmentsAPI] PUT non autorisé, tentative PATCH $uri');
      response = await http
          .patch(
            uri,
            headers: _authService.authHeaders,
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);
    }

    _logResponse(response);
    _throwIfError(response);

    return Assignment.fromJson(_decodeMap(response.body));
  }

  Future<void> deleteAssignment(int id) async {
    final uri = Uri.parse('$_baseApiUrl/assignments/$id');
    debugPrint('[AssignmentsAPI] DELETE $uri');

    final response = await http
        .delete(uri, headers: _authService.authHeaders)
        .timeout(_requestTimeout);
    _logResponse(response);
    _throwIfError(response);
  }

  Future<Map<String, dynamic>> uploadAttachment(dynamic file) async {
    final uri = Uri.parse('$_baseApiUrl/upload');
    debugPrint('[AssignmentsAPI] POST $uri (upload)');

    final token = _authService.token;
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée');
    }

    final bytes = _extractFileBytes(file);
    final path = _extractFilePath(file);
    final filename = _extractFileName(file);

    final hasBytes = bytes != null && bytes.isNotEmpty;
    final hasPath = path != null && path.isNotEmpty;

    if ((!hasBytes && !hasPath) || filename.isEmpty) {
      throw Exception('Fichier invalide pour upload');
    }

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    if (hasPath && !kIsWeb) {
      request.files.add(await http.MultipartFile.fromPath('files', path));
    } else {
      request.files.add(
        http.MultipartFile.fromBytes('files', bytes!, filename: filename),
      );
    }

    final streamed = await request.send().timeout(_requestTimeout);
    final response = await http.Response.fromStream(streamed);

    _logResponse(response);
    _throwIfError(response);

    final decoded = jsonDecode(response.body);
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, dynamic>) {
        final fileId = _toIntNullable(first['id']);
        if (fileId == null) {
          throw Exception('ID de fichier introuvable');
        }

        final rawUrl = (first['url'] ?? '').toString();
        if (rawUrl.isEmpty) {
          throw Exception('URL de fichier introuvable');
        }

        final fileUrl =
            rawUrl.startsWith('http') ? rawUrl : '$_serverBaseUrl$rawUrl';

        return {
          'id': fileId,
          'url': fileUrl,
          'name': (first['name'] ?? filename).toString(),
        };
      }
    }

    throw Exception('Réponse upload invalide');
  }

  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> source) {
    final normalizedDescription =
        _normalizeDescription(source['description'] ?? source['instructions']);
    final hasAttachmentField =
        source.containsKey('attachment') || source.containsKey('attachmentId');
    final resolvedCourse = _resolveCourseRelation(source);

    final attachmentValue = source.containsKey('attachmentId')
        ? source['attachmentId']
        : source['attachment'];

    final payload = <String, dynamic>{
      'title': source['title'],
      'description': normalizedDescription,
      'course': resolvedCourse,
      'due_date': source['due_date'] ?? source['dueDate'],
      'max_points': source['max_points'] ?? source['maxPoints'] ?? 100,
      'passing_score': source['passing_score'] ??
          source['passingGrade'] ??
          source['passing_grade'] ??
          0,
      'allow_late_submission': source['allow_late_submission'] ??
          source['allowLateSubmission'] ??
          false,
      'attachment': attachmentValue,
    };

    payload.removeWhere(
      (key, value) =>
          value == null && !(hasAttachmentField && key == 'attachment'),
    );
    return payload;
  }

  dynamic _resolveCourseRelation(Map<String, dynamic> source) {
    final rawCourse = source['course'];
    final fallbackCourseId =
        _toIntNullable(source['courseId'] ?? source['course_id']);

    if (rawCourse is int) return rawCourse;
    if (rawCourse is num) return rawCourse.toInt();
    if (fallbackCourseId != null) return fallbackCourseId;

    if (rawCourse is String) {
      final trimmed = rawCourse.trim();
      if (trimmed.isEmpty) return null;
      final numeric = int.tryParse(trimmed);
      if (numeric != null) return numeric;
      return trimmed;
    }

    return rawCourse;
  }

  List<Map<String, dynamic>>? _normalizeDescription(dynamic value) {
    if (value == null) return null;

    if (value is List) {
      final list = value.whereType<Map>().map((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
      return list.isEmpty ? null : list;
    }

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    return [
      {
        'type': 'paragraph',
        'children': [
          {'type': 'text', 'text': text}
        ],
      }
    ];
  }

  void _logResponse(http.Response response) {
    debugPrint(
        '[AssignmentsAPI] Response ${response.statusCode} ${response.request?.url.path}');
    debugPrint('[AssignmentsAPI] Body: ${response.body}');
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final message = _extractMessage(response.body);

    if (response.statusCode == 400) {
      throw Exception('Données invalides');
    }

    if (response.statusCode == 401) {
      _authService.handleUnauthorized();
      if (Get.currentRoute != Routes.LOGIN) {
        Get.offAllNamed(Routes.LOGIN);
      }
      throw Exception('Session expirée');
    }

    if (response.statusCode == 403) {
      throw Exception('Accès refusé');
    }

    if (response.statusCode == 404) {
      throw Exception('Ressource introuvable');
    }

    if (response.statusCode >= 500) {
      throw Exception('Erreur serveur');
    }

    throw Exception(message);
  }

  String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['error']?['message']?.toString() ??
            decoded['message']?.toString() ??
            'Erreur inconnue';
      }
    } catch (_) {
      // ignore
    }
    return 'Connexion impossible';
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }

  Uint8List? _extractFileBytes(dynamic file) {
    if (file is Map<String, dynamic>) {
      final dynamic bytes = file['bytes'];
      if (bytes is Uint8List) return bytes;
      if (bytes is List<int>) return Uint8List.fromList(bytes);
    }
    return null;
  }

  String? _extractFilePath(dynamic file) {
    if (file is Map<String, dynamic>) {
      final path = file['path']?.toString().trim();
      if (path != null && path.isNotEmpty) {
        return path;
      }
    }
    return null;
  }

  String _extractFileName(dynamic file) {
    if (file is Map<String, dynamic>) {
      final name = file['name']?.toString() ?? '';
      return name.trim();
    }
    return '';
  }

  int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

import 'dart:convert';

import 'package:flutter_getx_app/app/core/service/auth_service.dart';
import 'package:flutter_getx_app/app/data/models/training_session_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TrainingSessionsApi {
  static const String _baseApiUrl = 'http://193.111.250.244:3046/api';

  final AuthService _authService;

  TrainingSessionsApi({AuthService? authService})
      : _authService = authService ?? Get.find<AuthService>();

  Future<List<TrainingSession>> getSessions() async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final endpoint =
        '/training-sessions?populate=attendees&populate=course&sort=start_datetime:desc&_ts=$ts';
    final response = await _get(endpoint);
    final decoded = _decodeMap(response.body);
    final data = decoded['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) =>
              TrainingSession.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const [];
  }

  Future<TrainingSession> getSession(dynamic id) async {
    final endpoint =
        '/training-sessions/$id?populate=attendees&populate=course';
    final response = await _get(endpoint);
    return TrainingSession.fromJson(_decodeMap(response.body));
  }

  Future<TrainingSession> createSession(TrainingSession session) async {
    final data = _sanitizePayload(session.toStrapiData());
    final response = await _post(
      '/training-sessions',
      {'data': data},
    );
    return TrainingSession.fromJson(_decodeMap(response.body));
  }

  Future<TrainingSession> updateSession(
      dynamic id, TrainingSession session) async {
    final data = _sanitizePayload(session.toStrapiData());
    final response = await _put(
      '/training-sessions/$id',
      {'data': data},
    );
    return TrainingSession.fromJson(_decodeMap(response.body));
  }

  Future<void> deleteSession(dynamic id) async {
    await _delete('/training-sessions/$id');
  }

  Future<TrainingSession> updateSessionAttendees(
    dynamic id, {
    required List<int> attendeeIds,
  }) async {
    final response = await _put(
      '/training-sessions/$id',
      {
        'data': {
          'attendees': attendeeIds,
        }
      },
    );
    return TrainingSession.fromJson(_decodeMap(response.body));
  }

  Future<http.Response> _get(String endpoint) async {
    final uri = Uri.parse('$_baseApiUrl$endpoint');
    print('📡 GET $uri');
    final response = await http.get(uri, headers: _authService.authHeaders);
    _logResponse(response);
    _throwIfError(response);
    return response;
  }

  Future<http.Response> _post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_baseApiUrl$endpoint');
    print('📡 POST $uri');
    print('📦 Payload: $payload');
    final response = await http.post(
      uri,
      headers: _authService.authHeaders,
      body: jsonEncode(payload),
    );
    _logResponse(response);
    _throwIfError(response);
    return response;
  }

  Future<http.Response> _put(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_baseApiUrl$endpoint');
    print('📡 PUT $uri');
    print('📦 Payload: $payload');
    final response = await http.put(
      uri,
      headers: _authService.authHeaders,
      body: jsonEncode(payload),
    );
    _logResponse(response);
    _throwIfError(response);
    return response;
  }

  Future<http.Response> _delete(String endpoint) async {
    final uri = Uri.parse('$_baseApiUrl$endpoint');
    print('📡 DELETE $uri');
    final response = await http.delete(uri, headers: _authService.authHeaders);
    _logResponse(response);
    _throwIfError(response);
    return response;
  }

  void _logResponse(http.Response response) {
    print('✅ Réponse ${response.statusCode}: ${response.request?.url.path}');
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final decoded = _decodeBody(response.body);
    final strapiMessage = decoded['error']?['message']?.toString() ??
        decoded['message']?.toString() ??
        'Erreur inconnue';

    if (response.statusCode == 401) {
      print('❌ 401 Unauthorized: $strapiMessage');
      _authService.handleUnauthorized();
      throw Exception('Session expirée, reconnectez-vous');
    }

    if (response.statusCode == 403) {
      print('❌ 403 Forbidden: $strapiMessage');
      throw Exception('Accès interdit');
    }

    if (response.statusCode == 404) {
      print('❌ 404 Not Found: $strapiMessage');
      throw Exception('Ressource introuvable');
    }

    if (response.statusCode == 422) {
      print('❌ 422 Validation: $strapiMessage');
      throw Exception(strapiMessage);
    }

    if (response.statusCode >= 500) {
      print('❌ 500 Server Error: $strapiMessage');
      throw Exception('Erreur serveur');
    }

    print('❌ HTTP ${response.statusCode}: $strapiMessage');
    throw Exception(strapiMessage);
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = _decodeBody(body);
    return decoded;
  }

  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> source) {
    final cleaned = Map<String, dynamic>.from(source);

    cleaned.removeWhere((key, value) => value == null);

    return cleaned;
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }
}

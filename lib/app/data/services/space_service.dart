import 'dart:convert';

import 'package:flutter_getx_app/app/core/service/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/space_model.dart';

class SpaceApi {
  static const String baseUrl = 'http://193.111.250.244:3046/api';

  // Certains backends acceptent uniquement /spaces (sans slash final),
  // d'autres uniquement /spaces/ (avec slash). On supporte les deux.
  static Uri _spacesCollectionUri({Map<String, String>? queryParameters}) {
    return Uri.parse('$baseUrl/spaces').replace(
      queryParameters: queryParameters,
    );
  }

  static Uri _spacesCollectionUriAlt({Map<String, String>? queryParameters}) {
    return Uri.parse('$baseUrl/spaces/').replace(
      queryParameters: queryParameters,
    );
  }

  static Uri _spaceItemUri(String documentId,
      {Map<String, String>? queryParameters}) {
    final encoded = Uri.encodeComponent(documentId.trim());
    return Uri.parse('$baseUrl/spaces/$encoded').replace(
      queryParameters: queryParameters,
    );
  }

  static Uri _spaceItemUriAlt(String documentId,
      {Map<String, String>? queryParameters}) {
    final encoded = Uri.encodeComponent(documentId.trim());
    return Uri.parse('$baseUrl/spaces/$encoded/').replace(
      queryParameters: queryParameters,
    );
  }

  static Future<String?> _getToken() async {
    try {
      final storage = Get.find<StorageService>();
      final raw = storage.getToken() ??
          storage.read<String>('jwt') ??
          storage.read<String>('token');

      if (raw == null) return null;

      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.toLowerCase().startsWith('bearer ')) {
        return trimmed.substring(7).trim();
      }

      return trimmed;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>> _headers(
      {required bool includeJson}) async {
    final token = await _getToken();
    return {
      if (includeJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _headersGet() =>
      _headers(includeJson: false);

  static Future<Map<String, String>> _headersJson() =>
      _headers(includeJson: true);

  static Map<String, dynamic> _toPayload(Map body) {
    final data = <String, dynamic>{};

    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      data[key] = value;
    }

    put('name', body['name']);

    data['slug'] = body['slug'] ??
        body['name'].toString().trim().replaceAll(' ', '-').toLowerCase();

    put('type', body['type']);
    put('location', body['location']);
    put('floor', body['floor']);
    put('description', body['description']);

    put('capacity', body['capacity']);
    put('area_sqm', body['area_sqm']);
    put('svg_width', body['svg_width']);
    put('svg_height', body['svg_height']);
    put('availability_status', body['availability_status']);

    put('is_coworking', body['is_coworking']);
    put('allow_guest_reservations', body['allow_guest_reservations']);

    put('hourly_rate', body['hourly_rate']);
    put('daily_rate', body['daily_rate']);
    put('monthly_rate', body['monthly_rate']);
    put('currency', body['currency']);

    return {'data': data};
  }

  static Future<List<Space>> getSpaces({
    bool populate = false,
    bool forceRefresh = false,
  }) async {
    final headers = await _headersGet();
    final allSpaces = <Space>[];
    var page = 1;
    final refreshToken =
        forceRefresh ? DateTime.now().millisecondsSinceEpoch.toString() : null;

    while (true) {
      final query = <String, String>{
        if (populate) 'populate': '*',
        'sort': 'createdAt:desc',
        'pagination[page]': '$page',
        'pagination[pageSize]': '25',
        if (refreshToken != null) '_t': refreshToken,
      };

      http.Response res = await http.get(
        _spacesCollectionUri(queryParameters: query),
        headers: headers,
      );

      if (res.statusCode == 404) {
        res = await http.get(
          _spacesCollectionUriAlt(queryParameters: query),
          headers: headers,
        );
      }

      if (res.statusCode != 200) {
        throw Exception(_errorMessage(res));
      }

      final decoded = jsonDecode(res.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      if (data is! List) break;

      final chunk = data.map((e) => Space.fromJson(e)).toList().cast<Space>();
      allSpaces.addAll(chunk);

      final meta = decoded is Map<String, dynamic> ? decoded['meta'] : null;
      final pagination =
          meta is Map<String, dynamic> ? meta['pagination'] : null;
      final pageCount = pagination is Map<String, dynamic>
          ? int.tryParse('${pagination['pageCount'] ?? ''}')
          : null;

      // If pagination metadata is missing, treat response as fully loaded.
      if (pageCount == null || page >= pageCount || chunk.isEmpty) {
        break;
      }

      page++;
    }

    return allSpaces;
  }

  static Future<Space> getSpace(String documentId,
      {bool populate = false}) async {
    final query = populate ? const {'populate': '*'} : null;
    http.Response res = await http.get(
      _spaceItemUri(documentId, queryParameters: query),
      headers: await _headersGet(),
    );

    if (res.statusCode == 404) {
      res = await http.get(
        _spaceItemUriAlt(documentId, queryParameters: query),
        headers: await _headersGet(),
      );
    }

    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res));
    }

    return _parseSpaceFromResponse(res);
  }

  static Future<Space> createSpace(Map body) async {
    http.Response res = await http.post(
      _spacesCollectionUri(),
      headers: await _headersJson(),
      body: jsonEncode(_toPayload(body)),
    );

    if (res.statusCode == 404) {
      res = await http.post(
        _spacesCollectionUriAlt(),
        headers: await _headersJson(),
        body: jsonEncode(_toPayload(body)),
      );
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_errorMessage(res));
    }

    return _parseSpaceFromResponse(res);
  }

  static Future<Space> updateSpace(String documentId, Map body) async {
    final uri = _spaceItemUri(documentId);
    final uriAlt = _spaceItemUriAlt(documentId);
    final headers = await _headersJson();
    final payload = jsonEncode(_toPayload(body));

    http.Response res = await http.put(
      uri,
      headers: headers,
      body: payload,
    );

    // Certains backends refusent PUT et attendent PATCH.
    if (res.statusCode == 405) {
      res = await http.patch(
        uri,
        headers: headers,
        body: payload,
      );
    }

    // Fallback variante avec slash final
    if (res.statusCode == 404) {
      res = await http.put(
        uriAlt,
        headers: headers,
        body: payload,
      );
      if (res.statusCode == 405) {
        res = await http.patch(
          uriAlt,
          headers: headers,
          body: payload,
        );
      }
    }

    // Certains backends renvoient 204 (No Content) après update.
    if (res.statusCode == 204 || res.body.trim().isEmpty) {
      return getSpace(documentId, populate: true);
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_errorMessage(res));
    }

    return _parseSpaceFromResponse(res);
  }

  static Future<void> deleteSpace(String documentId) async {
    final trimmedDocumentId = documentId.trim();

    if (trimmedDocumentId.isEmpty) {
      throw Exception(
          'documentId manquant: impossible de supprimer cet espace');
    }

    final headers = await _headersGet();
    if (!headers.containsKey('Authorization')) {
      throw Exception('Session expirée: reconnectez-vous puis réessayez');
    }

    final res = await http.delete(
      _spaceItemUri(trimmedDocumentId),
      headers: headers,
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }

    throw Exception(_errorMessage(res));
  }

  static Space _parseSpaceFromResponse(http.Response res) {
    if (res.body.trim().isEmpty) {
      throw Exception('Réponse vide du serveur');
    }

    final decoded = jsonDecode(res.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw Exception('Format de réponse inattendu');
    }

    return Space.fromJson(data);
  }

  static String _errorMessage(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
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

    return 'Erreur HTTP ${res.statusCode}: ${res.body}';
  }
}

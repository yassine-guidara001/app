import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/space_model.dart';

class SpaceApi {
  static const String baseUrl = 'http://193.111.250.244:3046/api';
  static const FlutterSecureStorage storage = FlutterSecureStorage();

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
    final token = await storage.read(key: 'jwt');
    if (token == null || token.trim().isEmpty) return null;
    return token;
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

  static Future<List<Space>> getSpaces({bool populate = false}) async {
    final query = populate ? const {'populate': '*'} : null;
    http.Response res = await http.get(
      _spacesCollectionUri(queryParameters: query),
      headers: await _headersGet(),
    );

    if (res.statusCode == 404) {
      res = await http.get(
        _spacesCollectionUriAlt(queryParameters: query),
        headers: await _headersGet(),
      );
    }

    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res));
    }

    final decoded = jsonDecode(res.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is! List) return <Space>[];

    return data.map((e) => Space.fromJson(e)).toList().cast<Space>();
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
    final headersGet = await _headersGet();
    final headersJson = await _headersJson();

    final trimmedDocumentId = documentId.trim();

    assert(() {
      // Debug only: aide à vérifier si on supprime bien via documentId.
      print('DELETE Space documentId="$trimmedDocumentId"');
      print(
          'DELETE URIs: ${_spaceItemUri(trimmedDocumentId)} | ${_spaceItemUriAlt(trimmedDocumentId)}');
      return true;
    }());

    if (trimmedDocumentId.isEmpty) {
      throw Exception(
          'documentId manquant: impossible de supprimer cet espace');
    }

    Future<http.Response?> tryDeleteWithUris(List<Uri> uris) async {
      http.Response? lastResponse;
      for (final uri in uris) {
        try {
          var res = await http.delete(uri, headers: headersGet);

          // Certains backends/proxys exigent un Content-Type même sur DELETE.
          if (res.statusCode == 400 || res.statusCode == 415) {
            res = await http.delete(uri, headers: headersJson);
          }

          lastResponse = res;

          // Succès: Strapi/serveurs peuvent renvoyer 200, 202, 204...
          if (res.statusCode >= 200 && res.statusCode < 300) {
            return res;
          }

          // Si c'est 404, on tente la variante suivante (slash / no-slash).
          if (res.statusCode == 404) {
            continue;
          }

          // Autres erreurs: inutile de retenter l'autre URL dans la plupart des cas.
          break;
        } catch (_) {
          continue;
        }
      }
      return lastResponse;
    }

    // Suppression par documentId (Strapi v5)
    final byDocumentId = await tryDeleteWithUris([
      _spaceItemUri(trimmedDocumentId),
      _spaceItemUriAlt(trimmedDocumentId),
    ]);

    if (byDocumentId != null &&
        byDocumentId.statusCode >= 200 &&
        byDocumentId.statusCode < 300) {
      return;
    }

    if (byDocumentId != null) {
      throw Exception(_errorMessage(byDocumentId));
    }

    throw Exception('Erreur réseau lors de la suppression');
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

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/equipment_model.dart';

class EquipmentApi {
  static const String baseUrl = 'http://193.111.250.244:3046/api';
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Uri _collection({Map<String, String>? query}) =>
      Uri.parse('$baseUrl/equipment-assets').replace(queryParameters: query);

  static Uri _collectionAlt({Map<String, String>? query}) =>
      Uri.parse('$baseUrl/equipment-assets/').replace(queryParameters: query);

  static Uri _item(String documentId, {Map<String, String>? query}) => Uri.parse(
          '$baseUrl/equipment-assets/${Uri.encodeComponent(documentId.trim())}')
      .replace(queryParameters: query);

  static Uri _itemAlt(String documentId, {Map<String, String>? query}) => Uri.parse(
          '$baseUrl/equipment-assets/${Uri.encodeComponent(documentId.trim())}/')
      .replace(queryParameters: query);

  static Future<String?> _getToken() async {
    final secureJwt = await storage.read(key: 'jwt');
    if (secureJwt != null && secureJwt.trim().isNotEmpty) {
      return secureJwt;
    }

    final secureAuthToken = await storage.read(key: 'auth_token');
    if (secureAuthToken != null && secureAuthToken.trim().isNotEmpty) {
      return secureAuthToken;
    }

    try {
      final box = GetStorage();
      final boxAuthToken = box.read<String>('auth_token');
      if (boxAuthToken != null && boxAuthToken.trim().isNotEmpty) {
        return boxAuthToken;
      }

      final boxJwt = box.read<String>('jwt');
      if (boxJwt != null && boxJwt.trim().isNotEmpty) {
        return boxJwt;
      }
    } catch (_) {}

    return null;
  }

  static Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await _getToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('Token manquant: Authorization Bearer obligatoire');
    }
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================== GET ALL ==================
  static Future<List<Equipment>> getEquipments({required bool populate}) async {
    final query = populate ? const {'populate': '*'} : null;
    final authHeaders = await _headers();

    http.Response res = await http.get(
      _collection(query: query),
      headers: authHeaders,
    );

    if (res.statusCode == 404) {
      res = await http.get(
        _collectionAlt(query: query),
        headers: authHeaders,
      );
    }

    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res));
    }

    final decoded = jsonDecode(res.body);
    final List data = decoded['data'] ?? [];

    return data
        .map((e) => Equipment.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ================== GET ONE ==================
  static Future<Equipment> getEquipment(String documentId) async {
    final authHeaders = await _headers();

    http.Response res = await http.get(
      _item(documentId, query: {'populate': '*'}),
      headers: authHeaders,
    );

    if (res.statusCode == 404) {
      res = await http.get(
        _itemAlt(documentId, query: {'populate': '*'}),
        headers: authHeaders,
      );
    }

    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res));
    }

    final decoded = jsonDecode(res.body);
    return Equipment.fromJson(Map<String, dynamic>.from(decoded['data']));
  }

  // ================== CREATE ==================
  static Future<Equipment> createEquipment(Equipment e) async {
    final payload = jsonEncode(_toPayload(e));
    final authHeaders = await _headers(json: true);

    http.Response res = await http.post(
      _collection(),
      headers: authHeaders,
      body: payload,
    );

    if (res.statusCode == 404) {
      res = await http.post(
        _collectionAlt(),
        headers: authHeaders,
        body: payload,
      );
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_errorMessage(res));
    }

    final decoded = jsonDecode(res.body);
    return Equipment.fromJson(Map<String, dynamic>.from(decoded['data']));
  }

  // ================== UPDATE ==================
  static Future<Equipment> updateEquipment(
      String documentId, Equipment e) async {
    final payload = jsonEncode(_toPayload(e));

    final headers = await _headers(json: true);
    final uri = _item(documentId);
    final uriAlt = _itemAlt(documentId);

    http.Response res = await http.put(uri, headers: headers, body: payload);

    if (res.statusCode == 405) {
      res = await http.patch(uri, headers: headers, body: payload);
    }

    if (res.statusCode == 404) {
      res = await http.put(uriAlt, headers: headers, body: payload);
      if (res.statusCode == 405) {
        res = await http.patch(uriAlt, headers: headers, body: payload);
      }
    }

    if (res.statusCode == 204 || res.body.trim().isEmpty) {
      return getEquipment(documentId);
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_errorMessage(res));
    }

    final decoded = jsonDecode(res.body);
    return Equipment.fromJson(Map<String, dynamic>.from(decoded['data']));
  }

  // ================== DELETE ==================
  static Future<void> deleteEquipment(String documentId) async {
    final headersGet = await _headers();
    final headersJson = await _headers(json: true);

    http.Response res = await http.delete(
      _item(documentId),
      headers: headersGet,
    );

    if (res.statusCode == 400 || res.statusCode == 415) {
      res = await http.delete(_item(documentId), headers: headersJson);
    }

    if (res.statusCode == 404) {
      res = await http.delete(_itemAlt(documentId), headers: headersGet);
      if (res.statusCode == 400 || res.statusCode == 415) {
        res = await http.delete(_itemAlt(documentId), headers: headersJson);
      }
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_errorMessage(res));
    }
  }

  // ================== PAYLOAD FIX ==================
  static Map<String, dynamic> _toPayload(Equipment e) {
    final data = <String, dynamic>{};

    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      data[key] = value;
    }

    put('name', e.name);
    put('type', e.type);
    put('serial_number', e.serialNumber);

    String status = _normalizeStatus(e.status);

    put('status', status);
    put('mystatus', status);

    put('purchase_date', _normalizeDate(e.purchaseDate));
    put('warranty_expiry', _normalizeDate(e.warrantyExpiration));
    put('purchase_price', e.purchasePrice);
    data['description'] = e.description.trim();
    data['notes'] = e.notes.trim();

    data['price_per_day'] = 0;

    final spaces = _spaceStringToIds(e.space);
    data['spaces'] = spaces;

    data['technical_issues'] = <dynamic>[];
    data['reservations'] = <dynamic>[];
    data['localizations'] = <dynamic>[];

    return {'data': data};
  }

  static List<int> _spaceStringToIds(String value) {
    final v = value.trim();
    if (v.isEmpty || v.toLowerCase() == 'aucun') return [];

    final commaSeparated = v
        .split(',')
        .map((part) => int.tryParse(part.trim()))
        .whereType<int>()
        .toList();
    if (commaSeparated.isNotEmpty) return commaSeparated;

    final id = int.tryParse(v);
    if (id != null) return [id];
    return [];
  }

  static String? _normalizeDate(String value) {
    final s = value.trim();
    if (s.isEmpty) return null;

    final iso = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (iso.hasMatch(s)) return s;

    final fr = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final m = fr.firstMatch(s);
    if (m != null) {
      return '${m.group(3)}-${m.group(2)}-${m.group(1)}';
    }

    return null;
  }

  static String _normalizeStatus(String raw) {
    final value = raw.trim().toLowerCase().replaceAll('_', ' ');
    if (value == 'disponible') return 'Disponible';
    if (value == 'en maitenance' ||
        value == 'en maintenance' ||
        value == 'maintenance') {
      return 'En maitenance';
    }
    if (value == 'en panne' || value == 'panne' || value == 'occupé') {
      return 'En panne';
    }
    return 'Disponible';
  }

  static String _errorMessage(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded['error'] != null) {
        final error = decoded['error'];
        final message = error['message']?.toString() ?? 'Erreur inconnue';
        final details = error['details'];
        if (details != null) {
          return '$message | details: $details';
        }
        return message;
      }
    } catch (_) {}
    return 'Erreur HTTP ${res.statusCode}: ${res.body}';
  }
}

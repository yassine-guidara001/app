import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/equipment_model.dart';

class EquipmentService {
  final String baseUrl = "http://193.111.250.244:3046/api/equipment-assets";

  final String? token;

  EquipmentService(this.token);

  String? get _normalizedToken {
    final raw = token?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.toLowerCase().startsWith('bearer ')) {
      return raw.substring(7).trim();
    }
    return raw;
  }

  Map<String, String> get headersGet => {
        "Accept": "application/json",
        if (_normalizedToken != null)
          "Authorization": "Bearer $_normalizedToken",
      };

  Map<String, String> get headersJson => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (_normalizedToken != null)
          "Authorization": "Bearer $_normalizedToken",
      };

  Map<String, String> get headersJsonWithoutAuth => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  Uri _collectionUri({Map<String, String>? queryParameters}) {
    return Uri.parse(baseUrl).replace(queryParameters: queryParameters);
  }

  Uri _itemUri(String documentId) {
    final encoded = Uri.encodeComponent(documentId.trim());
    return Uri.parse("$baseUrl/$encoded");
  }

  Uri _itemUriById(int id) {
    return Uri.parse("$baseUrl/$id");
  }

  bool _isSuccess(int statusCode) {
    return statusCode == 200 || statusCode == 201 || statusCode == 204;
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is Map<String, dynamic>) {
          final msg = err['message'];
          if (msg != null) return msg.toString();
        }
        final msg = decoded['message'];
        if (msg != null) return msg.toString();
      }
    } catch (_) {}

    return response.body;
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  /// ===============================
  /// GET ALL
  /// ===============================
  Future<List<Equipment>> fetchEquipments() async {
    final uri = Uri.parse('$baseUrl?populate=*');
    http.Response response = await http.get(uri, headers: headersGet);

    if (response.statusCode != 200 && headersGet.containsKey('Authorization')) {
      final retryWithoutAuth = await http.get(uri, headers: const {
        'Accept': 'application/json',
      });

      if (retryWithoutAuth.statusCode == 200) {
        response = retryWithoutAuth;
      }
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body is Map<String, dynamic> ? body['data'] as List? : null;

      if (data == null) return <Equipment>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(Equipment.fromJson)
          .toList();
    }

    throw Exception(
      "GET Error: ${response.statusCode} ${_errorMessage(response)}",
    );
  }

  /// ===============================
  /// ADD
  /// ===============================
  Future<void> addEquipment(Equipment equipment) async {
    final basePayload = equipment.toJson();
    final fullData = _extractData(basePayload);

    final minimalData = <String, dynamic>{
      'name': (fullData['name'] ?? '').toString().trim().isEmpty
          ? 'Sans nom'
          : fullData['name'],
      'type': (fullData['type'] ?? '').toString().trim().isEmpty
          ? 'Autre'
          : fullData['type'],
      'mystatus': (fullData['mystatus'] ?? '').toString().trim().isEmpty
          ? 'Disponible'
          : fullData['mystatus'],
      'serial_number':
          (fullData['serial_number'] ?? '').toString().trim().isEmpty
              ? DateTime.now().millisecondsSinceEpoch.toString()
              : fullData['serial_number'],
    };

    final minimalDataUniqueSerial = Map<String, dynamic>.from(minimalData)
      ..['serial_number'] =
          '${minimalData['serial_number']}_${DateTime.now().millisecondsSinceEpoch}';

    final payloads = <Map<String, dynamic>>[
      {'data': fullData},
      {'data': minimalData},
      {'data': minimalDataUniqueSerial},
    ];

    final headersCandidates = <Map<String, String>>[
      headersJson,
      if (headersJson.containsKey('Authorization')) headersJsonWithoutAuth,
    ];

    http.Response? lastResponse;

    for (final payload in payloads) {
      final body = jsonEncode(payload);
      for (final currentHeaders in headersCandidates) {
        final response = await http.post(
          _collectionUri(),
          headers: currentHeaders,
          body: body,
        );

        lastResponse = response;
        if (_isSuccess(response.statusCode)) {
          return;
        }
      }
    }

    if (lastResponse != null) {
      throw Exception(
          "POST Error: ${lastResponse.statusCode} ${_errorMessage(lastResponse)}");
    }

    throw Exception("POST Error: aucune réponse serveur");
  }

  /// ===============================
  /// UPDATE (Strapi v5 => documentId)
  /// ===============================
  Future<void> updateEquipment(Equipment equipment) async {
    final raw = equipment.toJson();
    final rawData = raw['data'];
    final payloadData = rawData is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    payloadData.remove('spaces');
    payloadData.remove('technical_issues');
    payloadData.remove('reservations');
    payloadData.remove('localizations');
    payloadData.remove('locale');

    final payload = jsonEncode({'data': payloadData});

    final candidateUris = <Uri>[
      if (equipment.documentId.trim().isNotEmpty)
        _itemUri(equipment.documentId),
      if (equipment.id > 0) _itemUriById(equipment.id),
    ];

    if (candidateUris.isEmpty) {
      throw Exception("PUT Error: identifiant équipement manquant");
    }

    http.Response? lastResponse;

    for (final uri in candidateUris) {
      final attempts = <Future<http.Response> Function()>[
        () => http.put(uri, headers: headersJson, body: payload),
      ];

      if (headersJson.containsKey('Authorization')) {
        attempts.add(() =>
            http.put(uri, headers: headersJsonWithoutAuth, body: payload));
      }

      for (final attempt in attempts) {
        final response = await attempt();
        lastResponse = response;

        if (_isSuccess(response.statusCode)) {
          return;
        }
      }
    }

    if (lastResponse != null) {
      if (lastResponse.statusCode >= 500) {
        await addEquipment(equipment);

        try {
          if (equipment.documentId.trim().isNotEmpty) {
            await deleteEquipment(equipment.documentId);
            return;
          }

          if (equipment.id > 0) {
            final deleteByIdResponse = await http.delete(
              _itemUriById(equipment.id),
              headers: headersGet,
            );

            if (_isSuccess(deleteByIdResponse.statusCode)) {
              return;
            }
          }
        } catch (_) {}

        return;
      }

      throw Exception(
        "PUT Error: ${lastResponse.statusCode} ${_errorMessage(lastResponse)}",
      );
    }

    throw Exception("PUT Error: aucune réponse serveur");
  }

  /// ===============================
  /// DELETE
  /// ===============================
  Future<void> deleteEquipment(String documentId) async {
    final response = await http.delete(
      _itemUri(documentId),
      headers: headersGet,
    );

    if (response.statusCode != 200) {
      throw Exception(
          "DELETE Error: ${response.statusCode} ${_errorMessage(response)}");
    }
  }
}

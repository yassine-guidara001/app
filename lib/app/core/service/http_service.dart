import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_getx_app/app/core/service/storage_service.dart';

/// Service HTTP centralisé
class HttpService extends GetxService {
  static const String baseUrl = 'http://193.111.250.244:3046'; // Strapi

  final Duration timeoutDuration = const Duration(seconds: 30);

  // Headers par défaut
  Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Ajouter le token si disponible
    try {
      final storageService = Get.find<StorageService>();
      final token = storageService.read<String>('token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // StorageService non disponible
    }

    return headers;
  }

  // Headers pour requêtes sans authentification
  Map<String, String> get headersWithoutAuth => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// POST request AVEC authentification (token)
  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(url, headers: headers, body: jsonEncode(data))
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request SANS authentification (pour login/register)
  Future<Response> postAuth(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 POST AUTH: $url');
      print('📤 Data: $data');
      print('📋 Headers: $headersWithoutAuth');

      final response = await http
          .post(url, headers: headersWithoutAuth, body: jsonEncode(data))
          .timeout(timeoutDuration);

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error: $e');
      return _handleError(e);
    }
  }

  /// GET request
  Future<Response> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response =
          await http.get(url, headers: headers).timeout(timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Response _handleResponse(http.Response response) {
    print('📊 Response statusCode: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    try {
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Succès: statusCode ${response.statusCode}');
        return Response(statusCode: response.statusCode, body: body);
      }

      // Erreur du serveur (body contient les détails)
      String errorMessage = response.reasonPhrase ?? 'Erreur serveur';
      if (body is Map) {
        errorMessage = body['error']?['message'] ??
            body['message'] ??
            body['error']?.toString() ??
            errorMessage;
      }

      // Afficher plus de détails pour les erreurs 5xx
      if (response.statusCode >= 500) {
        print('🔴 ERREUR SERVEUR ${response.statusCode}');
        print('📋 Détails: ${body}');
      } else {
        print('⚠️ Erreur ${response.statusCode}: $errorMessage');
      }

      return Response(
        statusCode: response.statusCode,
        statusText: errorMessage,
        body: body is Map ? body : null,
      );
    } catch (e) {
      print('❌ JSON parsing error: $e');
      print('📄 Raw body: ${response.body}');

      return Response(
        statusCode: response.statusCode,
        statusText: response.reasonPhrase ?? 'Erreur parsing',
        body: null,
      );
    }
  }

  Response _handleError(dynamic error) {
    String message = 'Une erreur est survenue';
    if (error.toString().contains('SocketException')) {
      message = 'Pas de connexion internet';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Délai dépassé (30s)';
    } else {
      message = error.toString();
    }

    print('❌ Network error: $message');

    return Response(statusCode: 0, statusText: message, body: null);
  }
}

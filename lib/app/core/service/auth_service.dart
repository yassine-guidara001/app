import 'dart:convert';

import 'package:flutter_getx_app/app/core/service/storage_service.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthService extends GetxService {
  static const String _baseApiUrl = 'http://193.111.250.244:3046/api';

  final StorageService _storage = Get.find<StorageService>();

  String? get token {
    final raw = _storage.getToken() ??
        _storage.read<String>('jwt') ??
        _storage.read<String>('token');

    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }
    return trimmed;
  }

  bool get isLoggedIn => (token ?? '').isNotEmpty;

  Map<String, String> get authHeaders {
    final currentToken = token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (currentToken != null && currentToken.isNotEmpty)
        'Authorization': 'Bearer $currentToken',
    };
  }

  Future<String> login({
    required String identifier,
    required String password,
  }) async {
    final payload = {
      'identifier': identifier.trim(),
      'password': password,
    };

    print('📡 POST /auth/local');

    final response = await http.post(
      Uri.parse('$_baseApiUrl/auth/local'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print('✅ Réponse /auth/local: ${response.statusCode}');

    final decoded = _decodeBody(response.body);
    if (response.statusCode == 200) {
      final jwt = (decoded['jwt'] ?? '').toString().trim();
      if (jwt.isEmpty) {
        throw Exception('JWT manquant dans la réponse de connexion');
      }

      await _storage.saveToken(jwt);
      await _storage.write('jwt', jwt);
      await _storage.write('token', jwt);

      final user = decoded['user'];
      if (user is Map<String, dynamic>) {
        await _storage.saveUserData(user);
      }

      return jwt;
    }

    throw Exception(_statusMessage(response.statusCode, decoded));
  }

  Future<void> logout() async {
    await _storage.logout();
    if (Get.currentRoute != Routes.LOGIN) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void handleUnauthorized() {
    print('❌ 401 Unauthorized → redirection /login');
    logout();
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _statusMessage(int statusCode, Map<String, dynamic> body) {
    final strapiMsg = body['error']?['message']?.toString() ??
        body['message']?.toString() ??
        'Erreur inconnue';

    if (statusCode == 401) return 'Identifiants invalides';
    if (statusCode == 403) return 'Accès interdit';
    if (statusCode == 404) return 'Ressource introuvable';
    if (statusCode == 422) return strapiMsg;
    if (statusCode >= 500) return 'Erreur serveur';
    return strapiMsg;
  }
}

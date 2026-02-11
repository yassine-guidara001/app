import 'package:flutter_getx_app/app/core/service/http_service.dart';
import 'package:flutter_getx_app/app/core/service/storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final HttpService httpService = Get.find<HttpService>();
  final StorageService storageService = Get.find<StorageService>();

  /// Extraire le token de la réponse (essaie différentes clés)
  String? _extractToken(Map<String, dynamic> body) {
    final token = body['jwt'] ??
        body['token'] ??
        body['accessToken'] ??
        body['access_token'];
    if (token != null && token.toString().isNotEmpty) {
      print('✅ Token trouvé: ${token.toString().substring(0, 20)}...');
      return token.toString();
    }
    return null;
  }

  // 🔐 LOGIN
  Future<void> loginUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Erreur', 'Remplir tous les champs');
      return;
    }

    isLoading.value = true;

    try {
      print('🔐 Tentative login...');
      final response = await httpService.postAuth('/api/auth/local', {
        "identifier": email,
        "password": password,
      });

      print(
          '📥 Response: statusCode=${response.statusCode}, body=${response.body}');

      // Vérifier si statusCode est null (erreur réseau)
      if (response.statusCode == null || response.statusCode == 0) {
        Get.snackbar('Erreur', response.statusText ?? 'Erreur réseau');
        return;
      }

      if (response.statusCode == 200) {
        if (response.body == null || response.body is! Map) {
          Get.snackbar('Erreur', 'Réponse serveur invalide');
          return;
        }

        final token = _extractToken(response.body as Map<String, dynamic>);

        if (token == null) {
          print('❌ Token NOT found in response');
          print('📋 Available keys: ${(response.body as Map).keys.toList()}');
          Get.snackbar('Erreur', 'Pas de token reçu du serveur');
          return;
        }

        // Sauvegarder le token
        await storageService.saveToken(token);

        final user = response.body['user'];
        if (user != null) {
          await storageService.saveUserData(user);
          final username =
              user is Map ? (user['username'] ?? 'Utilisateur') : 'Utilisateur';
          Get.snackbar('Succès', 'Bienvenue $username');
        } else {
          Get.snackbar('Succès', 'Connexion réussie');
        }

        Get.offAllNamed(Routes.HOME);
      } else {
        // Erreur du serveur — tenter d'extraire un message détaillé
        String serverMsg = response.statusText ?? 'Connexion échouée';
        try {
          if (response.body is Map) {
            final body = response.body as Map;
            serverMsg =
                body['error']?['message'] ?? body['message'] ?? serverMsg;
          }
        } catch (_) {}

        print('⚠️ Login failed: $serverMsg');
        Get.snackbar('Erreur', serverMsg);
      }
    } catch (e) {
      print('❌ Login exception: $e');
      Get.snackbar('Erreur', 'Erreur: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 🔐 REGISTER
  Future<void> registerUser(
      String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Erreur', 'Remplir tous les champs');
      return;
    }

    isLoading.value = true;

    try {
      print('🔐 Tentative register...');
      final response = await httpService.postAuth('/api/auth/local/register', {
        "username": username,
        "email": email,
        "password": password,
      });

      print(
          '📥 Response: statusCode=${response.statusCode}, body=${response.body}');

      // Vérifier si statusCode est null (erreur réseau)
      if (response.statusCode == null || response.statusCode == 0) {
        Get.snackbar('Erreur', response.statusText ?? 'Erreur réseau');
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body == null || response.body is! Map) {
          Get.snackbar('Succès', 'Inscription réussie - Connectez-vous');
          Get.offAllNamed(Routes.LOGIN);
          return;
        }

        final token = _extractToken(response.body as Map<String, dynamic>);

        if (token == null) {
          print('❌ Token NOT found after register');
          print('📋 Available keys: ${(response.body as Map).keys.toList()}');
          Get.snackbar('Succès', 'Inscription réussie - Connectez-vous');
          Get.offAllNamed(Routes.LOGIN);
          return;
        }

        // Auto-login: sauvegarder le token
        await storageService.saveToken(token);

        final user = response.body['user'];
        if (user != null) {
          await storageService.saveUserData(user);
        }

        Get.snackbar('Succès', 'Inscription et connexion réussies');
        Get.offAllNamed(Routes.HOME);
      } else {
        // Erreur du serveur — afficher message détaillé si disponible
        String serverMsg = response.statusText ?? 'Inscription échouée';
        try {
          if (response.body is Map) {
            final body = response.body as Map;
            serverMsg =
                body['error']?['message'] ?? body['message'] ?? serverMsg;
          }
        } catch (_) {}

        print('⚠️ Register failed: $serverMsg');
        Get.snackbar('Erreur', serverMsg);
      }
    } catch (e) {
      print('❌ Register exception: $e');
      Get.snackbar('Erreur', 'Erreur: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

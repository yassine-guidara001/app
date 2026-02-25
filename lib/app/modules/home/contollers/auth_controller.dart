import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_getx_app/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final storage = const FlutterSecureStorage();

  final String baseUrl = "http://193.111.250.244:3046";

  Future<void> loginUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs");
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/local"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "identifier": email,
          "password": password,
        }),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String jwt = data['jwt'];

        await storage.write(key: 'jwt', value: jwt);

        Get.snackbar("Succès", "Connecté avec succès");
        Get.offAllNamed(Routes.HOME);
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          "Erreur",
          error['error']?['message'] ?? "Login échoué",
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar("Erreur", "Impossible de se connecter au serveur");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await storage.http.delete(key: 'jwt');
    Get.offAllNamed(Routes.LOGIN);
  }
}

class FlutterSecureStorage {
  const FlutterSecureStorage();
  
  get http => null;
  
  Future<void> write({required String key, required String value}) async {}
}
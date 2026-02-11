import 'dart:convert';
import 'package:flutter_getx_app/app/core/service/http_service.dart';
import 'package:get/get.dart';
import '../models/user_models.dart';

class UserProvider {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _httpService.get('/users');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des utilisateurs');
      }
    } catch (e) {
      // Pour test Web si pas d'API
      print('Erreur API: $e, utilisation de données mock');
      return [
        UserModel(id: 1, name: 'Ahmed', email: 'ahmed@test.com'),
        UserModel(id: 2, name: 'Sara', email: 'sara@test.com'),
      ];
    }
  }

  Future<UserModel> getUserById(int id) async {
    final users = await getUsers();
    return users.firstWhere((u) => u.id == id, orElse: () => UserModel(id: 0, name: 'Unknown', email: 'unknown@test.com'));
  }

  Future<UserModel> createUser(UserModel user) async {
    return user; // mock creation pour test Web
  }

  Future<UserModel> updateUser(int id, UserModel user) async {
    return user; // mock update pour test Web
  }

  Future<void> deleteUser(int id) async {
    print('Utilisateur $id supprimé (mock)');
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final all = await getUsers();
    return all.where((u) => u.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

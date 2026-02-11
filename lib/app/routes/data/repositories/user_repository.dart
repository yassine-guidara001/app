import 'package:flutter_getx_app/app/routes/data/models/user_models.dart';

import '../providers/user_provider.dart';

/// Repository pour la logique métier des utilisateurs
/// Sert d'intermédiaire entre le Provider et le Controller
class UserRepository {
  final UserProvider _provider = UserProvider();

  /// Récupérer tous les utilisateurs
  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await _provider.getUsers();
      users.sort((a, b) => a.name.compareTo(b.name));
      return users;
    } catch (e) {
      print('Repository: Erreur lors de la récupération des utilisateurs - $e');
      return [];
    }
  }

  /// Récupérer un utilisateur par ID
  Future<UserModel?> getUserById(int id) async {
    if (id <= 0) {
      print('Repository: ID invalide - $id');
      return null;
    }
    try {
      return await _provider.getUserById(id);
    } catch (e) {
      print('Repository: Impossible de récupérer l\'utilisateur $id - $e');
      return null;
    }
  }

  /// Créer un nouvel utilisateur
  Future<UserModel?> createUser({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    if (name.trim().isEmpty) {
      print('Repository: Le nom ne peut pas être vide');
      return null;
    }
    if (email.trim().isEmpty || !_isValidEmail(email)) {
      print('Repository: Email invalide');
      return null;
    }

    final newUser = UserModel(
      id: 0, // temporaire, le backend assignera un vrai ID
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone?.trim(),
      address: address?.trim(),
    );

    try {
      return await _provider.createUser(newUser);
    } catch (e) {
      print('Repository: Erreur lors de la création de l\'utilisateur - $e');
      return null;
    }
  }

  /// Mettre à jour un utilisateur
  Future<UserModel?> updateUser(UserModel user) async {
    if (user.id <= 0) {
      print('Repository: ID utilisateur invalide');
      return null;
    }
    if (user.name.trim().isEmpty) {
      print('Repository: Le nom ne peut pas être vide');
      return null;
    }
    if (!_isValidEmail(user.email)) {
      print('Repository: Email invalide');
      return null;
    }

    final cleanUser = user.copyWith(
      name: user.name.trim(),
      email: user.email.trim().toLowerCase(),
      phone: user.phone?.trim(),
      address: user.address?.trim(),
    );

    try {
      return await _provider.updateUser(user.id, cleanUser);
    } catch (e) {
      print('Repository: Erreur lors de la mise à jour - $e');
      return null;
    }
  }

  /// Supprimer un utilisateur
  Future<bool> deleteUser(int id) async {
    if (id <= 0) {
      print('Repository: ID invalide');
      return false;
    }
    try {
      await _provider.deleteUser(id);
      return true;
    } catch (e) {
      print('Repository: Erreur lors de la suppression - $e');
      return false;
    }
  }

  /// Rechercher des utilisateurs par nom
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty || query.trim().length < 2) {
      return [];
    }
    final cleanQuery = query.trim();
    try {
      final results = await _provider.searchUsers(cleanQuery);
      return results
          .where((user) =>
              user.name.toLowerCase().contains(cleanQuery.toLowerCase()))
          .toList();
    } catch (e) {
      print('Repository: Erreur lors de la recherche - $e');
      return [];
    }
  }

  // ==================== UTILITAIRES ====================
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}

import 'package:get/get.dart';

class HomeController extends GetxController {
  // Loader
  final isLoading = true.obs;

  // Liste des utilisateurs
  final users = <User>[].obs;

  // Compteur exemple
  final counter = 0.obs;

  // Liste complète (pour la recherche)
  final _allUsers = <User>[];

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  /// Charger les utilisateurs
  Future<void> fetchUsers() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    _allUsers
      ..clear()
      ..addAll([
        User(id: 1, name: "Yassine", email: "yassine@gmail.com"),
        User(id: 2, name: "Ahmed", email: "ahmed@gmail.com"),
      ]);

    users.value = List.from(_allUsers);
    isLoading.value = false;
  }

  /// Pull to refresh
  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  /// Recherche
  void searchUsers(String query) {
    if (query.isEmpty) {
      users.value = List.from(_allUsers);
    } else {
      users.value = _allUsers
          .where(
            (u) => u.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  /// Compteur
  void incrementCounter() {
    counter.value++;
  }

  /// Nombre d'utilisateurs
  int get userCount => users.length;

  /// Sélection
  void selectUser(User user) {
    Get.snackbar(
      "Utilisateur",
      "Vous avez sélectionné : ${user.name}",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Création
  void createUser(String name, String email) {
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      email: email,
    );

    users.add(newUser);
    _allUsers.add(newUser);
  }

  /// Suppression
  void deleteUser(int id) {
    users.removeWhere((u) => u.id == id);
    _allUsers.removeWhere((u) => u.id == id);
  }
}

/// MODEL
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });
}

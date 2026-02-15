import 'package:get/get.dart';

class HomeController extends GetxController {
  /// ===============================
  /// 🔵 SIDEBAR MENU
  /// ===============================
  final selectedMenu = 3.obs; // utilisateurs selected par défaut

  void changeMenu(int index, String route) {
    selectedMenu.value = index;
    Get.toNamed(route);
  }

  /// ===============================
  /// 🔵 USERS MANAGEMENT
  /// ===============================

  final isLoading = true.obs;
  final users = <User>[].obs;
  final _allUsers = <User>[];

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    _allUsers.clear();

    users.value = List.from(_allUsers);
    isLoading.value = false;
  }

  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      users.value = List.from(_allUsers);
    } else {
      users.value = _allUsers
          .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectUser(User user) {
    Get.snackbar(
      "Utilisateur",
      "Vous avez sélectionné : ${user.name}",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void createUser(String name, String email, {String role = 'Utilisateur'}) {
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      email: email,
      role: role,
      status: 'Actif',
      registeredAt: DateTime.now(),
    );

    users.add(newUser);
    _allUsers.add(newUser);
  }

  void deleteUser(int id) {
    users.removeWhere((u) => u.id == id);
    _allUsers.removeWhere((u) => u.id == id);
  }
}

/// ================== MODEL ==================
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime registeredAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.registeredAt,
  });
}

import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var users = <User>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() {
    // Liste initialement vide
    users.value = [];
  }

  void addUser(User user) {
    users.add(user);
  }

  void updateUser(User user) {
    int index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
    }
  }

  void deleteUser(int id) {
    users.removeWhere((u) => u.id == id);
    Get.snackbar('Utilisateur', 'Utilisateur supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM);
  }

  List<User> get filteredUsers {
    if (searchQuery.value.isEmpty) return users;
    return users
        .where((u) =>
            u.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            u.email.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  void setSearch(String query) {
    searchQuery.value = query;
  }
}

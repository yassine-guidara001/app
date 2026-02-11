import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Utilisateurs'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshUsers,
          ),
        ],
      ),

      /// Drawer / Sidebar moderne
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _drawerItem(Icons.home, "Home", Routes.HOME),
            _drawerItem(Icons.person, "Profile", Routes.PROFILE),
            _drawerItem(Icons.settings, "Settings", Routes.SETTINGS),
            _drawerItem(Icons.info, "About", Routes.ABOUT),
            const Spacer(),
            _drawerItem(Icons.logout, "Logout", Routes.LOGIN, isLogout: true),
          ],
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.people_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucun utilisateur',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Recherche
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher un utilisateur...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: controller.searchUsers,
              ),
            ),

            // Liste utilisateurs
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteUser(user.id),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () => controller.selectUser(user),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Dialogue pour ajouter un utilisateur
  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nouvel Utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();

              if (name.isNotEmpty && email.isNotEmpty) {
                controller.createUser(name, email);
                Get.back();
              } else {
                Get.snackbar("Erreur", "Veuillez remplir tous les champs",
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text("Créer"),
          ),
        ],
      ),
    );
  }

  /// Drawer item helper
  Widget _drawerItem(IconData icon, String title, String route, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black)),
      onTap: () {
        if (isLogout) {
          Get.offAllNamed(route);
        } else {
          Get.toNamed(route);
        }
      },
    );
  }
}

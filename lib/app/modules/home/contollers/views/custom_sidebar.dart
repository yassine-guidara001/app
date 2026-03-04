import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// App Logo and Name
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text("S",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SUNSPACE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  Text("Dashboard", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          /// Scrollable Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Main Menu
                  _menuItem(controller, 0, Icons.grid_view, "Tableau de bord",
                      Routes.HOME),
                  const SizedBox(height: 24),

                  /// GESTION Section
                  const Text("GESTION",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  _menuItem(controller, 1, Icons.business_outlined, "Espaces",
                      Routes.SPACES),
                  _menuItem(controller, 2, Icons.build_circle_outlined,
                      "Équipements", Routes.EQUIPMENTS),
                  _menuItem(controller, 3, Icons.people_alt_outlined,
                      "Utilisateurs", Routes.USERS),
                  _menuItem(controller, 4, Icons.calendar_today_outlined,
                      "Réservations", Routes.RESERVATIONS),
                  const SizedBox(height: 24),

                  /// ENSEIGNANT Section
                  const Text("ENSEIGNANT",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  _menuItem(controller, 5, Icons.menu_book_outlined,
                      "Formations", Routes.FORMATIONS),
                  _menuItem(controller, 6, Icons.layers_outlined, "Sessions",
                      Routes.SESSIONS),
                  _menuItem(controller, 7, Icons.school_outlined, "Étudiants",
                      Routes.HOME),
                  _menuItem(controller, 8, Icons.chrome_reader_mode_outlined,
                      "Devoirs", Routes.DEVOIRS),
                  _menuItem(controller, 9, Icons.forum_outlined,
                      "Communication", Routes.COMMUNICATION),
                  const SizedBox(height: 24),

                  /// ETUDIANT Section
                  const Text("ÉTUDIANT",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  _menuItem(controller, 10, Icons.menu_book_outlined,
                      "Mes cours", Routes.FORMATIONS),
                  _menuItem(controller, 11, Icons.assignment_outlined,
                      "Mes devoirs", Routes.DEVOIRS),
                  _menuItem(controller, 12, Icons.school_outlined,
                      "Catalogue Cours", Routes.FORMATIONS),
                  _menuItem(controller, 13, Icons.apartment_outlined,
                      "Espaces d'étude", Routes.SPACES),
                  _menuItem(controller, 14, Icons.calendar_today_outlined,
                      "Sessions", Routes.SESSIONS),
                  _menuItem(controller, 15, Icons.place_outlined,
                      "Plan des espaces", Routes.SPACES),
                  _menuItem(controller, 16, Icons.groups_outlined,
                      "Communication", Routes.COMMUNICATION),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// User Profile Card at bottom
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Text("A", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Utilisateur",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("admin@sunspace.app",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// Logout Action
          InkWell(
            onTap: () => Get.offAllNamed(Routes.LOGIN),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text("Déconnexion",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(HomeController controller, int index, IconData icon,
      String title, String route) {
    return Obx(() {
      final isSelected = controller.selectedMenu.value == index;
      return InkWell(
        onTap: () => controller.changeMenu(index, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0F2FE) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.blue : const Color(0xFF64748B),
                  size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue : const Color(0xFF1E293B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (title == "Réservations") ...[
                const Spacer(),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ]
            ],
          ),
        ),
      );
    });
  }
}

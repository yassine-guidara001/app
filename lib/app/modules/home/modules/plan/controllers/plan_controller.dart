import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/space_model.dart';

class PlanController extends GetxController {
  late PageController pageController;

  final selectedSpace = Rx<SpaceModel?>(null);
  final isReservationModalOpen = false.obs;

  final dateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final guestsCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void selectSpace(SpaceModel space) {
    selectedSpace.value = space;
    isReservationModalOpen.value = true;
  }

  void closeReservationModal() {
    isReservationModalOpen.value = false;
    clearForm();
  }

  void clearForm() {
    dateCtrl.clear();
    timeCtrl.clear();
    guestsCtrl.clear();
    notesCtrl.clear();
  }

  Future<bool> submitReservation() async {
    if (selectedSpace.value == null) return false;

    final spaceName = selectedSpace.value!.name;
    final date = dateCtrl.text.trim();
    final time = timeCtrl.text.trim();
    final guests = guestsCtrl.text.trim();
    // final notes = notesCtrl.text.trim(); // À utiliser lors de l'intégration API

    // Validation
    if (date.isEmpty || time.isEmpty || guests.isEmpty) {
      Get.snackbar(
        'Réservation',
        'Veuillez remplir tous les champs requis',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    }

    // Placeholder - appel API
    try {
      Get.snackbar(
        'Succès',
        'Réservation de "$spaceName" confirmée pour le $date à $time',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      closeReservationModal();
      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de réserver l\'espace',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    dateCtrl.dispose();
    timeCtrl.dispose();
    guestsCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }
}

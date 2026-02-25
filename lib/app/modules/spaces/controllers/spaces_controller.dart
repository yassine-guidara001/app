import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/data/models/space_model.dart';
import 'package:flutter_getx_app/app/data/services/space_service.dart';
import 'package:get/get.dart';

class SpaceController extends GetxController {
  // ================= STATE =================

  final spaces = <Space>[].obs;
  final loading = false.obs;
  final errorMessage = ''.obs;

  // ================= INIT =================

  @override
  void onInit() {
    loadSpaces();
    super.onInit();
  }

  // ================= LOAD =================

  Future<void> loadSpaces() async {
    loading.value = true;
    errorMessage.value = '';

    try {
      final result = await SpaceApi.getSpaces(populate: true);
      spaces.assignAll(result);

      print('✅ ${spaces.length} espaces chargés');
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ loadSpaces error: $e');

      Get.snackbar(
        "Erreur",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: loadSpaces,
          child: const Text("Réessayer", style: TextStyle(color: Colors.white)),
        ),
      );
    } finally {
      loading.value = false;
    }
  }

  // ================= CREATE =================

  Future<Space?> create(Map<String, dynamic> data) async {
    try {
      loading.value = true;

      final newSpace = await SpaceApi.createSpace(data);
      // Affichage immédiat dans le tableau
      spaces.insert(0, newSpace);

      Get.snackbar(
        "Succès",
        "Espace créé avec succès",
        snackPosition: SnackPosition.BOTTOM,
      );

      return newSpace;
    } catch (e) {
      Get.snackbar(
        "Erreur création",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      return null;
    } finally {
      loading.value = false;
    }
  }

  // ================= UPDATE =================

  Future<bool> updateSpace(String documentId, Map<String, dynamic> data) async {
    try {
      loading.value = true;

      final updated = await SpaceApi.updateSpace(documentId, data);

      final index = spaces.indexWhere((e) => e.documentId == documentId);
      if (index != -1) {
        spaces[index] = updated;
        spaces.refresh();
      }

      Get.snackbar(
        "Succès",
        "Espace modifié avec succès",
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        "Erreur modification",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      loading.value = false;
    }
  }

  // ================= DELETE =================

  Future<void> delete(String documentId) async {
    try {
      loading.value = true;

      await SpaceApi.deleteSpace(documentId);
      spaces.removeWhere((e) => e.documentId == documentId);

      Get.snackbar(
        "Succès",
        "Espace supprimé",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erreur suppression",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }

  // ================= FIND =================

  Space? findById(int id) {
    try {
      return spaces.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Space? findByDocumentId(String documentId) {
    try {
      return spaces.firstWhere((e) => e.documentId == documentId);
    } catch (_) {
      return null;
    }
  }

  // ================= REFRESH =================

  Future<void> refreshSpaces() async {
    await loadSpaces();
  }
}

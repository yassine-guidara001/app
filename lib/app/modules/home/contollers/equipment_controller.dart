import 'package:get/get.dart';
import 'package:flutter_getx_app/app/data/services/equipment_service.dart';
import 'package:flutter_getx_app/app/data/models/equipment_model.dart';

class EquipmentController extends GetxController {
  final equipmentList = <Equipment>[].obs;

  // Back-compat pour l'UI existante
  RxList<Equipment> get equipments => equipmentList;

  final _allEquipments = <Equipment>[];
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEquipments();
  }

  Future<void> fetchEquipments() async {
    isLoading.value = true;

    try {
      final items = await EquipmentApi.getEquipments(populate: true);

      _allEquipments
        ..clear()
        ..addAll(items);

      searchEquipments(searchQuery.value);
    } catch (e) {
      print('❌ fetchEquipments error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addEquipment(Equipment equipment) async {
    isLoading.value = true;
    try {
      await EquipmentApi.createEquipment(equipment);
      await fetchEquipments();
    } catch (e) {
      print('❌ addEquipment error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEquipment(Equipment equipment) async {
    isLoading.value = true;
    try {
      final documentId = equipment.documentId.trim();
      if (documentId.isEmpty) {
        throw Exception(
            'documentId manquant: impossible de modifier cet équipement');
      }
      await EquipmentApi.updateEquipment(documentId, equipment);
      await fetchEquipments();
    } catch (e) {
      print('❌ updateEquipment error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEquipment(String documentId) async {
    isLoading.value = true;
    try {
      final trimmed = documentId.trim();
      if (trimmed.isEmpty) {
        throw Exception(
            'documentId manquant: impossible de supprimer cet équipement');
      }
      await EquipmentApi.deleteEquipment(trimmed);
      await fetchEquipments();
    } catch (e) {
      print('❌ deleteEquipment error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchEquipments(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      equipmentList.value = List.from(_allEquipments);
    } else {
      equipmentList.value = _allEquipments
          .where((e) =>
              e.name.toLowerCase().contains(query.toLowerCase()) ||
              e.type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}

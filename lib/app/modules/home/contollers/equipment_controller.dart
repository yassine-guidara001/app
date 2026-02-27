import 'package:get/get.dart';
import '../../../data/models/equipment_model.dart';
import '../../../data/services/equipment_service.dart';
import '../../../core/service/storage_service.dart';

class EquipmentController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  EquipmentService? _service;

  var equipments = <Equipment>[].obs;
  var isLoading = false.obs;

  String? _readToken() {
    final token = _storageService.getToken() ??
        _storageService.read<String>('jwt') ??
        _storageService.read<String>('token');
    if (token == null || token.trim().isEmpty) return null;
    return token.trim();
  }

  EquipmentService _getService() {
    final token = _readToken();

    final currentService = _service;
    if (currentService != null && currentService.token == token) {
      return currentService;
    }

    final created = EquipmentService(token);
    _service = created;
    return created;
  }

  @override
  void onInit() {
    _service = null;
    fetchEquipments();
    super.onInit();
  }

  /// ===============================
  /// FETCH
  /// ===============================
  Future<void> fetchEquipments() async {
    try {
      isLoading(true);

      final result = await _getService().fetchEquipments();

      equipments.assignAll(result);
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ===============================
  /// ADD
  /// ===============================
  Future<void> addEquipment(Equipment equipment) async {
    try {
      isLoading(true);

      await _getService().addEquipment(equipment);
      await fetchEquipments();

      Get.snackbar("Succès", "Équipement ajouté avec succès");
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ===============================
  /// UPDATE
  /// ===============================
  Future<void> updateEquipment(Equipment equipment) async {
    try {
      isLoading(true);

      await _getService().updateEquipment(equipment);
      await fetchEquipments();

      Get.snackbar("Succès", "Équipement modifié avec succès");
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ===============================
  /// DELETE
  /// ===============================
  Future<void> deleteEquipment(String documentId) async {
    try {
      isLoading(true);

      await _getService().deleteEquipment(documentId);

      equipments.removeWhere((e) => e.documentId == documentId);

      Get.snackbar("Succès", "Équipement supprimé");
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ===============================
  /// SEARCH
  /// ===============================
  void searchEquipments(String query) {
    if (query.isEmpty) {
      fetchEquipments();
    } else {
      final filtered = equipments.where(
        (e) =>
            e.name.toLowerCase().contains(query.toLowerCase()) ||
            e.type.toLowerCase().contains(query.toLowerCase()),
      );

      equipments.assignAll(filtered.toList());
    }
  }
}

import 'package:get/get.dart';

class Equipment {
  final int id;
  final String name;
  final String type;
  final String serialNumber;
  final String status;
  final String purchaseDate;
  final double purchasePrice;
  final String warrantyExpiration;
  final String space;
  final String description;
  final String notes;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.serialNumber,
    required this.status,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.warrantyExpiration,
    required this.space,
    this.description = '',
    this.notes = '',
  });
}

class EquipmentController extends GetxController {
  final equipments = <Equipment>[].obs;
  final _allEquipments = <Equipment>[];
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEquipments();
  }

  void fetchEquipments() {
    isLoading.value = true;
    _allEquipments.clear();
    equipments.value = List.from(_allEquipments);
    isLoading.value = false;
  }

  void addEquipment(Equipment equipment) {
    _allEquipments.add(equipment);
    searchEquipments(searchQuery.value);
  }

  void updateEquipment(Equipment equipment) {
    int index = _allEquipments.indexWhere((e) => e.id == equipment.id);
    if (index != -1) {
      _allEquipments[index] = equipment;
      searchEquipments(searchQuery.value);
    }
  }

  void deleteEquipment(int id) {
    _allEquipments.removeWhere((e) => e.id == id);
    searchEquipments(searchQuery.value);
  }

  void searchEquipments(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      equipments.value = List.from(_allEquipments);
    } else {
      equipments.value = _allEquipments
          .where((e) =>
              e.name.toLowerCase().contains(query.toLowerCase()) ||
              e.type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}

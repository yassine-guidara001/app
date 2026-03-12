import 'package:flutter_getx_app/app/core/service/auth_service.dart';
import 'package:flutter_getx_app/app/data/models/association_model.dart';
import 'package:flutter_getx_app/app/data/services/associations_service.dart';
import 'package:get/get.dart';

class AssociationBudgetController extends GetxController {
  AssociationBudgetController({AssociationsService? service})
      : _service = service ?? Get.find<AssociationsService>();

  final AssociationsService _service;
  final AuthService _auth = Get.find<AuthService>();

  final userAssociations = <AssociationModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    final userId = _auth.currentUserId;
    if (userId == null) {
      errorMessage.value = 'Utilisateur non connecté';
      isLoading.value = false;
      return;
    }

    try {
      final associations = await _service.loadAssociationsByUserId(userId);
      userAssociations.assignAll(associations);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Solde total (somme des budgets de toutes les associations de l'utilisateur).
  double get totalBalance =>
      userAssociations.fold(0, (sum, a) => sum + a.budgetValue);

  /// Devise de la première association (fallback TND).
  String get currency {
    if (userAssociations.isEmpty) return 'TND';
    final c = userAssociations.first.currency.trim();
    return c.isNotEmpty ? c : 'TND';
  }
}

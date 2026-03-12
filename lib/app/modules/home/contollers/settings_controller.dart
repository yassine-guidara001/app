import 'package:flutter_getx_app/app/core/service/auth_service.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();

  final username = ''.obs;
  final email = ''.obs;
  final isLoading = false.obs;

  // Préférences notifications (état local)
  final notifEmail = true.obs;
  final notifSms = false.obs;
  final notifPush = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    try {
      // Requête GET /users/me?populate=*
      final profile = await _auth.syncCurrentUserProfile(force: true);
      if (profile != null) {
        username.value = _extract(profile, ['username', 'name', 'fullName']);
        email.value = _extract(profile, ['email']);
      }
    } catch (_) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  void saveNotifPreferences() {
    Get.snackbar(
      'Paramètres',
      'Préférences enregistrées.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void changePassword() {
    Get.snackbar(
      'Sécurité',
      'Fonctionnalité bientôt disponible.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _extract(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = (map[k] ?? '').toString().trim();
      if (v.isNotEmpty && v != 'null') return v;
    }
    return '';
  }
}

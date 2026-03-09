import 'package:flutter_getx_app/app/core/service/auth_service.dart';
import 'package:flutter_getx_app/app/data/models/training_session_model.dart';
import 'package:flutter_getx_app/app/data/services/training_sessions_api.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';
import 'package:get/get.dart';

class ProfessionalFormationsController extends GetxController {
  static const int _professionalFormationsMenuIndex = 20;

  final TrainingSessionsApi _api;
  final AuthService _authService;

  Worker? _menuWorker;

  ProfessionalFormationsController({
    TrainingSessionsApi? api,
    AuthService? authService,
  })  : _api = api ?? TrainingSessionsApi(),
        _authService = authService ?? Get.find<AuthService>();

  final RxList<TrainingSession> availableSessions = <TrainingSession>[].obs;
  final RxList<TrainingSession> mySessions = <TrainingSession>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt tabIndex = 0.obs;

  List<TrainingSession> get filteredAvailableSessions {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return availableSessions;

    return availableSessions.where((session) {
      final content = <String>[
        session.title,
        session.courseLabel,
        session.notes ?? '',
        session.type.label,
      ].join(' ').toLowerCase();
      return content.contains(q);
    }).toList();
  }

  List<TrainingSession> get filteredMySessions {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return mySessions;

    return mySessions.where((session) {
      final content = <String>[
        session.title,
        session.courseLabel,
        session.notes ?? '',
        session.type.label,
      ].join(' ').toLowerCase();
      return content.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _watchProfessionalMenu();
  }

  @override
  void onClose() {
    _menuWorker?.dispose();
    super.onClose();
  }

  void setSearch(String value) {
    searchQuery.value = value;
  }

  Future<void> loadData({bool withLoader = true}) async {
    if (withLoader) {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final results = await Future.wait<List<TrainingSession>>([
        _api.getProfessionalAvailableSessions(),
        _api.getProfessionalMySessions(userId),
      ]);

      final available = List<TrainingSession>.from(results[0]);
      final mine = List<TrainingSession>.from(results[1]);

      final myIds = mine.map((s) => s.id).toSet();
      available.removeWhere((session) => myIds.contains(session.id));

      availableSessions.assignAll(available);
      mySessions.assignAll(mine);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (withLoader) {
        isLoading.value = false;
      }
    }
  }

  Future<void> enrollInSession(TrainingSession session) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      Get.snackbar('Erreur', 'Utilisateur non connecté');
      return;
    }

    if (isSubmitting.value) {
      return;
    }

    if (session.participants.length >= session.maxParticipants) {
      Get.snackbar('Information', 'Session complète');
      return;
    }

    isSubmitting.value = true;

    try {
      final attendeeIds = <int>{
        ...session.participants.map((item) => item.id),
        userId,
      }.toList();

      final identifier = session.documentId.trim().isNotEmpty
          ? session.documentId
          : session.id;

      await _api.updateSessionAttendees(
        identifier,
        attendeeIds: attendeeIds,
      );

      await loadData(withLoader: false);
      tabIndex.value = 1;
      Get.snackbar('Succès', 'Inscription effectuée');
    } catch (e) {
      Get.snackbar('Erreur', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> leaveSession(TrainingSession session) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      Get.snackbar('Erreur', 'Utilisateur non connecté');
      return;
    }

    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;

    try {
      final attendeeIds = session.participants
          .map((item) => item.id)
          .where((id) => id != userId)
          .toSet()
          .toList();

      final identifier = session.documentId.trim().isNotEmpty
          ? session.documentId
          : session.id;

      await _api.updateSessionAttendees(
        identifier,
        attendeeIds: attendeeIds,
      );

      await loadData(withLoader: false);
      Get.snackbar('Succès', 'Désinscription effectuée');
    } catch (e) {
      Get.snackbar('Erreur', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  void _watchProfessionalMenu() {
    if (!Get.isRegistered<HomeController>()) {
      return;
    }

    final home = Get.find<HomeController>();

    _menuWorker = ever<int>(home.selectedMenu, (menu) {
      if (menu == _professionalFormationsMenuIndex) {
        loadData();
      }
    });

    if (home.selectedMenu.value == _professionalFormationsMenuIndex) {
      loadData();
    }
  }
}

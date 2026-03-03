import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/data/models/course_model.dart';
import 'package:flutter_getx_app/app/data/models/training_session_model.dart';
import 'package:flutter_getx_app/app/data/services/courses_api.dart';
import 'package:flutter_getx_app/app/data/services/training_sessions_api.dart';
import 'package:get/get.dart';

class TrainingSessionsController extends GetxController {
  final TrainingSessionsApi _api;
  final CoursesApi _coursesApi;

  TrainingSessionsController({
    TrainingSessionsApi? api,
    CoursesApi? coursesApi,
  })  : _api = api ?? TrainingSessionsApi(),
        _coursesApi = coursesApi ?? CoursesApi();

  final RxList<TrainingSession> sessions = <TrainingSession>[].obs;
  final RxList<Course> courses = <Course>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;

  List<TrainingSession> get filteredSessions {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return sessions;

    return sessions.where((session) {
      final content = <String>[
        session.title,
        session.courseLabel,
        session.type.label,
        session.status.label,
      ].join(' ').toLowerCase();
      return content.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
    fetchCourses();
  }

  Future<void> fetchSessions() async {
    isLoading.value = true;
    try {
      final result = await _api.getSessions();
      sessions.assignAll(result.map(_resolveCourseLabelForSession).toList());
      print('✅ Sessions chargées: ${result.length}');
    } catch (e) {
      print('❌ Erreur fetchSessions: $e');
      Get.snackbar('Erreur', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCourses() async {
    try {
      final result = await _coursesApi.getCourses();
      courses.assignAll(result);
      sessions.assignAll(sessions.map(_resolveCourseLabelForSession).toList());
      print('✅ Cours chargés: ${result.length}');
    } catch (e) {
      print('❌ Erreur fetchCourses: $e');
    }
  }

  Future<void> addSession(TrainingSession session) async {
    isSaving.value = true;
    try {
      final created = await _api.createSession(session);
      final resolved = _resolveCourseLabelForSession(
        created,
        fallbackLabel: session.courseLabel,
        fallbackCourseId: session.courseAssociated,
      );
      sessions.insert(0, resolved);
      Get.snackbar('Succès', 'Session créée avec succès');
    } catch (e) {
      Get.snackbar('Erreur', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> editSession(dynamic id, TrainingSession session) async {
    isSaving.value = true;
    try {
      final updated = await _api.updateSession(id, session);
      final resolved = _resolveCourseLabelForSession(
        updated,
        fallbackLabel: session.courseLabel,
        fallbackCourseId: session.courseAssociated,
      );

      final index = sessions.indexWhere((item) => item.id == resolved.id);
      if (index >= 0) {
        sessions[index] = resolved;
      } else {
        sessions.insert(0, resolved);
      }
      Get.snackbar('Succès', 'Session mise à jour');
    } catch (e) {
      Get.snackbar('Erreur', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> removeSession(TrainingSession session) async {
    final bool confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Supprimer la session'),
            content: Text('Voulez-vous supprimer "${session.title}" ?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await _api.deleteSession(session.id);
      sessions.removeWhere((item) => item.id == session.id);
      Get.snackbar('Succès', 'Session supprimée');
    } catch (e) {
      Get.snackbar('Erreur', e.toString().replaceFirst('Exception: ', ''));
    }
  }

  TrainingSession _resolveCourseLabelForSession(
    TrainingSession session, {
    String? fallbackLabel,
    int? fallbackCourseId,
  }) {
    final currentLabel = session.courseLabel.trim();
    final currentCourseId = session.courseAssociated ?? fallbackCourseId;

    if (currentLabel.isNotEmpty && currentLabel != 'Non spécifié') {
      return session;
    }

    final matchedCourse =
        courses.firstWhereOrNull((course) => course.id == currentCourseId);

    final resolvedLabel = matchedCourse?.title ??
        ((fallbackLabel != null && fallbackLabel.trim().isNotEmpty)
            ? fallbackLabel.trim()
            : 'Non spécifié');

    return session.copyWith(
      courseAssociated: currentCourseId,
      courseLabel: resolvedLabel,
    );
  }
}

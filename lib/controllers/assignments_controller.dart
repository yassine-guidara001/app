import 'package:flutter_getx_app/app/data/models/course_model.dart';
import 'package:flutter_getx_app/app/data/services/courses_api.dart';
import 'package:flutter_getx_app/models/assignment_model.dart';
import 'package:flutter_getx_app/services/assignments_api.dart';
import 'package:get/get.dart';

class AssignmentsController extends GetxController {
  final AssignmentsApi _api;
  final CoursesApi _coursesApi;

  AssignmentsController({AssignmentsApi? api, CoursesApi? coursesApi})
      : _api = api ?? AssignmentsApi(),
        _coursesApi = coursesApi ?? CoursesApi();

  final RxList<Assignment> assignments = <Assignment>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Course> courses = <Course>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _api.getAssignments();
      assignments.assignAll(result.map(_resolveCourseName).toList());
    } catch (e) {
      final message = _normalizeError(e);
      errorMessage.value = message;
      Get.snackbar('Erreur', message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAssignment(Map data) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final created = await _api.createAssignment(data);
      assignments.insert(0, _resolveCourseName(created));
      Get.snackbar('Succès', 'Devoir créé avec succès');
      return true;
    } catch (e) {
      final message = _normalizeError(e);
      errorMessage.value = message;
      Get.snackbar('Erreur', message);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> editAssignment(int id, Map data, {String? documentId}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final updated = await _api.updateAssignment(
        id,
        data,
        documentId: documentId,
      );
      final resolved = _resolveCourseName(updated);

      final index = assignments.indexWhere((item) => item.id == resolved.id);
      if (index >= 0) {
        assignments[index] = resolved;
      } else {
        assignments.insert(0, resolved);
      }

      Get.snackbar('Succès', 'Devoir modifié avec succès');
      return true;
    } catch (e) {
      final message = _normalizeError(e);
      errorMessage.value = message;
      Get.snackbar('Erreur', message);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeAssignment(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _api.deleteAssignment(id);
      assignments.removeWhere((item) => item.id == id);
      Get.snackbar('Succès', 'Devoir supprimé avec succès');
    } catch (e) {
      final message = _normalizeError(e);
      errorMessage.value = message;
      Get.snackbar('Erreur', message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCourses() async {
    try {
      final result = await _coursesApi.getCourses();
      courses.assignAll(result);
      assignments.assignAll(assignments.map(_resolveCourseName).toList());
    } catch (e) {
      final message = _normalizeError(e);
      errorMessage.value = message;
      Get.snackbar('Erreur', message);
    }
  }

  Future<String?> uploadAttachment(dynamic file) async {
    try {
      return await _api.uploadAttachment(file);
    } catch (e) {
      final message = _normalizeError(e);
      errorMessage.value = message;
      Get.snackbar('Erreur', message);
      return null;
    }
  }

  Assignment _resolveCourseName(Assignment assignment) {
    if (assignment.courseName.trim().isNotEmpty &&
        assignment.courseName != 'Non spécifié') {
      return assignment;
    }

    final found =
        courses.firstWhereOrNull((course) => course.id == assignment.courseId);

    if (found == null) {
      return assignment;
    }

    return assignment.copyWith(courseName: found.title);
  }

  String _normalizeError(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '').trim();

    if (raw.contains('SocketException') ||
        raw.contains('Failed host lookup') ||
        raw.contains('Connection') ||
        raw.contains('Timeout')) {
      return 'Connexion impossible';
    }

    if (raw.contains('Session expirée')) return 'Session expirée';
    if (raw.contains('Accès refusé')) return 'Accès refusé';
    if (raw.contains('Ressource introuvable')) return 'Ressource introuvable';
    if (raw.contains('Données invalides')) return 'Données invalides';
    if (raw.contains('Connexion impossible')) return 'Connexion impossible';
    if (raw.contains('Erreur serveur')) return 'Erreur serveur';

    return raw.isEmpty ? 'Erreur inconnue' : raw;
  }
}

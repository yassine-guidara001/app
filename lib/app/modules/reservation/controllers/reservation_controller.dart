import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/data/models/equipment_model.dart';
import 'package:flutter_getx_app/app/data/models/space_model.dart';
import 'package:flutter_getx_app/app/modules/reservation/services/reservation_service.dart';
import 'package:get/get.dart';

/// Contrôleur pour gérer l'état de la réservation
class ReservationController extends GetxController {
  // État de chargement
  final isLoading = false.obs;

  // Espace actuellement sélectionné
  final Rx<Space?> selectedSpace = Rx<Space?>(null);

  // Équipements de l'espace sélectionné
  final RxList<Equipment> equipments = <Equipment>[].obs;

  // Date et heure sélectionnées
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> startTime = TimeOfDay.now().obs;
  final Rx<TimeOfDay> endTime = const TimeOfDay(hour: 18, minute: 0).obs;

  // Nombre de participants
  final RxInt participants = 1.obs;

  // Notes optionnelles
  final notes = ''.obs;

  // Message d'erreur
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialiser la date à aujourd'hui
    selectedDate.value = DateTime.now();

    // Initialiser l'heure de début à l'heure actuelle
    final now = TimeOfDay.now();
    startTime.value = now;

    // Initialiser l'heure de fin à 2 heures plus tard
    endTime.value = TimeOfDay(
      hour: (now.hour + 2) % 24,
      minute: now.minute,
    );
  }

  /// Charge les informations d'un espace par son slug
  Future<void> loadSpaceBySlug(String slug) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Récupérer l'espace
      final space = await ReservationService.getSpaceBySlug(slug);

      if (space != null) {
        selectedSpace.value = space;

        // Récupérer les équipements de l'espace
        final equipmentsList =
            await ReservationService.getEquipmentsBySpaceSlug(slug);
        equipments.value = equipmentsList;
      } else {
        errorMessage.value = 'Espace non trouvé';
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Met à jour la date sélectionnée
  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  /// Met à jour l'heure de début
  void updateStartTime(TimeOfDay time) {
    startTime.value = time;
  }

  /// Met à jour l'heure de fin
  void updateEndTime(TimeOfDay time) {
    endTime.value = time;
  }

  /// Met à jour le nombre de participants
  void updateParticipants(int count) {
    if (count > 0) {
      participants.value = count;
    }
  }

  /// Met à jour les notes
  void updateNotes(String text) {
    notes.value = text;
  }

  /// Valide les données de réservation
  bool validateReservation() {
    if (selectedSpace.value == null) {
      errorMessage.value = 'Aucun espace sélectionné';
      return false;
    }

    // Vérifier que la date n'est pas dans le passé
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    if (selectedDateTime.isBefore(DateTime(now.year, now.month, now.day))) {
      errorMessage.value = 'La date doit être aujourd\'hui ou dans le futur';
      return false;
    }

    // Vérifier que l'heure de fin est après l'heure de début
    final startMinutes = startTime.value.hour * 60 + startTime.value.minute;
    final endMinutes = endTime.value.hour * 60 + endTime.value.minute;

    if (endMinutes <= startMinutes) {
      errorMessage.value = 'L\'heure de fin doit être après l\'heure de début';
      return false;
    }

    // Vérifier la capacité
    final capacity = selectedSpace.value?.capacity ?? 0;
    if (participants.value > capacity) {
      errorMessage.value =
          'Le nombre de participants dépasse la capacité ($capacity)';
      return false;
    }

    errorMessage.value = '';
    return true;
  }

  /// Soumet la réservation
  Future<bool> submitReservation() async {
    if (!validateReservation()) {
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final space = selectedSpace.value!;

      // Formater les heures au format HH:mm
      final startTimeStr =
          '${startTime.value.hour.toString().padLeft(2, '0')}:${startTime.value.minute.toString().padLeft(2, '0')}';
      final endTimeStr =
          '${endTime.value.hour.toString().padLeft(2, '0')}:${endTime.value.minute.toString().padLeft(2, '0')}';

      final success = await ReservationService.createReservation(
        spaceId: space.documentId,
        date: selectedDate.value,
        startTime: startTimeStr,
        endTime: endTimeStr,
        participants: participants.value,
        notes: notes.value.isEmpty ? null : notes.value,
      );

      if (success) {
        // Réinitialiser le formulaire
        resetForm();
        return true;
      } else {
        errorMessage.value = 'Échec de la création de la réservation';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Erreur: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Réinitialise le formulaire
  void resetForm() {
    selectedSpace.value = null;
    equipments.clear();
    selectedDate.value = DateTime.now();
    final now = TimeOfDay.now();
    startTime.value = now;
    endTime.value = TimeOfDay(
      hour: (now.hour + 2) % 24,
      minute: now.minute,
    );
    participants.value = 1;
    notes.value = '';
    errorMessage.value = '';
  }

  /// Calcule la durée en heures
  double get durationInHours {
    final startMinutes = startTime.value.hour * 60 + startTime.value.minute;
    final endMinutes = endTime.value.hour * 60 + endTime.value.minute;
    return (endMinutes - startMinutes) / 60.0;
  }

  /// Calcule le coût estimé (horaire)
  double get estimatedCost {
    final space = selectedSpace.value;
    if (space == null) return 0.0;
    return space.hourlyRate * durationInHours;
  }
}

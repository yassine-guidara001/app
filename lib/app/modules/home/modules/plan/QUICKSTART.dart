// DÉMARRAGE RAPIDE - Plan Interactif

import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

// ========== 1. ACCÉDER AU PLAN ==========

// Depuis n'importe quel endroit dans l'app:
void openPlan() {
  Get.toNamed(Routes.PLAN);
}

// Exemple: Depuis un bouton du Dashboard
// ElevatedButton(
//   onPressed: () => Get.toNamed(Routes.PLAN),
//   child: Text('Voir le plan'),
// )

// ========== 2. AJUSTER LES COORDONNÉES ==========

// Fichier à modifier: lib/app/modules/home/modules/plan/models/space_model.dart

// Avant (placeholder):
// SpaceModel(
//   id: 1,
//   name: 'Open Space Principal',
//   left: 480, top: 250,
//   width: 220, height: 120,
// )

// Après (vos vraies coordonnées):
// SpaceModel(
//   id: 1,
//   name: 'Open Space Principal',
//   left: 150,  // Votre X du SVG
//   top: 200,   // Votre Y du SVG
//   width: 300, // Votre largeur
//   height: 150, // Votre hauteur
// )

// ========== 3. REMPLACER LE SVG ==========

// Copier votre plan.svg dans: assets/plan.svg
// Le chemin doit correspondre à pubspec.yaml qui dit:
// flutter:
//   assets:
//     - assets/
//     - assets/plan.svg

// ========== 4. TESTER LOCALEMENT ==========

void testPlan() async {
  // Option 1: Via la route
  // Get.toNamed(Routes.PLAN);

  // Option 2: Via le contrôleur (advanced)
  // final controller = Get.find<PlanController>();
  // controller.selectSpace(planSpaces[0]);
}

// ========== 5. INTÉGRER L'API DE RÉSERVATION ==========

// Modifier: lib/app/modules/home/modules/plan/controllers/plan_controller.dart
// Fonction à modifier: submitReservation()

/*
Future<void> submitReservation() async {
  if (selectedSpace.value == null) return;

  // ✅ À FAIRE: Appelez votre API
  try {
    final response = await HttpService.post(
      '/api/reservations', // Votre endpoint
      body: {
        'spaceId': selectedSpace.value!.id,
        'date': dateCtrl.text,
        'time': timeCtrl.text,
        'guestCount': int.parse(guestsCtrl.text),
        'notes': notesCtrl.text,
      },
    );

    if (response.statusCode == 201) {
      Get.snackbar(
        'Succès',
        'Réservation de "${selectedSpace.value!.name}" confirmée',
        backgroundColor: Color(0xFF10B981),
        colorText: Colors.white,
      );
      closeReservationModal();
    } else {
      throw Exception('Erreur serveur');
    }
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Impossible de réserver: $e',
      backgroundColor: Color(0xFFEF4444),
      colorText: Colors.white,
    );
  }
}
*/

// ========== 6. AJOUTER UN BOUTON AU DASHBOARD ==========

// Dans dashboard_view.dart, ajouter:
/*
ElevatedButton(
  onPressed: () => Get.toNamed(Routes.PLAN),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2764DB),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.map, size: 18),
      SizedBox(width: 8),
      Text('Visualiser le plan'),
    ],
  ),
),
*/

// ========== 7. FICHIERS IMPORTANTS ==========

/*

FICHIERS À CONNAÎTRE:

1. lib/app/modules/home/modules/plan/models/space_model.dart
   - Contient la liste des 13 espaces
   - À personnaliser avec vos coordonnées

2. lib/app/modules/home/modules/plan/controllers/plan_controller.dart
   - Gestion de l'état (GetX)
   - Contient submitReservation() à intégrer avec l'API

3. lib/app/modules/home/modules/plan/views/plan_view.dart
   - Affichage du plan SVG
   - Création des zones cliquables

4. lib/app/modules/home/modules/plan/views/widgets/reservation_modal.dart
   - Formulaire de réservation
   - Validation des champs

5. assets/plan.svg
   - À remplacer par votre plan réel

*/

// ========== 8. STRUCTURE DE RÉPONSE API ATTENDUE ==========

/*

Votre POST /api/reservations devrait retourner:

{
  "id": "reservation_123",
  "spaceId": 1,
  "spaceName": "Open Space Principal",
  "userId": "user_456",
  "date": "15/03/2026",
  "time": "14:00",
  "guestCount": 5,
  "notes": "Réunion importante",
  "status": "confirmed",
  "createdAt": "2026-03-12T12:34:56Z"
}

*/

// ========== 9. CHECKLIST DE DÉPLOIEMENT ==========

/*

Avant de mettre en production:

✅ Remplacer assets/plan.svg par votre vrai plan
✅ Ajuster les coordonnées dans space_model.dart
✅ Tester chaque zone cliquable
✅ Intégrer l'API dans submitReservation()
✅ Tester la validation du formulaire
✅ Tester les snackbars d'erreur
✅ Vérifier la responsive sur mobile
✅ Nettoyer les logs de debug

*/

// ========== 10. TROUBLESHOOTING ==========

/*

PROBLÈME: Le SVG ne charge pas
SOLUTION: Vérifier:
  - assets/plan.svg existe
  - pubspec.yaml contient "- assets/plan.svg"
  - Faire: flutter pub get

PROBLÈME: Les zones ne cliquent pas
SOLUTION: 
  - Vérifier les coordonnées dans space_model.dart
  - Utiliser le DEBUG mode pour voir les zones

PROBLÈME: La modale ne s'affiche pas
SOLUTION:
  - Vérifier les imports de ReservationModal
  - Vérifier que PlanController est bien injecté

PROBLÈME: Les réservations ne se sauvegardent pas
SOLUTION:
  - Vérifier que submitReservation() appelle vraiment l'API
  - Vérifier les logs pour les erreurs réseau

*/

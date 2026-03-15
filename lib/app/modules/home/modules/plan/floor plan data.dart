import 'package:flutter/material.dart';

class FloorSpaceZone {
  final String spaceId;
  final String label;
  final Rect rect; // coordonnées dans le viewBox SVG : 0 0 2780 1974

  const FloorSpaceZone({
    required this.spaceId,
    required this.label,
    required this.rect,
  });

  bool containsPoint(Offset point) => rect.contains(point);
}

/// Zones calées sur les grandes zones GRISES FONCÉES du SVG (class="T", fill=#d9d9d9)
/// viewBox = 0 0 2780 1974
/// 
/// Zones identifiées depuis les paths SVG :
/// M10 394 H229 V196... → zone gauche haute
/// M2251 1645 h503... → zone droite
/// M774 771 ... → zone centrale
/// M457 600 H239 V384 H10 V18 h447 → zone gauche milieu
/// etc.
class FloorPlanData {
  static const double svgWidth  = 2780;
  static const double svgHeight = 1974;

  static const List<FloorSpaceZone> zones = [

    // ── Zone 1 : Couloir/bureaux gauche-haut (M10 394 H229 V196) ─────────
    FloorSpaceZone(
      spaceId: '1',
      label: 'Bureau Gauche Haut',
      rect: Rect.fromLTWH(10, 196, 219, 200),
    ),

    // ── Zone 2 : Grande zone gauche-bas (M457 600 H239 V384 H10 V18) ─────
    FloorSpaceZone(
      spaceId: '2',
      label: 'Open Space Gauche',
      rect: Rect.fromLTWH(10, 18, 448, 582),
    ),

    // ── Zone 3 : Bureaux privés gauche-milieu ─────────────────────────────
    FloorSpaceZone(
      spaceId: '3',
      label: 'Bureau Privé A',
      rect: Rect.fromLTWH(10, 600, 448, 863),
    ),

    // ── Zone 4 : Salle de réunion centre-haut (tables rondes) ────────────
    FloorSpaceZone(
      spaceId: '4',
      label: 'Salle de Réunion Principale',
      rect: Rect.fromLTWH(555, 240, 420, 270),
    ),

    // ── Zone 5 : Salle de réunion centre (grande table) ──────────────────
    FloorSpaceZone(
      spaceId: '5',
      label: 'Grande Salle de Réunion',
      rect: Rect.fromLTWH(735, 240, 290, 270),
    ),

    // ── Zone 6 : Bureaux individuels centre-gauche ────────────────────────
    FloorSpaceZone(
      spaceId: '6',
      label: 'Bureaux Individuels',
      rect: Rect.fromLTWH(370, 462, 400, 410),
    ),

    // ── Zone 7 : Zone centrale (M774 771) ────────────────────────────────
    FloorSpaceZone(
      spaceId: '7',
      label: 'Espace Coworking Central',
      rect: Rect.fromLTWH(826, 858, 395, 250),
    ),

    // ── Zone 8 : Salle centre-droite (M1221 1117) ────────────────────────
    FloorSpaceZone(
      spaceId: '8',
      label: 'Salle de Formation',
      rect: Rect.fromLTWH(1221, 1117, 229, 394),
    ),

    // ── Zone 9 : Bureau premium (M826 1107 h384) ─────────────────────────
    FloorSpaceZone(
      spaceId: '9',
      label: 'Open Space Sud',
      rect: Rect.fromLTWH(826, 1107, 384, 394),
    ),

    // ── Zone 10 : Zone toilettes/locaux techniques (M468 868) ───────────
    FloorSpaceZone(
      spaceId: '10',
      label: 'Bureau Sud-Ouest',
      rect: Rect.fromLTWH(468, 868, 348, 712),
    ),

    // ── Zone 11 : Salle de réunion droite haut (M2251 853) ───────────────
    FloorSpaceZone(
      spaceId: '11',
      label: 'Espace Réunion Droite A',
      rect: Rect.fromLTWH(2251, 443, 529, 381),
    ),

    // ── Zone 12 : Salle droite milieu-haut (M2251 467) ───────────────────
    FloorSpaceZone(
      spaceId: '12',
      label: 'Espace Réunion Droite B',
      rect: Rect.fromLTWH(2251, 824, 529, 411),
    ),

    // ── Zone 13 : Salle droite milieu-bas (M2261 1234) ───────────────────
    FloorSpaceZone(
      spaceId: '13',
      label: 'Espace Bureau Droite A',
      rect: Rect.fromLTWH(2261, 1235, 493, 400),
    ),

    // ── Zone 14 : Salle droite bas (M2261 1615) ──────────────────────────
    FloorSpaceZone(
      spaceId: '14',
      label: 'Espace Bureau Droite B',
      rect: Rect.fromLTWH(2251, 1645, 503, 292),
    ),

    // ── Zone 15 : Grande zone droite (M2251 18 h739) ─────────────────────
    FloorSpaceZone(
      spaceId: '15',
      label: 'Open Space Droit',
      rect: Rect.fromLTWH(2251, 18, 529, 425),
    ),

    // ── Zone 16 : Zone salle bas-droite (M1559 1223) ─────────────────────
    FloorSpaceZone(
      spaceId: '16',
      label: 'Salle Sud-Est',
      rect: Rect.fromLTWH(1560, 1223, 255, 288),
    ),

    // ── Zone 17 : Grande zone centre-droite haute (M1952 857) ────────────
    FloorSpaceZone(
      spaceId: '17',
      label: 'Grande Salle Centre',
      rect: Rect.fromLTWH(1415, 462, 537, 395),
    ),

    // ── Zone 18 : Salle bas-centre (M2033 1937) ──────────────────────────
    FloorSpaceZone(
      spaceId: '18',
      label: 'Studio Sud',
      rect: Rect.fromLTWH(1560, 1442, 473, 416),
    ),
  ];
}
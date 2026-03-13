// Widget DEBUG - À utiliser uniquement lors de l'ajustement des coordonnées
// Pour activer le debug mode, changez showDebugZones = true dans plan_view.dart

import 'package:flutter/material.dart';
import '../../models/space_model.dart';

/// Widget pour afficher visuellement les zones cliquables (DEBUG)
class ClickableZoneDebugger extends StatelessWidget {
  final SpaceModel space;
  final bool isHovered;

  const ClickableZoneDebugger({
    required this.space,
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: space.left,
      top: space.top,
      child: Container(
        width: space.width,
        height: space.height,
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.blue.withOpacity(0.3)
              : Colors.red.withOpacity(0.2),
          border: Border.all(
            color: isHovered ? Colors.blue : Colors.red,
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Zone ${space.id}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '(${space.left.toInt()}, ${space.top.toInt()})',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '${space.width.toInt()}x${space.height.toInt()}px',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            if (isHovered)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    space.name,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*

INSTRUCTIONS POUR UTILISER LE DEBUG MODE:

1. Ouvrir plan_view.dart
2. Ajouter au top de la classe PlanView:
   static const bool showDebugZones = true;  // Changez à true pour activer

3. Dans le Stack qui crée les zones cliquables, remplacer:
   ...planSpaces.map((space) => Positioned(...))
   
   Par:
   ...planSpaces.map((space) {
     if (showDebugZones) {
       return ClickableZoneDebugger(space: space);
     }
     return Positioned(...);
   })

4. Lancer l'app - vous verrez toutes les zones cliquables en rouge/bleu

5. Une fois ajustée, mettez showDebugZones = false pour revenir à la production

*/

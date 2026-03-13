// Ce fichier de documentation explique comment ajuster les coordonnées des espaces
// pour correspondre exactement à votre plan SVG original.

/*

GUIDE D'AJUSTEMENT DES COORDONNÉES

1. OUVRIR LE PLAN SVG DANS UN ÉDITEUR
   - Ouvrez votre plan.svg original dans un éditeur (VS Code, Inkscape, etc.)
   - Notez les dimensions du SVG: <svg viewBox="0 0 WIDTH HEIGHT" ...>

2. IDENTIFIER LES POSITIONS
   Pour chaque espace numéroté sur votre plan:
   
   a) Avec Inkscape:
      - Sélectionnez l'espace
      - Voir la position X et Y dans les propriétés
      - Voir la largeur (W) et hauteur (H)
   
   b) Avec l'inspecteur SVG:
      - Ouvrez dans le navigateur
      - Clic-droit > Inspecter
      - Trouvez le <rect> correspondant
      - Lisez les attributs x, y, width, height

3. METTRE À JOUR space_model.dart

   Exemple: Si Espace 1 a:
   - Position X: 480px
   - Position Y: 250px
   - Largeur: 220px
   - Hauteur: 120px

   Mettez à jour:
   
   SpaceModel(
     id: 1,
     name: 'Open Space Principal',
     left: 480,      // Votre X du SVG
     top: 250,       // Votre Y du SVG
     width: 220,     // Votre largeur du SVG
     height: 120,    // Votre hauteur du SVG
     description: 'Grand espace ouvert pour équipes',
   ),

4. TESTER L'ALIGNEMENT
   - Lancez l'app: flutter run
   - Naviguez vers Routes.PLAN
   - Cliquez sur chaque zone numérotée
   - Les zones doivent correspondre exactement aux espaces du plan

5. AFFINER SI NÉCESSAIRE
   - Si une zone ne correspond pas bien:
     * Augmentez légèrement left/top pour décaler vers la droite/bas
     * Gonflez width/height pour couvrir mieux l'espace
   - Testez à nouveau après chaque ajustement

TIPS:
- Les coordonnées sont relatives au coin haut-gauche du SVG
- L'app affiche le numéro de l'espace présenté (ex: "1")
- Utilizez l'évènement onTap pour vérifier quelle zone a été cliquée
- Vous pouvez ajouter des logs via:
  print('Space ${space.id} at (${space.left}, ${space.top})')

*/

// Exemple de modification complète pour 13 espaces:
final List<SpaceModel> planSpacesExample = [
  // Ajustez ces coordonnées selon votre plan réel
  SpaceModel(
    id: 1,
    name: 'Open Space Principal',
    left: 480,
    top: 250,
    width: 220,
    height: 120,
    description: 'Grand espace ouvert pour équipes',
  ),
  // ... continuer pour les autres espaces ...
];

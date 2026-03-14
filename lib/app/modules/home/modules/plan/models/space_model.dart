class SpaceModel {
  final int id;
  final String name;
  final double left;
  final double top;
  final double width;
  final double height;
  final String category;
  final int capacity;
  final bool isAvailable;
  final String? description;

  SpaceModel({
    required this.id,
    required this.name,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.category,
    required this.capacity,
    this.isAvailable = true,
    this.description,
  });
}

// Données des espaces avec leurs coordonnées
// id plan == numéro backend (slug = espace{id}, ex: id=1 → espace1 → "Open Space Principal")
final List<SpaceModel> planSpaces = [
  SpaceModel(
    id: 1,
    name: 'Open Space Principal',
    left: 245,
    top: 8,
    width: 408,
    height: 175,
    category: 'Espace de travail',
    capacity: 6,
    description: 'Grand espace ouvert pour équipes',
  ),
  SpaceModel(
    id: 2,
    name: 'Espace 2',
    left: 840,
    top: 80,
    width: 260,
    height: 155,
    category: 'Salle de reunion',
    capacity: 2,
    description: 'Salle de réunion 2 places',
  ),
  SpaceModel(
    id: 3,
    name: 'Espace 3',
    left: 840,
    top: 240,
    width: 260,
    height: 155,
    category: 'Salle de reunion',
    capacity: 4,
    description: 'Salle de réunion 4 places',
  ),
  SpaceModel(
    id: 4,
    name: 'Espace 4',
    left: 980,
    top: 380,
    width: 120,
    height: 100,
    category: 'Bureau prive',
    capacity: 4,
    description: 'Bureau privé',
  ),
  SpaceModel(
    id: 5,
    name: 'Espace 5',
    left: 980,
    top: 510,
    width: 120,
    height: 100,
    category: 'Cabine telephonique',
    capacity: 1,
    description: 'Cabine téléphonique',
  ),
  SpaceModel(
    id: 6,
    name: 'Espace 6',
    left: 700,
    top: 510,
    width: 120,
    height: 100,
    category: 'Zone relax',
    capacity: 4,
    description: 'Zone relax',
  ),
  SpaceModel(
    id: 7,
    name: 'Espace 7',
    left: 550,
    top: 510,
    width: 120,
    height: 100,
    category: 'Kitchenette',
    capacity: 3,
    description: 'Kitchenette',
  ),
  SpaceModel(
    id: 8,
    name: 'Espace 8',
    left: 280,
    top: 510,
    width: 120,
    height: 100,
    category: 'Espace service',
    capacity: 2,
    description: 'WC',
  ),
  SpaceModel(
    id: 9,
    name: 'Espace 9',
    left: 280,
    top: 380,
    width: 80,
    height: 80,
    category: 'Rangement',
    capacity: 1,
    description: 'Rangement',
  ),
  SpaceModel(
    id: 10,
    name: 'Espace 10',
    left: 180,
    top: 350,
    width: 80,
    height: 120,
    category: 'Espace de passage',
    capacity: 1,
    description: 'Escalier',
  ),
  SpaceModel(
    id: 12,
    name: 'Espace 12',
    left: 600,
    top: 250,
    width: 120,
    height: 120,
    category: 'Bureau open space',
    capacity: 6,
    description: 'Bureau open space',
  ),
  SpaceModel(
    id: 13,
    name: 'Espace 13',
    left: 750,
    top: 380,
    width: 100,
    height: 100,
    category: 'Espace client',
    capacity: 4,
    description: 'Espace client',
  ),
];

class SpaceModel {
  final String id;
  final String name;
  final String description;
  final int maxPersons;
  final double pricePerHour;
  final double pricePerDay;
  final List<EquipmentModel> equipments;
  final SpaceType type;
  final bool isAvailable;

  const SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.maxPersons,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.equipments,
    required this.type,
    this.isAvailable = true,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id']?.toString() ?? '',
      name: json['attributes']?['name'] ?? json['name'] ?? '',
      description: json['attributes']?['description'] ?? json['description'] ?? '',
      maxPersons: json['attributes']?['maxPersons'] ?? json['maxPersons'] ?? 1,
      pricePerHour: (json['attributes']?['pricePerHour'] ?? json['pricePerHour'] ?? 0).toDouble(),
      pricePerDay: (json['attributes']?['pricePerDay'] ?? json['pricePerDay'] ?? 0).toDouble(),
      equipments: [],
      type: SpaceType.values.firstWhere(
        (e) => e.name == (json['attributes']?['type'] ?? json['type'] ?? 'openSpace'),
        orElse: () => SpaceType.openSpace,
      ),
      isAvailable: json['attributes']?['isAvailable'] ?? json['isAvailable'] ?? true,
    );
  }
}

class EquipmentModel {
  final String id;
  final String name;
  final double price;

  const EquipmentModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id']?.toString() ?? '',
      name: json['attributes']?['name'] ?? json['name'] ?? '',
      price: (json['attributes']?['price'] ?? json['price'] ?? 0).toDouble(),
    );
  }
}

enum SpaceType {
  openSpace,
  meetingRoom,
  privateOffice,
  coworking,
  studio,
}

extension SpaceTypeExtension on SpaceType {
  String get label {
    switch (this) {
      case SpaceType.openSpace:
        return 'Open Space';
      case SpaceType.meetingRoom:
        return 'Salle de Réunion';
      case SpaceType.privateOffice:
        return 'Bureau Privé';
      case SpaceType.coworking:
        return 'Coworking';
      case SpaceType.studio:
        return 'Studio';
    }
  }
}

class ReservationModel {
  final String? id;
  final String spaceId;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final bool fullDay;
  final int participants;
  final String? userId;
  final ReservationStatus status;

  const ReservationModel({
    this.id,
    required this.spaceId,
    required this.date,
    this.startTime,
    this.endTime,
    required this.fullDay,
    required this.participants,
    this.userId,
    this.status = ReservationStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'data': {
      'space': spaceId,
      'date': date.toIso8601String().split('T').first,
      'startTime': startTime,
      'endTime': endTime,
      'fullDay': fullDay,
      'participants': participants,
      'status': status.name,
    }
  };
}

enum ReservationStatus { pending, confirmed, cancelled }
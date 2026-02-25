class Space {
  final int id;
  final String documentId;
  final String name;
  final String slug;
  final String? type;
  final String? location;
  final String? floor;
  final int capacity;
  final double area;
  final int svgWidth;
  final int svgHeight;
  final String status;
  final bool isCoworking;
  final bool allowGuestReservations;
  final double hourlyRate;
  final double dailyRate;
  final double monthlyRate;
  final String currency;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Space({
    required this.id,
    required this.documentId,
    required this.name,
    required this.slug,
    required this.type,
    required this.location,
    required this.floor,
    required this.capacity,
    required this.area,
    required this.svgWidth,
    required this.svgHeight,
    required this.status,
    required this.isCoworking,
    required this.allowGuestReservations,
    required this.hourlyRate,
    required this.dailyRate,
    required this.monthlyRate,
    required this.currency,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory Space.fromJson(Map<String, dynamic> json) {
    final attrs = json["attributes"];
    final a = attrs is Map<String, dynamic> ? attrs : json;

    final rawDocumentId = json["documentId"] ??
        json["document_id"] ??
        a["documentId"] ??
        a["document_id"];

    return Space(
      id: _toInt(json["id"]),
      documentId: (rawDocumentId ?? '').toString().trim(),
      name: (a["name"] ?? "").toString(),
      slug: (a["slug"] ?? "").toString(),
      type: a["type"]?.toString(),
      location: a["location"]?.toString(),
      floor: a["floor"]?.toString(),
      capacity: _toInt(a["capacity"], fallback: 1),
      area: _toDouble(a["area_sqm"]),
      svgWidth: _toInt(a["svg_width"]),
      svgHeight: _toInt(a["svg_height"]),
      status: (a["availability_status"] ?? "Disponible").toString(),
      isCoworking: _toBool(a["is_coworking"]),
      allowGuestReservations: _toBool(a["allow_guest_reservations"]),
      hourlyRate: _toDouble(a["hourly_rate"]),
      dailyRate: _toDouble(a["daily_rate"]),
      monthlyRate: _toDouble(a["monthly_rate"]),
      currency: (a["currency"] ?? "TND").toString(),
      description: (a["description"] ?? "").toString(),
      createdAt: _toDateTime(a["createdAt"]),
      updatedAt: _toDateTime(a["updatedAt"]),
    );
  }
}

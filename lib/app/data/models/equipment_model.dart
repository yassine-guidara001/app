class Equipment {
  final int id;
  final String documentId;
  final String name;
  final String type;
  final String serialNumber;
  final String status;
  final String purchaseDate;
  final double purchasePrice;
  final String warrantyExpiration;
  final String space;
  final String description;
  final String notes;

  Equipment({
    required this.id,
    this.documentId = '',
    required this.name,
    required this.type,
    required this.serialNumber,
    required this.status,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.warrantyExpiration,
    required this.space,
    this.description = '',
    this.notes = '',
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

  static String _toStr(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    final s = v.toString();
    return s;
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    final a = attrs is Map<String, dynamic> ? attrs : json;

    final rawDocumentId = json['documentId'] ??
        json['document_id'] ??
        a['documentId'] ??
        a['document_id'];

    final name = _toStr(a['name']);
    final type = _toStr(a['type']);
    final serialNumber = _toStr(a['serial_number']);
    final status = _toStr(
      a['status'],
      fallback: _toStr(a['mystatus'], fallback: 'Disponible'),
    );
    final purchaseDate = _toStr(a['purchase_date']);
    final warrantyExpiration = _toStr(a['warranty_expiry']);
    final purchasePrice = _toDouble(a['purchase_price']);
    final description = _toStr(a['description']);
    final notes = _toStr(a['notes']);

    final spaceLabel = _extractFirstSpaceLabel(a);

    return Equipment(
      id: _toInt(json['id']),
      documentId: _toStr(rawDocumentId).trim(),
      name: name,
      type: type,
      serialNumber: serialNumber,
      status: status.isEmpty ? 'Disponible' : status,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      warrantyExpiration: warrantyExpiration,
      space: spaceLabel,
      description: description,
      notes: notes,
    );
  }

  static String _extractFirstSpaceLabel(Map<String, dynamic> a) {
    final rel = a['spaces'];

    // Strapi v4 classique: { data: [ { id, attributes: {name} } ] }
    if (rel is Map) {
      final data = rel['data'];
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map) {
          final firstAttrs = first['attributes'];
          final n = (firstAttrs is Map) ? firstAttrs['name'] : null;
          if (n != null && n.toString().trim().isNotEmpty) {
            return n.toString();
          }
          final id = first['id'];
          return id?.toString() ?? 'Aucun';
        }
      }
      return 'Aucun';
    }

    // Strapi (observé): spaces: [ {id, name, ...} ] ou [id,...]
    if (rel is List) {
      if (rel.isEmpty) return 'Aucun';
      final first = rel.first;
      if (first is Map) {
        final n = first['name'];
        if (n != null && n.toString().trim().isNotEmpty) {
          return n.toString();
        }
        final id = first['id'] ?? first['documentId'] ?? first['document_id'];
        return id?.toString() ?? 'Aucun';
      }
      if (first is int || first is num || first is String) {
        return first.toString();
      }
    }

    return 'Aucun';
  }
}

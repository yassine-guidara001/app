import 'package:flutter_getx_app/app/data/services/reservations_service.dart';
import 'package:get/get.dart';

class ReservationsController extends GetxController {
  final ReservationsService _service = ReservationsService();

  final allReservations = <ReservationModel>[].obs;
  final reservations = <ReservationModel>[].obs;
  final isLoading = false.obs;
  final selectedStatus = 'Tous'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadReservations();
  }

  Future<void> loadReservations() async {
    try {
      isLoading.value = true;

      final result = await _service.getReservations();

      final List<dynamic> data = result['data'] ?? [];
      final fetchedReservations =
          data.map((json) => ReservationModel.fromJson(json)).toList();

      allReservations.assignAll(fetchedReservations);
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les réservations: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String newStatus) async {
    try {
      await _service.updateReservationStatus(id, newStatus);
      await loadReservations();
      Get.snackbar(
        'Succès',
        'Statut mis à jour',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le statut: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteReservation(int id) async {
    try {
      await _service.deleteReservation(id);
      await loadReservations();
      Get.snackbar(
        'Succès',
        'Réservation supprimée',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  int get totalCount => allReservations.length;

  int get confirmedCount => allReservations
      .where((item) => _normalizeStatus(item.status) == 'confirmé')
      .length;

  int get pendingCount => allReservations
      .where((item) => _normalizeStatus(item.status) == 'en attente')
      .length;

  List<ReservationModel> get upcomingReservations {
    final now = DateTime.now();
    final upcoming = reservations.where((item) => item.dateTime.isAfter(now));
    final sorted = upcoming.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sorted;
  }

  void _applyFilters() {
    final selected = _normalizeStatus(selectedStatus.value);
    final query = searchQuery.value.trim().toLowerCase();

    final filtered = allReservations.where((item) {
      final statusMatches = selectedStatus.value == 'Tous' ||
          _normalizeStatus(item.status) == selected;

      final searchMatches = query.isEmpty ||
          item.spaceName.toLowerCase().contains(query) ||
          item.userName.toLowerCase().contains(query);

      return statusMatches && searchMatches;
    }).toList();

    reservations.assignAll(filtered);
  }

  String _normalizeStatus(String value) {
    final lower = value.toLowerCase().trim().replaceAll('_', ' ');
    if (lower == 'en attente') return 'en attente';
    if (lower == 'confirme' || lower == 'confirmé') return 'confirmé';
    if (lower == 'annule' || lower == 'annulé') return 'annulé';
    return lower;
  }
}

class ReservationModel {
  final int id;
  final String spaceName;
  final String userName;
  final String userEmail;
  final String? userType;
  final DateTime dateTime;
  final double amount;
  final String status;
  final String? paymentMethod;

  ReservationModel({
    required this.id,
    required this.spaceName,
    required this.userName,
    required this.userEmail,
    this.userType,
    required this.dateTime,
    required this.amount,
    required this.status,
    this.paymentMethod,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final attributes = _extractAttributes(json);
    final space = _extractRelationMap(attributes['space']);
    final user = _extractRelationMap(attributes['user']);

    return ReservationModel(
      id: _toInt(json['id']),
      spaceName: _firstNonEmptyString([
        space?['name'],
        attributes['space_name'],
      ], fallback: 'N/A'),
      userName: _firstNonEmptyString([
        user?['username'],
        user?['fullName'],
        attributes['organizer_name'],
        attributes['guest_name'],
      ], fallback: 'Inconnu'),
      userEmail: _firstNonEmptyString([
        user?['email'],
        attributes['guest_email'],
      ]),
      userType: _firstNonEmptyString([
        attributes['userType'],
        attributes['user_type'],
      ]),
      dateTime: _parseDate([
            attributes['start_datetime'],
            attributes['startDate'],
            attributes['createdAt'],
          ]) ??
          DateTime.now(),
      amount: _toDouble(
        attributes['total_amount'] ??
            attributes['amount'] ??
            attributes['totalAmount'],
      ),
      status: _firstNonEmptyString([
        attributes['mystatus'],
        attributes['status'],
      ], fallback: 'en_attente'),
      paymentMethod: _firstNonEmptyString([
        attributes['payment_method'],
        attributes['paymentMethod'],
      ]),
    );
  }

  static Map<String, dynamic> _extractAttributes(Map<String, dynamic> source) {
    final attrs = source['attributes'];
    if (attrs is Map) {
      return Map<String, dynamic>.from(attrs);
    }
    return Map<String, dynamic>.from(source);
  }

  static Map<String, dynamic>? _extractRelationMap(dynamic value) {
    if (value is Map) {
      final dynamic data = value['data'];
      if (data is Map) {
        final dynamic nestedAttrs = data['attributes'];
        if (nestedAttrs is Map) {
          return Map<String, dynamic>.from(nestedAttrs);
        }
        return Map<String, dynamic>.from(data);
      }

      final dynamic attrs = value['attributes'];
      if (attrs is Map) {
        return Map<String, dynamic>.from(attrs);
      }

      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String _firstNonEmptyString(List<dynamic> values,
      {String fallback = ''}) {
    for (final value in values) {
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallback;
  }

  static DateTime? _parseDate(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate == null) {
        continue;
      }
      final parsed = DateTime.tryParse(candidate.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

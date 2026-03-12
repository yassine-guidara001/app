import 'dart:convert';
import 'package:flutter_getx_app/app/core/service/storage_service.dart';
import 'package:flutter_getx_app/app/data/models/equipment_model.dart';
import 'package:flutter_getx_app/app/data/models/space_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Service pour gérer les réservations d'espaces
class ReservationService {
  static const String baseUrl = 'http://193.111.250.244:3046/api';

  /// Récupère le token JWT depuis le storage
  static Future<String?> _getToken() async {
    try {
      final storage = Get.find<StorageService>();
      final raw = storage.getToken() ??
          storage.read<String>('jwt') ??
          storage.read<String>('token');

      if (raw == null) return null;

      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.toLowerCase().startsWith('bearer ')) {
        return trimmed.substring(7).trim();
      }

      return trimmed;
    } catch (_) {
      return null;
    }
  }

  /// Crée les headers d'authentification
  static Future<Map<String, String>> _headers(
      {required bool includeJson}) async {
    final token = await _getToken();
    return {
      if (includeJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Récupère un espace par son slug
  /// GET /api/spaces?filters[slug][$eq]=slug
  static Future<Space?> getSpaceBySlug(String slug) async {
    try {
      final uri = Uri.parse('$baseUrl/spaces').replace(
        queryParameters: {
          'filters[slug][\$eq]': slug,
          'populate': '*',
        },
      );

      final response = await http.get(
        uri,
        headers: await _headers(includeJson: false),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map<String, dynamic> ? decoded['data'] : null;

        if (data is List && data.isNotEmpty) {
          return Space.fromJson(data[0]);
        }
      }

      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'espace: $e');
      return null;
    }
  }

  /// Récupère les équipements associés à un espace via son slug
  /// GET /api/equipment-assets?filters[spaces][slug][$eq]=slug
  static Future<List<Equipment>> getEquipmentsBySpaceSlug(String slug) async {
    try {
      final uri = Uri.parse('$baseUrl/equipment-assets').replace(
        queryParameters: {
          'filters[spaces][slug][\$eq]': slug,
          'populate': '*',
        },
      );

      final response = await http.get(
        uri,
        headers: await _headers(includeJson: false),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map<String, dynamic> ? decoded['data'] : null;

        if (data is List) {
          return data
              .map((item) => Equipment.fromJson(item is Map<String, dynamic>
                  ? item
                  : {'id': 0, 'documentId': ''}))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Erreur lors de la récupération des équipements: $e');
      return [];
    }
  }

  /// Crée une réservation
  /// POST /api/reservations
  static Future<bool> createReservation({
    required String spaceId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int participants,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/reservations');

      final payload = {
        'data': {
          'space': spaceId,
          'reservation_date': date.toIso8601String().split('T')[0],
          'start_time': startTime,
          'end_time': endTime,
          'number_of_participants': participants,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'status': 'confirmed',
        }
      };

      final response = await http.post(
        uri,
        headers: await _headers(includeJson: true),
        body: jsonEncode(payload),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erreur lors de la création de la réservation: $e');
      return false;
    }
  }
}

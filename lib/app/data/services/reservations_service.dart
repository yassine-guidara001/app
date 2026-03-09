import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservationsService {
  static const String baseUrl = 'http://193.111.250.244:3046/api';

  Future<Map<String, dynamic>> getReservations() async {
    try {
      // Keep this endpoint identical to the Network capture request.
      final uri = Uri.parse(
        '$baseUrl/reservations?populate[space][populate]=*&populate[user][fields]=username,email',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reservations: $e');
    }
  }

  Future<Map<String, dynamic>> createReservation(
      Map<String, dynamic> requestBody) async {
    try {
      final uri = Uri.parse('$baseUrl/reservations');

      // Swagger expects { "data": { ... } } for Strapi content types.
      final payload = requestBody.containsKey('data')
          ? requestBody
          : {
              'data': requestBody,
            };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      throw Exception('Failed to create reservation: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating reservation: $e');
    }
  }

  Future<void> updateReservationStatus(int id, String status) async {
    try {
      final uri = Uri.parse('$baseUrl/reservations/$id');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {'mystatus': _toApiStatus(status)}
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating reservation: $e');
    }
  }

  Future<void> deleteReservation(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/reservations/$id');
      final response = await http.delete(uri);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete reservation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting reservation: $e');
    }
  }

  String _toApiStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'en attente' || normalized == 'en_attente') {
      return 'En_attente';
    }
    if (normalized == 'confirmé' || normalized == 'confirme') {
      return 'Confirmé';
    }
    if (normalized == 'annulé' || normalized == 'annule') {
      return 'Annulé';
    }
    return status;
  }
}

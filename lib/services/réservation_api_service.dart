import 'dart:convert';
import 'package:flutter_getx_app/app/modules/home/modules/plan/models/space_model.dart';
import 'package:http/http.dart' as http;

class ReservationApiService {
  static const String _baseUrl = 'http://193.111.250.244:3046/api';

  // Replace with your actual auth token storage/retrieval
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ─── Spaces ───────────────────────────────────────────────────────────────

  Future<List<SpaceModel>> fetchSpaces() async {
    final uri = Uri.parse('$_baseUrl/spaces?populate=equipments');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => SpaceModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load spaces: ${response.statusCode}');
  }

  Future<SpaceModel> fetchSpace(String id) async {
    final uri = Uri.parse('$_baseUrl/spaces/$id?populate=equipments');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return SpaceModel.fromJson(body['data']);
    }
    throw Exception('Failed to load space: ${response.statusCode}');
  }

  // ─── Reservations ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchReservationsForDate({
    required String spaceId,
    required DateTime date,
  }) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse(
      '$_baseUrl/reservations?filters[space][id][\$eq]=$spaceId&filters[date][\$eq]=$dateStr&populate=*',
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load reservations: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createReservation(ReservationModel reservation) async {
    final uri = Uri.parse('$_baseUrl/reservations');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(reservation.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['message'] ?? 'Failed to create reservation');
  }
}
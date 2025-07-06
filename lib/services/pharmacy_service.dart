// lib/services/pharmacy_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PharmacyService extends ApiService {
  static const String _pharmacyApiUrl = 'https://api-medev.com/citizen/pharmacies/nearby';
  static const String _healthEstablishmentApiUrl = 'https://api-medev.com/etablissement-sante/nearby';

  /// Récupère les pharmacies à proximité en utilisant les coordonnées GPS
  Future<Map<String, dynamic>> getNearbyPharmacies({required double latitude, required double longitude, int radius = 5}) async {
    try {
      final token = getToken();

      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.post(
        Uri.parse(_pharmacyApiUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'latitude': latitude, 'longitude': longitude, 'radius': radius}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur dans getNearbyPharmacies: $e');
      rethrow;
    }
  }

  /// Récupère les établissements de santé à proximité
  Future<Map<String, dynamic>> getNearbyHealthEstablishments({
    required double latitude,
    required double longitude,
    int radius = 5,
  }) async {
    try {
      final token = getToken();

      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.post(
        Uri.parse(_healthEstablishmentApiUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'latitude': latitude, 'longitude': longitude, 'radius': radius}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur dans getNearbyHealthEstablishments: $e');
      rethrow;
    }
  }
}

// lib/services/pharmacy_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PharmacyService extends ApiService {
  static const String _pharmacyApiUrl = 'https://api-medev.com/citizen/pharmacies/nearby';

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

  /// Formate les données des pharmacies pour l'affichage
  String formatPharmaciesForChat(List<Map<String, dynamic>> pharmacies) {
    if (pharmacies.isEmpty) {
      return "Aucune pharmacie trouvée à proximité.";
    }

    String result = "Voici les pharmacies les plus proches :\n\n";

    for (int i = 0; i < pharmacies.length && i < 5; i++) {
      final pharmacy = pharmacies[i];
      final name = pharmacy['name'] ?? 'Nom non disponible';
      final address = pharmacy['address'] ?? 'Adresse non disponible';
      final distance = pharmacy['distance'] ?? 0.0;
      final isOnDuty = pharmacy['is_on_duty'] ?? false;
      final phone = pharmacy['phone'] ?? '';

      result += "💊 $name\n";
      result += "📍 $address\n";
      result += "📏 ${distance.toStringAsFixed(1)} km\n";
      result += isOnDuty ? "🟢 De garde" : "🔴 Fermée";
      if (phone.isNotEmpty) {
        result += "\n📞 $phone";
      }
      result += "\n\n";
    }

    return result;
  }
}

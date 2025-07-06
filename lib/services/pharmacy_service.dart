import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PharmacyService extends ApiService {
  static const String _pharmacyApiUrl = 'https://api-medev.com/citizen/pharmacies/nearby';

  /// Récupère les pharmacies à proximité en utilisant les coordonnées GPS
  Future<List<Map<String, dynamic>>> getNearbyPharmacies(double latitude, double longitude) async {
    try {
      final token = getToken();

      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await http.post(
        Uri.parse(_pharmacyApiUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );

      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('pharmacies')) {
          return List<Map<String, dynamic>>.from(data['pharmacies']);
        } else {
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token d\'authentification invalide ou expiré');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des pharmacies: $e');
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
      final isOpen = pharmacy['isOpen'] ?? false;
      final phone = pharmacy['phone'] ?? '';

      result += "💊 $name\n";
      result += "📍 $address\n";
      result += "📏 ${distance.toStringAsFixed(1)} km\n";
      result += isOpen ? "🟢 Ouvert" : "🔴 Fermé";
      if (phone.isNotEmpty) {
        result += "\n📞 $phone";
      }
      result += "\n\n";
    }

    return result;
  }
}

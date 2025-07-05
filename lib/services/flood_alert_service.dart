// lib/services/flood_alert_service.dart
import 'dart:convert';
import '../core/constants/api.dart';
import 'api_service.dart';

/// Service pour la gestion des alertes d'inondation
class FloodAlertService extends ApiService {
  /// Récupère les alertes d'inondation à proximité
  Future<Map<String, dynamic>> getNearbyFloodAlerts({required double latitude, required double longitude}) async {
    try {
      final response = await postRequest(FloodAlertEndpoints.nearby, {"latitude": latitude, "longitude": longitude});

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur dans getNearbyFloodAlerts: $e');
      rethrow;
    }
  }
}

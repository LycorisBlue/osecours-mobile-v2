// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api.dart';

/**
 * Service pour gérer les appels API REST.
 * 
 * Cette classe fournit une interface unifiée pour effectuer des requêtes HTTP
 * vers le serveur backend. Elle gère automatiquement l'authentification
 * via des tokens JWT stockés dans Hive.
 */
class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  static const String authTokenBox = 'auth';

  /**
   * Récupère le token d'authentification stocké dans Hive.
   * 
   * Retourne null si aucun token n'est trouvé.
   */
  String? getToken() {
    final box = Hive.box(authTokenBox);
    return box.get('token');
  }

  /**
   * Effectue une requête HTTP GET authentifiée.
   * 
   * @param endpoint Le point de terminaison de l'API (sans le baseUrl)
   * @return http.Response
   * Ajoute automatiquement le token d'authentification dans les headers
   */
  Future<http.Response> getRequest(String endpoint) async {
    final token = getToken();
    final response = await http.get(
      Uri.parse(ApiHelper.buildUrl(endpoint)),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    return response;
  }

  /**
   * Effectue une requête HTTP POST authentifiée.
   * 
   * @param endpoint Le point de terminaison de l'API
   * @param body Les données à envoyer dans le corps de la requête
   * @return http.Response
   */
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    final token = getToken();
    final response = await http.post(
      Uri.parse(ApiHelper.buildUrl(endpoint)),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return response;
  }

  /**
   * Effectue une requête HTTP PATCH authentifiée.
   * 
   * @param endpoint Le point de terminaison de l'API
   * @param body Les données à envoyer pour la mise à jour partielle
   * @return http.Response
   */
  Future<http.Response> patchRequest(String endpoint, Map<String, dynamic> body) async {
    final token = getToken();
    final response = await http.patch(
      Uri.parse(ApiHelper.buildUrl(endpoint)),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return response;
  }

  /**
   * Effectue une requête HTTP PUT authentifiée.
   * 
   * @param endpoint Le point de terminaison de l'API
   * @param body Les données à envoyer dans le corps de la requête
   * @return http.Response
   */
  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> body) async {
    final token = getToken();
    final response = await http.put(
      Uri.parse(ApiHelper.buildUrl(endpoint)),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return response;
  }
}

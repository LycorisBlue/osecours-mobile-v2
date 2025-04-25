// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import 'api_service.dart';
import '../core/constants/api.dart';

/**
 * Service pour gérer l'authentification des utilisateurs.
 * 
 * Cette classe étend ApiService et fournit des méthodes pour l'inscription, 
 * la vérification OTP, et la gestion des identifiants externes.
 */
class AuthService extends ApiService {
  /**
   * Inscrit un nouvel utilisateur.
   * 
   * @param fullName Nom complet de l'utilisateur
   * @param phoneNumber Numéro de téléphone
   * @return Résultat de l'inscription
   */
  Future<Map<String, dynamic>> registerUser({required String fullName, required String phoneNumber}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiHelper.buildUrl(AuthEndpoints.register)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"fullName": fullName, "phoneNumber": phoneNumber}),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de l\'inscription: $e'};
    }
  }

  /**
   * Demande un code OTP pour la vérification.
   * 
   * @param type Type de demande ('create' pour nouvelle inscription, 'resend' pour renvoi)
   * @param phoneNumber Numéro de téléphone
   * @return Résultat de la demande OTP
   */
  Future<Map<String, dynamic>> requestOtp({required String type, required String phoneNumber}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiHelper.buildUrl(OtpEndpoints.request)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"type": type, "phoneNumber": phoneNumber}),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la demande OTP: $e'};
    }
  }

  /**
   * Vérifie un code OTP.
   * 
   * @param otp Code OTP reçu
   * @param phoneNumber Numéro de téléphone
   * @return Résultat de la vérification
   */
  Future<Map<String, dynamic>> verifyOtp({required String otp, required String phoneNumber}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiHelper.buildUrl(OtpEndpoints.verify)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"otp": otp, "phoneNumber": phoneNumber}),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la vérification OTP: $e'};
    }
  }

  /**
   * Met à jour l'identifiant externe pour les notifications.
   * 
   * @param externalId Identifiant externe (généralement OneSignal player ID)
   * @return Résultat de la mise à jour
   */
  Future<Map<String, dynamic>> updateExternalId(String externalId) async {
    try {
      final response = await postRequest(NotificationEndpoints.externalId, {'externalId': externalId});

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur mise à jour externalId: $e'};
    }
  }

  /**
   * Vérifie si l'utilisateur est connecté.
   * 
   * @return true si l'utilisateur est connecté, false sinon
   */
  bool isLoggedIn() {
    final box = Hive.box(ApiService.authTokenBox);
    return box.get('token') != null;
  }

  /**
   * Déconnecte l'utilisateur en supprimant ses données d'authentification.
   */
  Future<void> logout() async {
    final box = Hive.box(ApiService.authTokenBox);
    await box.clear();
  }
}

// lib/services/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/api.dart';
import 'api_service.dart';

/// Service pour gérer les opérations liées au profil utilisateur
class ProfileService extends ApiService {
  /// Ajoute ou met à jour l'email de l'utilisateur
  Future<Map<String, dynamic>> addEmail({required String email}) async {
    try {
      final response = await postRequest(ProfileEndpoints.addEmail, {'email': email});

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour l'email dans Hive
        final box = Hive.box('auth');
        await box.put('email', responseData['data']['email']);

        return {'success': true, 'message': 'Email ajouté avec succès', 'data': responseData['data']};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors de l\'ajout de l\'email'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  /// Upload d'une photo de profil
  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    try {
      // Vérifier la taille du fichier (5 Mo max)
      final int fileSizeInBytes = await imageFile.length();
      final double fileSizeInMb = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMb > 5) {
        return {'success': false, 'message': 'L\'image ne doit pas dépasser 5 Mo'};
      }

      // Déterminer le type MIME
      final String extension = imageFile.path.split('.').last.toLowerCase();
      String contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        default:
          return {'success': false, 'message': 'Format de fichier non supporté. Utilisez JPG, PNG ou GIF.'};
      }

      // Créer la requête multipart
      var request = http.MultipartRequest('POST', Uri.parse(ApiHelper.buildUrl(ProfileEndpoints.addPicture)));

      // Ajouter les headers
      final token = getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Ajouter le fichier
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path, contentType: MediaType.parse(contentType)));

      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour la photo dans Hive
        final box = Hive.box('auth');
        await box.put('photo', responseData['data']['photoUrl']);

        return {'success': true, 'message': 'Photo de profil mise à jour avec succès', 'data': responseData['data']};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors de l\'upload'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de l\'upload: ${e.toString()}'};
    }
  }

  /// Récupère les informations du profil utilisateur
  Future<Map<String, dynamic>> getProfileInfo() async {
    try {
      final box = Hive.box('auth');

      return {
        'success': true,
        'data': {
          'userId': box.get('userId'),
          'fullName': box.get('fullName', defaultValue: ''),
          'phoneNumber': box.get('phoneNumber', defaultValue: ''),
          'email': box.get('email', defaultValue: ''),
          'photo': box.get('photo'),
          'role': box.get('role', defaultValue: ''),
          'isActive': box.get('isActive', defaultValue: false),
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la récupération du profil: ${e.toString()}'};
    }
  }

  /// Met à jour les informations du profil dans Hive
  Future<Map<String, dynamic>> updateLocalProfileInfo(Map<String, dynamic> profileData) async {
    try {
      final box = Hive.box('auth');

      if (profileData.containsKey('fullName')) {
        await box.put('fullName', profileData['fullName']);
      }

      if (profileData.containsKey('email')) {
        await box.put('email', profileData['email']);
      }

      if (profileData.containsKey('photo')) {
        await box.put('photo', profileData['photo']);
      }

      return {'success': true, 'message': 'Profil mis à jour localement'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la mise à jour locale: ${e.toString()}'};
    }
  }

  /// Formate le numéro de téléphone pour l'affichage
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';

    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Retirer le préfixe 225 si présent
    if (cleanNumber.startsWith('225')) {
      cleanNumber = cleanNumber.substring(3);
    }

    // Vérifier que le numéro a 10 chiffres
    if (cleanNumber.length != 10) {
      return phoneNumber; // Retourner le numéro original si pas le bon format
    }

    // Formater le numéro : +225 XX XX XX XX XX
    String formattedNumber = '+225 ${cleanNumber.replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)} ').trim()}';

    return formattedNumber;
  }

  /// Obtient l'URL complète de la photo de profil
  String? getFullPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;

    // Si c'est déjà une URL complète, la retourner
    if (photoPath.startsWith('http')) {
      return photoPath;
    }

    // Sinon, construire l'URL complète
    return '${ApiConfig.baseUrl}/$photoPath';
  }

  /// Obtient les initiales du nom pour l'avatar par défaut
  String getUserInitials(String fullName) {
    if (fullName.isEmpty) return '?';

    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return fullName[0].toUpperCase();
    }
  }

  /// Valide une adresse email
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Valide un fichier image
  Map<String, dynamic> validateImageFile(File imageFile) {
    try {
      // Vérifier l'extension
      final String extension = imageFile.path.split('.').last.toLowerCase();
      final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];

      if (!allowedExtensions.contains(extension)) {
        return {'isValid': false, 'message': 'Format non supporté. Utilisez JPG, PNG ou GIF.'};
      }

      // La vérification de la taille sera faite dans uploadProfilePicture
      return {'isValid': true, 'message': 'Fichier valide'};
    } catch (e) {
      return {'isValid': false, 'message': 'Erreur lors de la validation du fichier'};
    }
  }
}

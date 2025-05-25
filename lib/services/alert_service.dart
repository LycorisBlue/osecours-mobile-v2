// lib/services/alert_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'location_service.dart';

/// Types d'alertes disponibles
enum AlertType {
  accidents('Accidents'),
  incendies('Incendies'),
  inondations('Inondations'),
  malaises('Malaises'),
  noyade('Noyade'),
  autre('Autre');

  const AlertType(this.label);
  final String label;
}

/// Statuts d'alertes
enum AlertStatus {
  enAttente('EN_ATTENTE', 'En attente'),
  acceptee('ACCEPTEE', 'Acceptée'),
  enCours('EN_COURS', 'En cours'),
  resolue('RESOLUE', 'Résolue');

  const AlertStatus(this.value, this.label);
  final String value;
  final String label;

  static AlertStatus fromString(String status) {
    return AlertStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => AlertStatus.enAttente,
    );
  }
}

/// Modèle pour un fichier média
class MediaFile {
  final File file;
  final bool isVideo;
  final String mimeType;

  MediaFile({
    required this.file,
    this.isVideo = false,
    required this.mimeType,
  });

  /// Formats d'images acceptés
  static const List<String> acceptedImageFormats = ['jpg', 'jpeg', 'png'];
  
  /// Formats de vidéos acceptés
  static const List<String> acceptedVideoFormats = ['mp4', 'mov'];

  /// Vérifie si le format est accepté
  static bool isFormatAccepted(String extension, bool isVideo) {
    final ext = extension.toLowerCase();
    return isVideo 
        ? acceptedVideoFormats.contains(ext)
        : acceptedImageFormats.contains(ext);
  }

  /// Obtient le type MIME approprié
  static String getMimeType(String extension, bool isVideo) {
    final ext = extension.toLowerCase();
    if (isVideo) {
      return 'video/$ext';
    } else {
      return ext == 'jpg' ? 'image/jpeg' : 'image/$ext';
    }
  }
}

/// Service pour la gestion des alertes
class AlertService {
  static const String baseUrl = 'http://46.202.170.228:3000';
  final ImagePicker _picker = ImagePicker();

  /// Récupère le token d'authentification
  String? _getToken() {
    final box = Hive.box('auth');
    return box.get('token');
  }

  /// Crée une nouvelle alerte
  Future<Map<String, dynamic>> createAlert({
    required AlertType alertType,
    required String description,
    required List<MediaFile> mediaFiles,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Validation des médias
      if (mediaFiles.isEmpty) {
        throw Exception('Au moins une photo ou vidéo est requise');
      }

      // Obtenir la position si non fournie
      if (latitude == null || longitude == null) {
        final position = await LocationService.getCurrentPosition();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
        }
      }

      // Obtenir l'adresse
      String address = 'Adresse inconnue';
      if (latitude != null && longitude != null) {
        address = await LocationService.getAddressFromCoordinates(latitude, longitude);
      }

      // Préparer la requête multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/citizen/create-alert'),
      );

      // Headers
      final token = _getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Champs de données
      request.fields.addAll({
        'location_lat': latitude?.toString() ?? '0',
        'location_lng': longitude?.toString() ?? '0',
        'description': description.isEmpty ? 'Aucune description soumise' : description,
        'category': alertType.label,
        'address': address,
      });

      // Ajouter les fichiers médias
      for (int i = 0; i < mediaFiles.length; i++) {
        final media = mediaFiles[i];
        request.files.add(await http.MultipartFile.fromPath(
          'files${i + 1}',
          media.file.path,
          contentType: http_parser.MediaType.parse(media.mimeType),
        ));
      }

      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Alerte envoyée avec succès',
          'data': responseData,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Erreur lors de l\'envoi de l\'alerte');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Récupère la dernière alerte de l'utilisateur
  Future<Map<String, dynamic>> getLatestAlert() async {
    try {
      final token = _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/citizen/latest-alert'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Erreur lors de la récupération');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  /// Récupère toutes les alertes de l'utilisateur
  Future<Map<String, dynamic>> getAllAlerts() async {
    try {
      final token = _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/citizen/all-alerts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'] ?? [],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Erreur lors de la récupération');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': [],
      };
    }
  }

  /// Récupère les détails d'une alerte spécifique
  Future<Map<String, dynamic>> getAlertDetails(String alertId) async {
    try {
      final token = _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/citizen/get-alert-details/$alertId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Erreur lors de la récupération');
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Prend une photo avec la caméra
  Future<MediaFile?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        final extension = photo.path.split('.').last.toLowerCase();
        
        if (!MediaFile.isFormatAccepted(extension, false)) {
          throw Exception('Format non supporté. Formats acceptés : JPG, JPEG, PNG');
        }

        return MediaFile(
          file: File(photo.path),
          isVideo: false,
          mimeType: MediaFile.getMimeType(extension, false),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Impossible de prendre une photo: $e');
    }
  }

  /// Enregistre une vidéo avec la caméra
  Future<MediaFile?> recordVideo({Duration maxDuration = const Duration(seconds: 10)}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: maxDuration,
      );

      if (video != null) {
        final extension = video.path.split('.').last.toLowerCase();
        
        if (!MediaFile.isFormatAccepted(extension, true)) {
          throw Exception('Format non supporté. Formats acceptés : MP4, MOV');
        }

        return MediaFile(
          file: File(video.path),
          isVideo: true,
          mimeType: MediaFile.getMimeType(extension, true),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Impossible d\'enregistrer une vidéo: $e');
    }
  }

  /// Sélectionne un média depuis la galerie
  Future<MediaFile?> pickFromGallery({bool isVideo = false}) async {
    try {
      if (isVideo) {
        final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          final extension = video.path.split('.').last.toLowerCase();
          return MediaFile(
            file: File(video.path),
            isVideo: true,
            mimeType: MediaFile.getMimeType(extension, true),
          );
        }
      } else {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final extension = image.path.split('.').last.toLowerCase();
          return MediaFile(
            file: File(image.path),
            isVideo: false,
            mimeType: MediaFile.getMimeType(extension, false),
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Impossible de sélectionner le média: $e');
    }
  }
}
// lib/models/alert_models.dart
import '../../core/constants/alert_enums.dart';
import 'media_models.dart';

/// Modèle pour représenter une alerte complète
class Alert {
  final String id;
  final String description;
  final AlertType type;
  final AlertStatus status;
  final AlertLocation location;
  final List<AlertMedia> media;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final AlertIntervention? intervention;

  const Alert({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
    required this.location,
    required this.media,
    required this.createdAt,
    this.updatedAt,
    this.intervention,
  });

  /// Crée une Alert depuis une réponse JSON de l'API
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? '',
      type: AlertTypeExtension.fromString(json['category'] ?? 'Autre'),
      status: AlertStatusExtension.fromString(json['status'] ?? 'EN_ATTENTE'),
      location: AlertLocation.fromJson(json['location'] ?? {}),
      media: (json['media'] as List<dynamic>?)?.map((item) => AlertMedia.fromJson(item as Map<String, dynamic>)).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      intervention:
          json['intervention'] != null ? AlertIntervention.fromJson(json['intervention'] as Map<String, dynamic>) : null,
    );
  }

  /// Convertit l'Alert en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'category': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'location': location.toJson(),
      'media': media.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'intervention': intervention?.toJson(),
    };
  }

  /// Crée une copie de l'Alert avec des propriétés modifiées
  Alert copyWith({
    String? id,
    String? description,
    AlertType? type,
    AlertStatus? status,
    AlertLocation? location,
    List<AlertMedia>? media,
    DateTime? createdAt,
    DateTime? updatedAt,
    AlertIntervention? intervention,
  }) {
    return Alert(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      intervention: intervention ?? this.intervention,
    );
  }
}

/// Modèle pour créer une nouvelle alerte (requête vers l'API)
class AlertRequest {
  final String description;
  final AlertType type;
  final AlertLocation location;
  final List<MediaFile> mediaFiles;

  const AlertRequest({required this.description, required this.type, required this.location, required this.mediaFiles});

  /// Convertit la requête en format pour l'API
  Map<String, dynamic> toApiRequest() {
    return {
      'description': description.isEmpty ? 'Aucune description soumise' : description,
      'category': type.label,
      'location_lat': location.latitude.toString(),
      'location_lng': location.longitude.toString(),
      'address': location.address,
    };
  }

  /// Valide la requête d'alerte
  List<String> validate() {
    final errors = <String>[];

    if (description.length > 500) {
      errors.add('La description ne peut pas dépasser 500 caractères');
    }

    if (mediaFiles.isEmpty) {
      errors.add('Au moins un média (photo ou vidéo) est requis');
    }

    if (mediaFiles.length > 3) {
      errors.add('Maximum 3 médias autorisés');
    }

    final videoCount = mediaFiles.where((media) => media.isVideo).length;
    if (videoCount > 1) {
      errors.add('Maximum 1 vidéo autorisée');
    }

    return errors;
  }

  /// Vérifie si la requête est valide
  bool get isValid => validate().isEmpty;
}

/// Modèle pour la localisation d'une alerte
class AlertLocation {
  final double latitude;
  final double longitude;
  final String address;

  const AlertLocation({required this.latitude, required this.longitude, required this.address});

  /// Crée une AlertLocation depuis JSON
  factory AlertLocation.fromJson(Map<String, dynamic> json) {
    return AlertLocation(
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
      address: json['address'] ?? 'Adresse inconnue',
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {'lat': latitude, 'lng': longitude, 'address': address};
  }

  /// Vérifie si les coordonnées sont valides
  bool get isValid {
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }
}

/// Modèle pour les médias d'une alerte (réponse API)
class AlertMedia {
  final String id;
  final String url;
  final String type;
  final String? fileName;
  final int? fileSize;

  const AlertMedia({required this.id, required this.url, required this.type, this.fileName, this.fileSize});

  /// Crée un AlertMedia depuis JSON
  factory AlertMedia.fromJson(Map<String, dynamic> json) {
    return AlertMedia(
      id: json['id']?.toString() ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'IMAGE',
      fileName: json['fileName'],
      fileSize: json['fileSize'],
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'type': type, 'fileName': fileName, 'fileSize': fileSize};
  }

  /// Vérifie si c'est une vidéo
  bool get isVideo => type.toUpperCase() == 'VIDEO';

  /// Obtient l'URL complète du média
  String getFullUrl(String baseUrl) {
    if (url.startsWith('http')) {
      return url;
    }
    return '$baseUrl/$url';
  }
}

/// Modèle pour l'intervention sur une alerte
class AlertIntervention {
  final String id;
  final String status;
  final DateTime? arrivalTime;
  final RescueMember rescueMember;

  const AlertIntervention({required this.id, required this.status, this.arrivalTime, required this.rescueMember});

  /// Crée une AlertIntervention depuis JSON
  factory AlertIntervention.fromJson(Map<String, dynamic> json) {
    return AlertIntervention(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? 'EN_COURS',
      arrivalTime: json['arrivalTime'] != null ? DateTime.parse(json['arrivalTime']) : null,
      rescueMember: RescueMember.fromJson(json['rescueMember'] ?? {}),
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'status': status, 'arrivalTime': arrivalTime?.toIso8601String(), 'rescueMember': rescueMember.toJson()};
  }

  /// Formate le statut d'intervention
  String get formattedStatus {
    switch (status.toUpperCase()) {
      case 'EN_COURS':
        return 'En cours';
      case 'TERMINEE':
        return 'Terminée';
      default:
        return status;
    }
  }
}

/// Modèle pour un membre des secours
class RescueMember {
  final String id;
  final String firstName;
  final String lastName;
  final String position;

  const RescueMember({required this.id, required this.firstName, required this.lastName, required this.position});

  /// Crée un RescueMember depuis JSON
  factory RescueMember.fromJson(Map<String, dynamic> json) {
    return RescueMember(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      position: json['position'] ?? '',
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'firstName': firstName, 'lastName': lastName, 'position': position};
  }

  /// Obtient le nom complet
  String get fullName => '$firstName $lastName';
}

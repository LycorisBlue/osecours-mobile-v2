// lib/data/models/flood_alert_models.dart
import 'package:flutter/material.dart';

/// Modèle pour les coordonnées géographiques d'une alerte d'inondation
class FloodLocation {
  final double lat;
  final double lng;

  const FloodLocation({required this.lat, required this.lng});

  /// Crée depuis JSON (API)
  factory FloodLocation.fromJson(Map<String, dynamic> json) {
    return FloodLocation(lat: (json['lat'] as num?)?.toDouble() ?? 0.0, lng: (json['lng'] as num?)?.toDouble() ?? 0.0);
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }
}

/// Modèle principal pour une alerte d'inondation
class FloodAlert {
  final String id;
  final String address;
  final String description;
  final String warningMessage;
  final String status;
  final FloodLocation location;
  final double distance;
  final DateTime createdAt;

  const FloodAlert({
    required this.id,
    required this.address,
    required this.description,
    required this.warningMessage,
    required this.status,
    required this.location,
    required this.distance,
    required this.createdAt,
  });

  /// Crée depuis JSON (API)
  factory FloodAlert.fromJson(Map<String, dynamic> json) {
    return FloodAlert(
      id: json['id']?.toString() ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      warningMessage: json['warningMessage'] ?? json['warning_message'] ?? '',
      status: json['status'] ?? 'ACCEPTEE',
      location: FloodLocation.fromJson(json['location'] ?? {}),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Obtient la couleur du statut
  Color getStatusColor() {
    switch (status.toUpperCase()) {
      case 'ACCEPTEE':
        return Colors.blue;
      case 'EN_COURS':
        return Colors.orange;
      case 'RESOLUE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Obtient le texte du statut
  String getStatusText() {
    switch (status.toUpperCase()) {
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'EN_COURS':
        return 'En cours';
      case 'RESOLUE':
        return 'Résolue';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'FloodAlert{id: $id, address: $address, status: $status}';
  }
}

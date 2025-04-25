// lib/core/data/emergency_data.dart

import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/icons.dart';

/// Modèle pour représenter un numéro d'urgence
class EmergencyNumber {
  final String title; // Nom du service d'urgence
  final String number; // Numéro de téléphone à appeler
  final String iconName; // Nom de l'icône dans IconManager
  final Color color; // Couleur associée au service

  const EmergencyNumber({required this.title, required this.number, required this.iconName, required this.color});

  /// Obtient l'icône appropriée en utilisant l'IconManager
  Icon getIcon({double? size}) {
    return IconManager.getIcon(iconName, color: color, size: size);
  }

  /// Obtient les données de l'icône
  IconData getIconData() {
    return IconManager.getIconData(iconName);
  }
}

/// Liste des numéros d'urgence disponibles dans l'application
class EmergencyData {
  /// Liste constante des numéros d'urgence
  static const List<EmergencyNumber> emergencyNumbers = [
    EmergencyNumber(
      title: "Groupement Sapeurs Pompiers Militaires",
      number: "180",
      iconName: "fire_truck",
      color: AppColors.primary,
    ),
    EmergencyNumber(title: "Police Nationale", number: "100", iconName: "local_police", color: Colors.blue),
    EmergencyNumber(
      title: "SAMU (Service d'aide médicale d'urgences)",
      number: "110",
      iconName: "medical_services",
      color: AppColors.primary,
    ),
  ];
}

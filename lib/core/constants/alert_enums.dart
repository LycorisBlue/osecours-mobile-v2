// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum AlertStatus { EN_ATTENTE, ACCEPTEE, EN_COURS, RESOLUE }

enum AlertType { Accidents, Incendies, Inondations, Malaises, Noyade, Autre }

extension AlertStatusExtension on AlertStatus {
  String get label {
    switch (this) {
      case AlertStatus.EN_ATTENTE:
        return 'En attente';
      case AlertStatus.ACCEPTEE:
        return 'Acceptée';
      case AlertStatus.EN_COURS:
        return 'En cours';
      case AlertStatus.RESOLUE:
        return 'Résolue';
    }
  }

  Color get color {
    switch (this) {
      case AlertStatus.EN_ATTENTE:
        return Colors.orange;
      case AlertStatus.ACCEPTEE:
        return Colors.blue;
      case AlertStatus.EN_COURS:
        return Colors.green;
      case AlertStatus.RESOLUE:
        return Colors.grey;
    }
  }

  static AlertStatus fromString(String status) {
    return AlertStatus.values.firstWhere((e) => e.toString().split('.').last == status, orElse: () => AlertStatus.EN_ATTENTE);
  }
}

extension AlertTypeExtension on AlertType {
  String get label {
    switch (this) {
      case AlertType.Accidents:
        return 'Accident';
      case AlertType.Incendies:
        return 'Incendie';
      case AlertType.Inondations:
        return 'Inondation';
      case AlertType.Malaises:
        return 'Malaise';
      case AlertType.Noyade:
        return 'Noyade';
      case AlertType.Autre:
        return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.Accidents:
        return Icons.car_crash;
      case AlertType.Incendies:
        return Icons.local_fire_department;
      case AlertType.Inondations:
        return Icons.water_damage;
      case AlertType.Malaises:
        return Icons.medical_services;
      case AlertType.Noyade:
        return Icons.pool;
      case AlertType.Autre:
        return Icons.warning;
    }
  }

  Color get color {
    switch (this) {
      case AlertType.Accidents:
        return Colors.red;
      case AlertType.Incendies:
        return Colors.orange;
      case AlertType.Inondations:
        return Colors.blue;
      case AlertType.Malaises:
        return Colors.purple;
      case AlertType.Noyade:
        return Colors.blue[700]!;
      case AlertType.Autre:
        return Colors.grey;
    }
  }

  static AlertType fromString(String type) {
    return AlertType.values.firstWhere((e) => e.toString().split('.').last == type, orElse: () => AlertType.Autre);
  }
}

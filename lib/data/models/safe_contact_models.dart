// lib/data/models/safe_contact_models.dart
import 'package:flutter/material.dart';

/// Énumération des catégories de contacts avec couleurs et icônes
enum ContactCategory {
  famille('Famille', Colors.pink, Icons.family_restroom),
  amis('Amis', Colors.blue, Icons.group),
  travail('Travail', Colors.orange, Icons.work),
  autre('Autre', Colors.grey, Icons.person);

  const ContactCategory(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;

  /// Crée une catégorie depuis une chaîne
  static ContactCategory fromString(String category) {
    return ContactCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == category.toLowerCase(),
      orElse: () => ContactCategory.autre,
    );
  }

  /// Obtient la couleur avec opacité pour les fonds
  Color get lightColor => color.withOpacity(0.1);

  /// Obtient la couleur avec opacité pour les bordures
  Color get borderColor => color.withOpacity(0.3);
}

/// Modèle pour un contact de sécurité
class SafeContact {
  final String id;
  final String number;
  final String description;
  final ContactCategory category;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SafeContact({
    required this.id,
    required this.number,
    required this.description,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crée un SafeContact depuis JSON (API)
  factory SafeContact.fromJson(Map<String, dynamic> json) {
    return SafeContact(
      id: json['id']?.toString() ?? '',
      number: json['number'] ?? '',
      description: json['description'] ?? '',
      category: ContactCategory.fromString(json['category'] ?? 'autre'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Crée un SafeContact depuis les données Hive (avec catégorie locale)
  factory SafeContact.fromHive(Map<String, dynamic> hiveData) {
    return SafeContact(
      id: hiveData['id']?.toString() ?? '',
      number: hiveData['number'] ?? '',
      description: hiveData['description'] ?? '',
      category: ContactCategory.fromString(hiveData['localCategory'] ?? 'autre'),
      createdAt: DateTime.parse(hiveData['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: hiveData['updatedAt'] != null ? DateTime.parse(hiveData['updatedAt']) : null,
    );
  }

  /// Convertit en JSON pour l'API (sans la catégorie locale)
  Map<String, dynamic> toApiJson() {
    return {'number': cleanNumber, 'description': description};
  }

  /// Convertit en Map pour Hive (avec catégorie locale)
  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'number': number,
      'description': description,
      'localCategory': category.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Obtient le numéro nettoyé (sans espaces et caractères spéciaux)
  String get cleanNumber {
    return number.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Formate le numéro pour l'affichage
  String get formattedNumber {
    String clean = cleanNumber;

    // Retirer le préfixe 225 si présent
    if (clean.startsWith('225')) {
      clean = clean.substring(3);
    }

    // Vérifier que le numéro a 10 chiffres
    if (clean.length != 10) {
      return number; // Retourner le numéro original si pas le bon format
    }

    // Formater : +225 XX XX XX XX XX
    return '+225 ${clean.replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)} ').trim()}';
  }

  /// Obtient les initiales pour l'avatar
  String get initials {
    if (description.isEmpty) return '?';

    final parts = description.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return description[0].toUpperCase();
    }
  }

  /// Valide le contact
  List<String> validate() {
    final errors = <String>[];

    if (description.trim().isEmpty) {
      errors.add('Le nom du contact est requis');
    }

    if (description.trim().length < 2) {
      errors.add('Le nom doit contenir au moins 2 caractères');
    }

    if (cleanNumber.length != 10) {
      errors.add('Le numéro doit contenir exactement 10 chiffres');
    }

    if (!RegExp(r'^(01|05|07)').hasMatch(cleanNumber)) {
      errors.add('Le numéro doit commencer par 01, 05 ou 07');
    }

    return errors;
  }

  /// Vérifie si le contact est valide
  bool get isValid => validate().isEmpty;

  /// Crée une copie avec des propriétés modifiées
  SafeContact copyWith({
    String? id,
    String? number,
    String? description,
    ContactCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SafeContact(
      id: id ?? this.id,
      number: number ?? this.number,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SafeContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SafeContact{id: $id, description: $description, number: $formattedNumber, category: ${category.label}}';
  }
}

/// Modèle pour la requête d'ajout de contacts
class SafeContactRequest {
  final List<SafeContactData> safeNumbers;

  const SafeContactRequest({required this.safeNumbers});

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {'safeNumbers': safeNumbers.map((contact) => contact.toJson()).toList()};
  }

  /// Valide la requête
  List<String> validate() {
    final errors = <String>[];

    if (safeNumbers.isEmpty) {
      errors.add('Au moins un contact est requis');
    }

    if (safeNumbers.length > 5) {
      errors.add('Maximum 5 contacts autorisés');
    }

    // Vérifier les doublons
    final numbers = safeNumbers.map((c) => c.cleanNumber).toList();
    final uniqueNumbers = numbers.toSet();
    if (numbers.length != uniqueNumbers.length) {
      errors.add('Numéros en double détectés');
    }

    // Valider chaque contact
    for (final contact in safeNumbers) {
      errors.addAll(contact.validate());
    }

    return errors;
  }

  /// Vérifie si la requête est valide
  bool get isValid => validate().isEmpty;
}

/// Données pour un nouveau contact de sécurité
class SafeContactData {
  final String number;
  final String description;

  const SafeContactData({required this.number, required this.description});

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {'number': cleanNumber, 'description': description};
  }

  /// Obtient le numéro nettoyé
  String get cleanNumber {
    return number.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Valide les données
  List<String> validate() {
    final errors = <String>[];

    if (description.trim().isEmpty) {
      errors.add('Le nom du contact est requis');
    }

    if (cleanNumber.length != 10) {
      errors.add('Le numéro doit contenir exactement 10 chiffres');
    }

    if (!RegExp(r'^(01|05|07)').hasMatch(cleanNumber)) {
      errors.add('Le numéro doit commencer par 01, 05 ou 07');
    }

    return errors;
  }

  /// Vérifie si les données sont valides
  bool get isValid => validate().isEmpty;
}

/// Configuration du partage de localisation
class LocationSharingConfig {
  final bool isEnabled;
  final LocationSharingMode mode;
  final DateTime? lastUpdated;

  const LocationSharingConfig({required this.isEnabled, required this.mode, this.lastUpdated});

  /// Crée depuis JSON
  factory LocationSharingConfig.fromJson(Map<String, dynamic> json) {
    return LocationSharingConfig(
      isEnabled: json['isEnabled'] ?? false,
      mode: LocationSharingMode.fromString(json['mode'] ?? 'emergency'),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {'isEnabled': isEnabled, 'mode': mode.name, 'lastUpdated': lastUpdated?.toIso8601String()};
  }

  /// Configuration par défaut
  static const LocationSharingConfig defaultConfig = LocationSharingConfig(isEnabled: false, mode: LocationSharingMode.emergency);
}

/// Modes de partage de localisation
enum LocationSharingMode {
  always('Toujours', 'Partager la localisation en permanence'),
  emergency('Urgence uniquement', 'Partager uniquement lors d\'une alerte');

  const LocationSharingMode(this.label, this.description);

  final String label;
  final String description;

  /// Crée depuis une chaîne
  static LocationSharingMode fromString(String mode) {
    return LocationSharingMode.values.firstWhere(
      (e) => e.name.toLowerCase() == mode.toLowerCase(),
      orElse: () => LocationSharingMode.emergency,
    );
  }
}

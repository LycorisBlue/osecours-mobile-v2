// lib/data/models/notification_models.dart
import 'package:flutter/material.dart';

/// Types de notifications avec leurs configurations visuelles
enum NotificationType {
  admin('ADMIN', 'Administrateur', Icons.admin_panel_settings, Colors.blue),
  rescueMember('RESCUE_MEMBER', 'Secouriste', Icons.local_hospital, Color(0xFFFF3333)),
  system('SYSTEM', 'Système', Icons.settings, Colors.grey),
  alert('ALERT', 'Alerte', Icons.warning, Colors.orange);

  const NotificationType(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  /// Crée un type depuis une chaîne
  static NotificationType fromString(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.value.toUpperCase() == type.toUpperCase(),
      orElse: () => NotificationType.system,
    );
  }

  /// Obtient la couleur avec opacité pour les fonds
  Color get lightColor => color.withOpacity(0.1);

  /// Obtient la couleur avec opacité pour les bordures
  Color get borderColor => color.withOpacity(0.3);
}

/// Modèle pour l'expéditeur d'une notification
class NotificationSender {
  final String id;
  final String firstName;
  final String lastName;
  final String role;

  const NotificationSender({required this.id, required this.firstName, required this.lastName, required this.role});

  /// Crée depuis JSON (API)
  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      role: json['role'] ?? 'SYSTEM',
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'first_name': firstName, 'last_name': lastName, 'role': role};
  }

  /// Convertit pour Hive
  Map<String, dynamic> toHiveMap() {
    return {'id': id, 'firstName': firstName, 'lastName': lastName, 'role': role};
  }

  /// Crée depuis Hive
  factory NotificationSender.fromHive(Map<String, dynamic> hiveData) {
    return NotificationSender(
      id: hiveData['id']?.toString() ?? '',
      firstName: hiveData['firstName'] ?? '',
      lastName: hiveData['lastName'] ?? '',
      role: hiveData['role'] ?? 'SYSTEM',
    );
  }

  /// Nom complet
  String get fullName => '$firstName $lastName'.trim();

  /// Initiales pour l'avatar
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Type de notification basé sur le rôle
  NotificationType get notificationType => NotificationType.fromString(role);
}

/// Modèle principal pour une notification
class AppNotification {
  final String id;
  final String message;
  final NotificationSender sender;
  final DateTime createdAt;
  final bool isRead;
  final String? alertId;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.message,
    required this.sender,
    required this.createdAt,
    this.isRead = false,
    this.alertId,
    this.metadata,
  });

  /// Crée depuis JSON (API)
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      message: json['message'] ?? '',
      sender: NotificationSender.fromJson(json['sender'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      alertId: json['alert_id']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'is_read': isRead,
      'alert_id': alertId,
      'metadata': metadata,
    };
  }

  /// Convertit pour Hive
  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'message': message,
      'sender': sender.toHiveMap(),
      'createdAt': createdAt.toIso8601String(),
      'is_read': isRead,
      'alert_id': alertId,
      'metadata': metadata,
    };
  }

  /// Crée depuis Hive
  factory AppNotification.fromHive(Map<String, dynamic> hiveData) {
    return AppNotification(
      id: hiveData['id']?.toString() ?? '',
      message: hiveData['message'] ?? '',
      sender: NotificationSender.fromHive(hiveData['sender'] ?? {}),
      createdAt: DateTime.parse(hiveData['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: hiveData['is_read'] ?? false,
      alertId: hiveData['alert_id']?.toString(),
      metadata: hiveData['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Type de notification basé sur l'expéditeur
  NotificationType get type => sender.notificationType;

  /// Message tronqué pour l'aperçu
  String get previewMessage {
    if (message.length <= 40) return message;
    return '${message.substring(0, 40)}...';
  }

  /// Vérifie si la notification est liée à une alerte
  bool get hasAlert => alertId != null && alertId!.isNotEmpty;

  /// Crée une copie avec des propriétés modifiées
  AppNotification copyWith({
    String? id,
    String? message,
    NotificationSender? sender,
    DateTime? createdAt,
    bool? isRead,
    String? alertId,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      alertId: alertId ?? this.alertId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Marque comme lue
  AppNotification markAsRead() {
    return copyWith(isRead: true);
  }

  /// Marque comme non lue
  AppNotification markAsUnread() {
    return copyWith(isRead: false);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppNotification{id: $id, message: ${message.substring(0, message.length > 20 ? 20 : message.length)}, sender: ${sender.fullName}, isRead: $isRead}';
  }
}

/// Modèle pour les statistiques de notifications
class NotificationStats {
  final int total;
  final int unread;
  final Map<NotificationType, int> byType;

  const NotificationStats({required this.total, required this.unread, required this.byType});

  /// Crée depuis une liste de notifications
  factory NotificationStats.fromNotifications(List<AppNotification> notifications) {
    final byType = <NotificationType, int>{};
    int unreadCount = 0;

    for (final notification in notifications) {
      // Compter par type
      byType[notification.type] = (byType[notification.type] ?? 0) + 1;

      // Compter les non lues
      if (!notification.isRead) {
        unreadCount++;
      }
    }

    return NotificationStats(total: notifications.length, unread: unreadCount, byType: byType);
  }

  /// Vérifie s'il y a des notifications non lues
  bool get hasUnread => unread > 0;

  /// Obtient le pourcentage de notifications lues
  double get readPercentage {
    if (total == 0) return 0.0;
    return (total - unread) / total;
  }
}

/// Exception personnalisée pour les notifications
class NotificationException implements Exception {
  final String message;
  final NotificationErrorType type;

  const NotificationException(this.message, this.type);

  @override
  String toString() => 'NotificationException: $message';
}

/// Types d'erreurs pour les notifications
enum NotificationErrorType { networkError, cacheError, validationError, unknownError }

extension NotificationErrorTypeExtension on NotificationErrorType {
  String get message {
    switch (this) {
      case NotificationErrorType.networkError:
        return 'Erreur de connexion réseau';
      case NotificationErrorType.cacheError:
        return 'Erreur de cache local';
      case NotificationErrorType.validationError:
        return 'Données de notification invalides';
      case NotificationErrorType.unknownError:
        return 'Erreur inconnue';
    }
  }
}

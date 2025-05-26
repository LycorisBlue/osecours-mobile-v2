// lib/services/notification_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/api.dart';
import '../data/models/notification_models.dart';
import 'api_service.dart';

/// Service complet pour la gestion des notifications
class NotificationService extends ApiService {
  static const String _hiveBoxKey = 'notifications';
  static const String _statsBoxKey = 'notificationStats';

  /// Récupère les notifications non lues depuis le serveur
  Future<Map<String, dynamic>> getUnreadNotifications() async {
    try {
      final response = await getRequest(NotificationEndpoints.unread);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final notificationsData = responseData['data'] as List<dynamic>? ?? [];

        // Convertir en objets AppNotification et sauvegarder dans le cache
        final notifications = notificationsData.map((json) => AppNotification.fromJson(json as Map<String, dynamic>)).toList();

        await _updateLocalCache(notifications);

        return {'success': true, 'data': notificationsData, 'message': 'Notifications récupérées avec succès'};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de la récupération des notifications',
          'data': <Map<String, dynamic>>[],
        };
      }
    } catch (e) {
      // En cas d'erreur réseau, retourner les données du cache local
      final cachedNotifications = await getLocalNotifications();
      return {
        'success': false,
        'message': 'Erreur réseau: ${e.toString()}',
        'data': cachedNotifications.map((n) => n.toJson()).toList(),
        'isOffline': true,
      };
    }
  }

  /// Récupère toutes les notifications (avec pagination)
  Future<Map<String, dynamic>> getAllNotifications({int page = 1, int limit = 20}) async {
    try {
      final queryParams = '?page=$page&limit=$limit';
      final response = await getRequest('${NotificationEndpoints.unread}$queryParams');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final notificationsData = responseData['data'] as List<dynamic>? ?? [];
        final totalCount = responseData['total'] ?? notificationsData.length;

        return {
          'success': true,
          'data': notificationsData,
          'total': totalCount,
          'page': page,
          'hasMore': (page * limit) < totalCount,
          'message': 'Notifications récupérées avec succès',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de la récupération',
          'data': <Map<String, dynamic>>[],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la récupération: ${e.toString()}', 'data': <Map<String, dynamic>>[]};
    }
  }

  /// Marque une notification comme lue
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await postRequest(NotificationEndpoints.read, {'notification_id': notificationId});

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour le cache local
        await _markLocalNotificationAsRead(notificationId);

        return {'success': true, 'message': 'Notification marquée comme lue'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors du marquage'};
      }
    } catch (e) {
      // Marquer localement même en cas d'erreur réseau
      await _markLocalNotificationAsRead(notificationId);

      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}', 'markedLocally': true};
    }
  }

  /// Marque toutes les notifications comme lues
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await postRequest(NotificationEndpoints.readAll, {});
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour le cache local
        await _markAllLocalNotificationsAsRead();

        return {'success': true, 'message': 'Toutes les notifications ont été marquées comme lues'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors du marquage'};
      }
    } catch (e) {
      // Marquer localement même en cas d'erreur réseau
      await _markAllLocalNotificationsAsRead();

      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}', 'markedLocally': true};
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await getRequest(NotificationEndpoints.count);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final count = responseData['count'] ?? 0;

        return {'success': true, 'count': count, 'message': 'Nombre de notifications récupéré'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors de la récupération du compteur', 'count': 0};
      }
    } catch (e) {
      // Retourner le compte local en cas d'erreur
      final localCount = await getLocalUnreadCount();
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}', 'count': localCount, 'isOffline': true};
    }
  }

  /// Récupère les notifications depuis le cache local
  Future<List<AppNotification>> getLocalNotifications() async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      final notificationsData =
          box.values.map((item) => AppNotification.fromHive(Map<String, dynamic>.from(item as Map))).toList();

      // Trier par date (plus récentes en premier)
      notificationsData.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notificationsData;
    } catch (e) {
      return <AppNotification>[];
    }
  }

  /// Récupère le nombre de notifications non lues localement
  Future<int> getLocalUnreadCount() async {
    try {
      final notifications = await getLocalNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }

  /// Obtient les statistiques locales des notifications
  Future<NotificationStats> getLocalStats() async {
    try {
      final notifications = await getLocalNotifications();
      return NotificationStats.fromNotifications(notifications);
    } catch (e) {
      return const NotificationStats(total: 0, unread: 0, byType: {});
    }
  }

  /// Met à jour le cache local avec les nouvelles notifications
  Future<void> _updateLocalCache(List<AppNotification> notifications) async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);

      // Récupérer les notifications existantes pour préserver les états "lu"
      final existingNotifications = await getLocalNotifications();
      final existingMap = {for (var n in existingNotifications) n.id: n};

      // Fusionner les nouvelles notifications avec les états existants
      final mergedNotifications =
          notifications.map((newNotification) {
            final existing = existingMap[newNotification.id];
            if (existing != null) {
              // Préserver l'état "lu" local
              return newNotification.copyWith(isRead: existing.isRead);
            }
            return newNotification;
          }).toList();

      // Sauvegarder dans Hive
      await box.clear();
      for (final notification in mergedNotifications) {
        await box.put(notification.id, notification.toHiveMap());
      }

      // Mettre à jour les statistiques
      await _updateLocalStats(mergedNotifications);
    } catch (e) {
      print('Erreur lors de la mise à jour du cache: $e');
    }
  }

  /// Marque une notification locale comme lue
  Future<void> _markLocalNotificationAsRead(String notificationId) async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      final notificationData = box.get(notificationId);

      if (notificationData != null) {
        final notification = AppNotification.fromHive(Map<String, dynamic>.from(notificationData as Map));
        final updatedNotification = notification.markAsRead();
        await box.put(notificationId, updatedNotification.toHiveMap());

        // Mettre à jour les statistiques
        final allNotifications = await getLocalNotifications();
        await _updateLocalStats(allNotifications);
      }
    } catch (e) {
      print('Erreur lors du marquage local: $e');
    }
  }

  /// Marque toutes les notifications locales comme lues
  Future<void> _markAllLocalNotificationsAsRead() async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      final notifications = await getLocalNotifications();

      final updatedNotifications = notifications.map((n) => n.markAsRead()).toList();

      await box.clear();
      for (final notification in updatedNotifications) {
        await box.put(notification.id, notification.toHiveMap());
      }

      // Mettre à jour les statistiques
      await _updateLocalStats(updatedNotifications);
    } catch (e) {
      print('Erreur lors du marquage global local: $e');
    }
  }

  /// Met à jour les statistiques locales
  Future<void> _updateLocalStats(List<AppNotification> notifications) async {
    try {
      if (!Hive.isBoxOpen(_statsBoxKey)) {
        await Hive.openBox(_statsBoxKey);
      }

      final box = Hive.box(_statsBoxKey);
      final stats = NotificationStats.fromNotifications(notifications);

      await box.put('stats', {
        'total': stats.total,
        'unread': stats.unread,
        'byType': stats.byType.map((key, value) => MapEntry(key.name, value)),
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques: $e');
    }
  }

  /// Nettoie le cache local des notifications
  Future<void> clearLocalCache() async {
    try {
      if (Hive.isBoxOpen(_hiveBoxKey)) {
        final box = Hive.box(_hiveBoxKey);
        await box.clear();
      }

      if (Hive.isBoxOpen(_statsBoxKey)) {
        final statsBox = Hive.box(_statsBoxKey);
        await statsBox.clear();
      }
    } catch (e) {
      print('Erreur lors du nettoyage du cache: $e');
    }
  }

  /// Synchronise les notifications avec le serveur (pour usage en arrière-plan)
  Future<void> syncWithServer() async {
    try {
      final result = await getUnreadNotifications();
      if (result['success'] == true) {
        print('Synchronisation des notifications réussie');
      }
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  /// Vérifie si une notification existe localement
  Future<bool> hasLocalNotification(String notificationId) async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      return box.containsKey(notificationId);
    } catch (e) {
      return false;
    }
  }

  /// Supprime une notification du cache local (si supporté par l'API plus tard)
  Future<void> deleteLocalNotification(String notificationId) async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      await box.delete(notificationId);

      // Mettre à jour les statistiques
      final remainingNotifications = await getLocalNotifications();
      await _updateLocalStats(remainingNotifications);
    } catch (e) {
      print('Erreur lors de la suppression locale: $e');
    }
  }
}

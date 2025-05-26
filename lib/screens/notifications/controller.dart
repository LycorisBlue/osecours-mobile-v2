// lib/screens/notifications/controller.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/notification_models.dart';
import '../../services/notification_service.dart';

/// Controller pour gérer la logique des notifications
class NotificationsController {
  final NotificationService _notificationService = NotificationService();
  static const String _hiveBoxKey = 'notifications';

  // État du controller
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isMarkingAllAsRead = false;
  String? _error;
  List<AppNotification> _notifications = [];
  NotificationStats _stats = const NotificationStats(total: 0, unread: 0, byType: {});

  // Getters pour l'état
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isMarkingAllAsRead => _isMarkingAllAsRead;
  String? get error => _error;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  NotificationStats get stats => _stats;

  // Getters calculés
  bool get isEmpty => _notifications.isEmpty && !_isLoading;
  bool get hasUnread => _stats.hasUnread;
  int get unreadCount => _stats.unread;

  /// Initialise le controller et charge les notifications
  Future<void> initialize(Function(void Function()) setState) async {
    await _loadNotifications(setState);
  }

  /// Charge les notifications depuis le serveur et le cache local
  Future<void> _loadNotifications(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger d'abord depuis le cache local pour un affichage immédiat
      await _loadFromCache(setState);

      // Puis récupérer depuis le serveur
      final result = await _notificationService.getUnreadNotifications();

      if (result['success'] ?? false) {
        final notificationsData = result['data'] as List<dynamic>? ?? [];
        final serverNotifications =
            notificationsData.map((json) => AppNotification.fromJson(json as Map<String, dynamic>)).toList();

        // Fusionner avec les notifications locales pour préserver les états "lu"
        await _mergeWithLocalNotifications(serverNotifications, setState);
      } else {
        // En cas d'erreur serveur, utiliser seulement le cache local
        if (_notifications.isEmpty) {
          setState(() {
            _error = result['message'] ?? 'Erreur lors du chargement des notifications';
          });
        }
      }
    } catch (e) {
      // En cas d'erreur réseau, utiliser le cache local
      if (_notifications.isEmpty) {
        setState(() {
          _error = 'Erreur de connexion: ${e.toString()}';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Charge les notifications depuis le cache Hive
  Future<void> _loadFromCache(Function(void Function()) setState) async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      final cachedData = box.values.map((item) => AppNotification.fromHive(Map<String, dynamic>.from(item as Map))).toList();

      setState(() {
        _notifications = cachedData;
        _sortNotifications();
        _updateStats();
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement du cache: $e');
    }
  }

  /// Fusionne les notifications serveur avec les notifications locales
  Future<void> _mergeWithLocalNotifications(List<AppNotification> serverNotifications, Function(void Function()) setState) async {
    try {
      // Créer une map des notifications locales par ID pour conserver les états "lu"
      final localNotificationsMap = {for (var n in _notifications) n.id: n};

      // Fusionner les notifications serveur avec les états locaux
      final mergedNotifications =
          serverNotifications.map((serverNotification) {
            final localNotification = localNotificationsMap[serverNotification.id];
            if (localNotification != null) {
              // Préserver l'état "lu" local
              return serverNotification.copyWith(isRead: localNotification.isRead);
            }
            return serverNotification;
          }).toList();

      // Ajouter les notifications locales qui ne sont plus sur le serveur
      final serverIds = serverNotifications.map((n) => n.id).toSet();
      final localOnlyNotifications = _notifications.where((n) => !serverIds.contains(n.id)).toList();

      final allNotifications = [...mergedNotifications, ...localOnlyNotifications];

      setState(() {
        _notifications = allNotifications;
        _sortNotifications();
        _updateStats();
      });

      // Sauvegarder dans le cache
      await _saveToCache();
    } catch (e) {
      debugPrint('Erreur lors de la fusion des notifications: $e');
    }
  }

  /// Rafraîchit les notifications (pull-to-refresh)
  Future<void> refreshNotifications(Function(void Function()) setState) async {
    setState(() {
      _isRefreshing = true;
      _error = null;
    });

    try {
      final result = await _notificationService.getUnreadNotifications();

      if (result['success'] ?? false) {
        final notificationsData = result['data'] as List<dynamic>? ?? [];
        final serverNotifications =
            notificationsData.map((json) => AppNotification.fromJson(json as Map<String, dynamic>)).toList();

        await _mergeWithLocalNotifications(serverNotifications, setState);
        _showSuccessMessage('Notifications mises à jour');
      } else {
        setState(() {
          _error = result['message'] ?? 'Erreur lors du rafraîchissement';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: ${e.toString()}';
      });
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId, Function(void Function()) setState) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index == -1) return;

      // Marquer localement
      setState(() {
        _notifications[index] = _notifications[index].markAsRead();
        _updateStats();
      });

      // Sauvegarder dans le cache
      await _saveToCache();

      // Notifier le serveur (sans attendre pour ne pas bloquer l'UI)
      _notificationService.markAsRead(notificationId).catchError((e) {
        debugPrint('Erreur lors du marquage serveur: $e');
      });
    } catch (e) {
      debugPrint('Erreur lors du marquage comme lu: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead(Function(void Function()) setState) async {
    if (!hasUnread) return;

    setState(() {
      _isMarkingAllAsRead = true;
      _error = null;
    });

    try {
      // Marquer toutes les notifications comme lues localement
      setState(() {
        _notifications = _notifications.map((n) => n.markAsRead()).toList();
        _updateStats();
      });

      // Sauvegarder dans le cache
      await _saveToCache();

      // Notifier le serveur
      await _notificationService.markAllAsRead();

      _showSuccessMessage('Toutes les notifications ont été marquées comme lues');
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du marquage: ${e.toString()}';
      });
    } finally {
      setState(() => _isMarkingAllAsRead = false);
    }
  }

  /// Filtre les notifications par type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Filtre les notifications non lues
  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Trouve une notification par ID
  AppNotification? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Trie les notifications par date (plus récentes en premier)
  void _sortNotifications() {
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Met à jour les statistiques
  void _updateStats() {
    _stats = NotificationStats.fromNotifications(_notifications);
  }

  /// Sauvegarde les notifications dans le cache Hive
  Future<void> _saveToCache() async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);

      // Nettoyer l'ancien contenu
      await box.clear();

      // Sauvegarder les nouvelles notifications
      for (final notification in _notifications) {
        await box.put(notification.id, notification.toHiveMap());
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du cache: $e');
    }
  }

  /// Efface le cache local
  Future<void> clearCache() async {
    try {
      if (Hive.isBoxOpen(_hiveBoxKey)) {
        final box = Hive.box(_hiveBoxKey);
        await box.clear();
      }
    } catch (e) {
      debugPrint('Erreur lors du nettoyage du cache: $e');
    }
  }

  /// Efface l'erreur
  void clearError(Function(void Function()) setState) {
    setState(() => _error = null);
  }

  /// Affiche un message de succès (méthode placeholder)
  void _showSuccessMessage(String message) {
    // Cette méthode sera appelée par l'UI pour afficher le message
    debugPrint('SUCCESS: $message');
  }

  /// Callback appelé quand une notification est tapée
  void onNotificationTapped(AppNotification notification, Function(void Function()) setState) {
    if (!notification.isRead) {
      markAsRead(notification.id, setState);
    }
  }

  /// Nettoie les ressources du controller
  void dispose() {
    // Rien à nettoyer pour l'instant
  }

  /// Obtient le nombre de notifications par type pour les statistiques
  Map<String, int> getTypeStats() {
    final stats = <String, int>{};
    for (final notification in _notifications) {
      final typeLabel = notification.type.label;
      stats[typeLabel] = (stats[typeLabel] ?? 0) + 1;
    }
    return stats;
  }

  /// Vérifie si une notification est récente (moins de 24h)
  bool isRecentNotification(AppNotification notification) {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);
    return difference.inHours < 24;
  }

  /// Obtient les notifications récentes (moins de 24h)
  List<AppNotification> getRecentNotifications() {
    return _notifications.where((n) => isRecentNotification(n)).toList();
  }
}

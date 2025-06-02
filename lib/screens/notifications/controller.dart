// lib/screens/notifications/controller.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/notification_service.dart';

class NotificationsController {
  final NotificationService _notificationService = NotificationService();
  static const String _hiveBoxKey = 'notifications';

  // État du controller
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isMarkingAllAsRead = false;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isMarkingAllAsRead => _isMarkingAllAsRead;
  String? get error => _error;
  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

  bool get isEmpty => _notifications.isEmpty && !_isLoading;
  bool get hasUnread => _notifications.any((n) => !(n['is_read'] as bool? ?? false));
  int get unreadCount => _notifications.where((n) => !(n['is_read'] as bool? ?? false)).length;
  int get totalCount => _notifications.length;

  /// Initialise le controller
  Future<void> initialize(Function(void Function()) setState) async {
    await _loadNotifications(setState);
  }

  /// Charge les notifications : local d'abord, puis API en arrière-plan
  Future<void> _loadNotifications(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Charger et afficher les données locales immédiatement
      await _loadFromLocal(setState);

      // 2. Récupérer les nouvelles en arrière-plan
      _fetchNewNotificationsInBackground(setState);
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Charge depuis Hive et affiche immédiatement
  Future<void> _loadFromLocal(Function(void Function()) setState) async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      final localNotifications =
          box.values.where((item) => item is Map).map((item) => Map<String, dynamic>.from(item as Map)).toList();

      setState(() {
        _notifications = localNotifications;
        _sortNotifications();
      });

      debugPrint('Notifications locales chargées: ${_notifications.length}');
    } catch (e) {
      debugPrint('Erreur chargement local: $e');
    }
  }

  /// Récupère nouvelles notifications en arrière-plan
  Future<void> _fetchNewNotificationsInBackground(Function(void Function()) setState) async {
    try {
      final result = await _notificationService.getUnreadNotifications();

      if (result['success'] == true || result.containsKey('data')) {
        final newNotificationsData = result['data'] as List<dynamic>? ?? [];

        if (newNotificationsData.isNotEmpty) {
          await _mergeNewNotifications(newNotificationsData.cast<Map<String, dynamic>>(), setState);
        }
      }
    } catch (e) {
      debugPrint('Erreur récupération arrière-plan: $e');
    }
  }

  /// Fusionne nouvelles notifications
  Future<void> _mergeNewNotifications(List<Map<String, dynamic>> newNotifications, Function(void Function()) setState) async {
    try {
      final existingIds = _notifications.map((n) => n['id']).toSet();
      final notificationsToAdd = newNotifications.where((n) => !existingIds.contains(n['id'])).toList();

      if (notificationsToAdd.isNotEmpty) {
        setState(() {
          _notifications.addAll(notificationsToAdd);
          _sortNotifications();
        });

        await _saveToLocal();
        debugPrint('${notificationsToAdd.length} nouvelles notifications ajoutées');
      }
    } catch (e) {
      debugPrint('Erreur fusion: $e');
    }
  }

  /// Rafraîchissement pull-to-refresh
  Future<void> refreshNotifications(Function(void Function()) setState) async {
    setState(() {
      _isRefreshing = true;
      _error = null;
    });

    try {
      await _loadFromLocal(setState);

      final result = await _notificationService.getUnreadNotifications();

      if (result['success'] == true || result.containsKey('data')) {
        final newNotificationsData = result['data'] as List<dynamic>? ?? [];

        if (newNotificationsData.isNotEmpty) {
          await _mergeNewNotifications(newNotificationsData.cast<Map<String, dynamic>>(), setState);
        }
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
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index == -1) return;

      // Marquer localement
      setState(() {
        _notifications[index]['is_read'] = true;
      });

      // Sauvegarder immédiatement
      await _saveToLocal();

      // Notifier serveur en arrière-plan
      _notificationService.markAsRead(notificationId).catchError((e) {
        debugPrint('Erreur marquage serveur: $e');
      });
    } catch (e) {
      debugPrint('Erreur marquage local: $e');
    }
  }

  /// Marque toutes comme lues
  Future<void> markAllAsRead(Function(void Function()) setState) async {
    if (!hasUnread) return;

    setState(() {
      _isMarkingAllAsRead = true;
      _error = null;
    });

    try {
      // Marquer toutes localement
      setState(() {
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }
      });

      // Sauvegarder immédiatement
      await _saveToLocal();

      // Notifier serveur
      await _notificationService.markAllAsRead();
    } catch (e) {
      setState(() {
        _error = 'Erreur marquage: ${e.toString()}';
      });
    } finally {
      setState(() => _isMarkingAllAsRead = false);
    }
  }

  /// Sauvegarde dans Hive
  Future<void> _saveToLocal() async {
    try {
      if (!Hive.isBoxOpen(_hiveBoxKey)) {
        await Hive.openBox(_hiveBoxKey);
      }

      final box = Hive.box(_hiveBoxKey);
      await box.clear();

      for (var notification in _notifications) {
        await box.put(notification['id'], notification);
      }

      debugPrint('${_notifications.length} notifications sauvegardées');
    } catch (e) {
      debugPrint('Erreur sauvegarde: $e');
    }
  }

  /// Trie par date (plus récentes en premier)
  void _sortNotifications() {
    _notifications.sort((a, b) {
      final dateA = DateTime.parse(a['createdAt']);
      final dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });
  }

  /// Callback tap notification
  void onNotificationTapped(Map<String, dynamic> notification, Function(void Function()) setState) {
    if (!(notification['is_read'] as bool? ?? false)) {
      markAsRead(notification['id'], setState);
    }
  }

  /// Clear error
  void clearError(Function(void Function()) setState) {
    setState(() => _error = null);
  }

  /// Dispose
  void dispose() {
    // Rien à nettoyer
  }
}

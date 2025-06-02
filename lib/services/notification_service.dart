// lib/services/notification_service.dart
import 'dart:convert';
import '../core/constants/api.dart';
import 'api_service.dart';

/// Service simplifié pour la gestion des notifications via API
class NotificationService extends ApiService {
  /// Récupère les notifications non lues depuis le serveur
  Future<Map<String, dynamic>> getUnreadNotifications() async {
    final response = await getRequest(NotificationEndpoints.unread);
    return json.decode(response.body);
  }

  /// Marque une notification comme lue
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final response = await postRequest(NotificationEndpoints.read, {'notification_id': notificationId});
    return json.decode(response.body);
  }

  /// Marque toutes les notifications comme lues
  Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await postRequest(NotificationEndpoints.readAll, {});
    return json.decode(response.body);
  }
}

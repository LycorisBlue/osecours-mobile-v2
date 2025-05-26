// lib/screens/alerts/controller.dart
import '../../services/alert_service.dart';

/// Controller pour gérer la logique des alertes
class AlertsController {
  final AlertService _alertService = AlertService();

  // État du controller
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  List<Map<String, dynamic>> _alerts = [];

  // Getters pour l'état
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  List<Map<String, dynamic>> get alerts => List.unmodifiable(_alerts);
  bool get hasAlerts => _alerts.isNotEmpty;
  bool get isEmpty => _alerts.isEmpty && !_isLoading;

  /// Initialise le controller et charge les alertes
  Future<void> initialize(Function(void Function()) setState) async {
    await loadAlerts(setState);
  }

  /// Charge toutes les alertes
  Future<void> loadAlerts(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _alertService.getAllAlerts();

      if (result['success']) {
        final alertsData = result['data'] as List<dynamic>;
        setState(() {
          _alerts = alertsData.map((alertJson) => alertJson as Map<String, dynamic>).toList();

          // Trier par date de création (plus récent en premier)
          _alerts.sort((a, b) {
            final dateA = DateTime.parse(a['createdAt'] ?? DateTime.now().toIso8601String());
            final dateB = DateTime.parse(b['createdAt'] ?? DateTime.now().toIso8601String());
            return dateB.compareTo(dateA);
          });

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Erreur lors du chargement des alertes';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Une erreur est survenue: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Rafraîchit les alertes (pull-to-refresh)
  Future<void> refreshAlerts(Function(void Function()) setState) async {
    setState(() {
      _isRefreshing = true;
      _error = null;
    });

    try {
      final result = await _alertService.getAllAlerts();

      if (result['success']) {
        final alertsData = result['data'] as List<dynamic>;
        setState(() {
          _alerts = alertsData.map((alertJson) => alertJson as Map<String, dynamic>).toList();

          // Trier par date de création (plus récent en premier)
          _alerts.sort((a, b) {
            final dateA = DateTime.parse(a['createdAt'] ?? DateTime.now().toIso8601String());
            final dateB = DateTime.parse(b['createdAt'] ?? DateTime.now().toIso8601String());
            return dateB.compareTo(dateA);
          });

          _isRefreshing = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Erreur lors du rafraîchissement';
          _isRefreshing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de rafraîchissement: ${e.toString()}';
        _isRefreshing = false;
      });
    }
  }

  /// Filtre les alertes par statut (en utilisant les strings directement)
  List<Map<String, dynamic>> getAlertsByStatus(String status) {
    return _alerts.where((alert) => alert['status'] == status).toList();
  }

  /// Obtient les statistiques des alertes
  Map<String, int> getAlertsStats() {
    final stats = <String, int>{'total': _alerts.length, 'en_attente': 0, 'acceptee': 0, 'en_cours': 0, 'resolue': 0};

    for (final alert in _alerts) {
      final status = alert['status']?.toString().toUpperCase() ?? 'EN_ATTENTE';
      switch (status) {
        case 'EN_ATTENTE':
          stats['en_attente'] = (stats['en_attente'] ?? 0) + 1;
          break;
        case 'ACCEPTEE':
          stats['acceptee'] = (stats['acceptee'] ?? 0) + 1;
          break;
        case 'EN_COURS':
          stats['en_cours'] = (stats['en_cours'] ?? 0) + 1;
          break;
        case 'RESOLUE':
          stats['resolue'] = (stats['resolue'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  /// Obtient une alerte par son ID
  Map<String, dynamic>? getAlertById(String alertId) {
    try {
      return _alerts.firstWhere((alert) => alert['id']?.toString() == alertId);
    } catch (e) {
      return null;
    }
  }

  /// Efface l'erreur
  void clearError(Function(void Function()) setState) {
    setState(() {
      _error = null;
    });
  }

  /// Nettoie les ressources
  void dispose() {
    _alerts.clear();
  }
}

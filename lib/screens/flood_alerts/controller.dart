// lib/screens/flood_alerts/controller.dart
import 'package:geolocator/geolocator.dart';
import '../../data/models/flood_alert_models.dart';
import '../../services/flood_alert_service.dart';

/// Controller pour gérer la logique des alertes d'inondation
class FloodAlertsController {
  final FloodAlertService _floodAlertService = FloodAlertService();

  // État du controller
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _globalMessage = '';
  List<FloodAlert> _floodAlerts = [];
  Position? _userPosition;

  // Getters pour l'état
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get globalMessage => _globalMessage;
  List<FloodAlert> get floodAlerts => List.unmodifiable(_floodAlerts);
  Position? get userPosition => _userPosition;
  bool get isEmpty => _floodAlerts.isEmpty && !_isLoading;
  bool get hasAlerts => _floodAlerts.isNotEmpty;

  /// Initialise le controller et charge les alertes
  Future<void> initialize(Function(void Function()) setState) async {
    await fetchFloodAlerts(setState);
  }

  /// Récupère les alertes d'inondation
  Future<void> fetchFloodAlerts(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Vérifier la permission de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _error = 'Accès à la localisation refusé';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _error = 'Les paramètres de localisation sont désactivés';
        });
        return;
      }

      // Obtenir la position
      _userPosition = await Geolocator.getCurrentPosition();

      // Appeler l'API
      final response = await _floodAlertService.getNearbyFloodAlerts(
        latitude: _userPosition!.latitude,
        longitude: _userPosition!.longitude,
      );

      // Traiter les résultats
      if (response.containsKey('data')) {
        var data = response['data'];

        // Extraire le message global
        _globalMessage = data['message'] ?? '';

        // Extraire les alertes
        if (data.containsKey('alerts') && data['alerts'] is List) {
          final List<dynamic> alertsJson = data['alerts'];

          setState(() {
            _floodAlerts = alertsJson.map((json) => FloodAlert.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _error = 'Aucune alerte trouvée';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Format de réponse incorrect';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur: ${e.toString()}';
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
      if (_userPosition != null) {
        final response = await _floodAlertService.getNearbyFloodAlerts(
          latitude: _userPosition!.latitude,
          longitude: _userPosition!.longitude,
        );

        if (response.containsKey('data')) {
          var data = response['data'];
          _globalMessage = data['message'] ?? '';

          if (data.containsKey('alerts') && data['alerts'] is List) {
            final List<dynamic> alertsJson = data['alerts'];
            setState(() {
              _floodAlerts = alertsJson.map((json) => FloodAlert.fromJson(json)).toList();
              _isRefreshing = false;
            });
          } else {
            setState(() {
              _isRefreshing = false;
              _error = 'Aucune alerte trouvée';
            });
          }
        } else {
          setState(() {
            _isRefreshing = false;
            _error = 'Format de réponse incorrect';
          });
        }
      } else {
        // Re-fetch complètement si pas de position
        await fetchFloodAlerts(setState);
        setState(() => _isRefreshing = false);
      }
    } catch (e) {
      setState(() {
        _isRefreshing = false;
        _error = 'Erreur: ${e.toString()}';
      });
    }
  }

  /// Efface l'erreur
  void clearError(Function(void Function()) setState) {
    setState(() => _error = null);
  }

  /// Nettoie les ressources
  void dispose() {
    _floodAlerts.clear();
  }
}

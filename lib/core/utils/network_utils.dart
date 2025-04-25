// lib/core/utils/network_utils.dart
import 'package:connectivity_plus/connectivity_plus.dart';

/// Classe utilitaire pour vérifier la connectivité réseau
class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Vérifie si l'appareil dispose d'une connexion Internet active
  ///
  /// Retourne [true] si l'appareil est connecté au WiFi ou aux données mobiles
  /// Retourne [false] sinon
  static Future<bool> isConnected() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      final result = results.first;
      return result == ConnectivityResult.wifi || result == ConnectivityResult.mobile || result == ConnectivityResult.ethernet;
    } catch (e) {
      // En cas d'erreur, supposer qu'il n'y a pas de connexion
      print(e);
      return false;
    }
  }

  /// Obtient le type de connexion actuelle
  ///
  /// Retourne une chaîne décrivant le type de connexion: 'WiFi', 'Mobile', 'Ethernet' ou 'Aucune'
  static Future<String> getConnectionType() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      final result = results.first;

      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        default:
          return 'Aucune';
      }
    } catch (e) {
      return 'Erreur';
    }
  }

  /// Permet de s'abonner aux changements de connectivité
  ///
  /// Retourne un Stream qui émet un événement à chaque changement de connectivité
  static Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;
}

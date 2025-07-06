// lib/screens/pharmacies_garde/controller.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/pharmacy_service.dart';

class PharmaciesGardeController {
  final PharmacyService _pharmacyService = PharmacyService();

  // Variables d'état
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _pharmacies = [];
  int _currentRadius = 2; // Commence par 2km
  String _searchStatus = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get pharmacies => _pharmacies;
  int get currentRadius => _currentRadius;
  String get searchStatus => _searchStatus;
  int get totalPharmacies => _pharmacies.length;

  /// Initialise le contrôleur et lance la recherche progressive
  Future<void> initialize(Function(void Function()) setState) async {
    await searchPharmaciesProgressively(setState);
  }

  /// Recherche progressive : 2km -> 5km -> 10km
  Future<void> searchPharmaciesProgressively(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pharmacies = [];
    });

    try {
      // Obtenir la position actuelle
      Position position = await _getCurrentPosition();

      // Recherche en 2km d'abord
      await _searchInRadius(2, position, setState);

      // Si pas de résultats, chercher en 5km
      if (_pharmacies.isEmpty) {
        await _searchInRadius(5, position, setState);
      }

      // Si toujours pas de résultats, chercher en 10km
      if (_pharmacies.isEmpty) {
        await _searchInRadius(10, position, setState);
      }

      // Si toujours rien
      if (_pharmacies.isEmpty) {
        setState(() {
          _error = 'Aucune pharmacie de garde trouvée dans un rayon de 10km';
          _searchStatus = 'Recherche terminée - Aucun résultat';
        });
      }
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
        _searchStatus = 'Erreur lors de la recherche';
      });
      debugPrint('Erreur lors de la recherche des pharmacies: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Recherche dans un rayon spécifique
  Future<void> _searchInRadius(int radius, Position position, Function(void Function()) setState) async {
    setState(() {
      _currentRadius = radius;
      _searchStatus = 'Recherche dans un rayon de ${radius}km...';
    });

    try {
      final result = await _pharmacyService.getNearbyPharmacies(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: radius,
      );

      if (result['data'] != null && result['data']['pharmacies'] != null) {
        List<Map<String, dynamic>> foundPharmacies = List<Map<String, dynamic>>.from(result['data']['pharmacies']);

        if (foundPharmacies.isNotEmpty) {
          setState(() {
            _pharmacies = foundPharmacies;
            _searchStatus = '${foundPharmacies.length} pharmacie(s) trouvée(s) dans un rayon de ${radius}km';
          });
          debugPrint('${foundPharmacies.length} pharmacies trouvées dans un rayon de ${radius}km');
        } else {
          setState(() {
            _searchStatus = 'Aucune pharmacie dans un rayon de ${radius}km';
          });
          debugPrint('Aucune pharmacie trouvée dans un rayon de ${radius}km');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche dans un rayon de ${radius}km: $e');
      // On ne throw pas l'erreur ici pour continuer avec le rayon suivant
    }
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Le service de localisation est désactivé');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission de localisation refusée définitivement');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Rafraîchit la recherche (repart de 2km)
  Future<void> refresh(Function(void Function()) setState) async {
    _currentRadius = 2;
    await searchPharmaciesProgressively(setState);
  }

  /// Retourne un message d'erreur approprié selon le type d'exception
  String _getErrorMessage(dynamic error) {
    String errorMsg = error.toString().toLowerCase();

    if (errorMsg.contains('socketexception') || errorMsg.contains('networkexception')) {
      return 'Vérifiez votre connexion internet';
    } else if (errorMsg.contains('timeoutexception')) {
      return 'Délai d\'attente dépassé, réessayez';
    } else if (errorMsg.contains('formatexception')) {
      return 'Erreur de format des données';
    } else if (errorMsg.contains('localisation') || errorMsg.contains('location') || errorMsg.contains('permission')) {
      return errorMsg.contains('permission') ? 'Permission de localisation requise' : 'Erreur de localisation';
    } else if (errorMsg.contains('token d\'authentification manquant')) {
      return 'Veuillez vous reconnecter';
    } else {
      return 'Une erreur est survenue, réessayez';
    }
  }

  /// Nettoie les ressources du contrôleur
  void dispose() {
    _pharmacies.clear();
    _error = null;
  }
}

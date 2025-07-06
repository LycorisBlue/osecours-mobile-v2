// lib/screens/centres_hospitaliers/controller.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/pharmacy_service.dart';

class CentresHospitaliersController {
  final PharmacyService _pharmacyService = PharmacyService();

  // Variables d'état
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _etablissements = [];
  Map<String, dynamic>? _statistics;
  int _currentRadius = 2; // Commence par 2km
  String _searchStatus = '';
  int _totalEtablissements = 0;
  int _totalCommunes = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get etablissements => _etablissements;
  Map<String, dynamic>? get statistics => _statistics;
  int get currentRadius => _currentRadius;
  String get searchStatus => _searchStatus;
  int get totalEtablissements => _totalEtablissements;
  int get totalCommunes => _totalCommunes;

  // Getters pour les statistiques par catégorie
  int get totalHopitaux {
    if (_statistics == null || _statistics!['parCategorie'] == null) return 0;
    final categories = _statistics!['parCategorie'] as List;
    final hopitaux = categories.firstWhere((cat) => cat['name'] == 'Hôpital', orElse: () => {'count': 0});
    return hopitaux['count'] ?? 0;
  }

  int get totalCliniques {
    if (_statistics == null || _statistics!['parCategorie'] == null) return 0;
    final categories = _statistics!['parCategorie'] as List;
    final cliniques = categories.firstWhere((cat) => cat['name'] == 'Clinique médicale', orElse: () => {'count': 0});
    return cliniques['count'] ?? 0;
  }

  /// Initialise le contrôleur et lance la recherche progressive
  Future<void> initialize(Function(void Function()) setState) async {
    await searchEtablissementsProgressively(setState);
  }

  /// Recherche progressive : 2km -> 5km -> 10km
  Future<void> searchEtablissementsProgressively(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _etablissements = [];
      _statistics = null;
      _totalEtablissements = 0;
      _totalCommunes = 0;
    });

    try {
      // Obtenir la position actuelle
      Position position = await _getCurrentPosition();

      // Recherche en 2km d'abord
      await _searchInRadius(2, position, setState);

      // Si pas de résultats, chercher en 5km
      if (_etablissements.isEmpty) {
        await _searchInRadius(5, position, setState);
      }

      // Si toujours pas de résultats, chercher en 10km
      if (_etablissements.isEmpty) {
        await _searchInRadius(10, position, setState);
      }

      // Si toujours rien
      if (_etablissements.isEmpty) {
        setState(() {
          _error = 'Aucun établissement de santé trouvé dans un rayon de 10km';
          _searchStatus = 'Recherche terminée - Aucun résultat';
        });
      }
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
        _searchStatus = 'Erreur lors de la recherche';
      });
      debugPrint('Erreur lors de la recherche des établissements: $e');
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
      final result = await _pharmacyService.getNearbyHealthEstablishments(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: radius,
      );

      if (result['data'] != null && result['data']['etablissements'] != null) {
        List<Map<String, dynamic>> foundEtablissements = List<Map<String, dynamic>>.from(result['data']['etablissements']);

        if (foundEtablissements.isNotEmpty) {
          setState(() {
            _etablissements = foundEtablissements;
            _statistics = result['data']['statistics'];
            _totalEtablissements = result['data']['totalEtablissements'] ?? foundEtablissements.length;
            _totalCommunes = result['data']['totalCommunes'] ?? 0;
            _searchStatus = '${foundEtablissements.length} établissement(s) trouvé(s) dans un rayon de ${radius}km';
          });
          debugPrint('${foundEtablissements.length} établissements trouvés dans un rayon de ${radius}km');
        } else {
          setState(() {
            _searchStatus = 'Aucun établissement dans un rayon de ${radius}km';
          });
          debugPrint('Aucun établissement trouvé dans un rayon de ${radius}km');
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
    await searchEtablissementsProgressively(setState);
  }

  /// Filtre les établissements par catégorie
  List<Map<String, dynamic>> getEtablissementsByCategory(String category) {
    return _etablissements.where((etablissement) => etablissement['categorie'] == category).toList();
  }

  /// Filtre les établissements par commune
  List<Map<String, dynamic>> getEtablissementsByCommune(String commune) {
    return _etablissements.where((etablissement) => etablissement['commune'] == commune).toList();
  }

  /// Obtient un établissement par son ID
  Map<String, dynamic>? getEtablissementById(String id) {
    try {
      return _etablissements.firstWhere((etablissement) => etablissement['id'] == id);
    } catch (e) {
      return null;
    }
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
    _etablissements.clear();
    _statistics = null;
    _error = null;
  }
}

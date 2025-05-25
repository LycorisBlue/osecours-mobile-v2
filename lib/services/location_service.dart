// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service pour la gestion de la géolocalisation
class LocationService {
  /// Vérifie si les services de localisation sont activés
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Vérifie et demande les permissions de localisation
  static Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Obtient la position actuelle de l'utilisateur
  static Future<Position?> getCurrentPosition() async {
    try {
      // Vérifier si le service est activé
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Service de localisation désactivé');
      }

      // Vérifier les permissions
      LocationPermission permission = await checkAndRequestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée');
      }

      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  /// Obtient l'adresse actuelle de l'utilisateur
  static Future<String> getCurrentAddress() async {
    try {
      Position? position = await getCurrentPosition();

      if (position == null) {
        return 'Localisation indisponible';
      }

      return await getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Erreur lors de l\'obtention de l\'adresse: $e');
      return 'Adresse indisponible';
    }
  }

  /// Convertit les coordonnées en adresse lisible
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Construire l'adresse de manière intelligente
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        // Si on a des éléments, les joindre avec des virgules
        if (addressParts.isNotEmpty) {
          return addressParts.take(2).join(', '); // Prendre max 2 éléments
        }

        // Fallback avec les coordonnées
        return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }

      return 'Adresse non trouvée';
    } catch (e) {
      print('Erreur lors de la conversion des coordonnées: $e');
      return 'Erreur de géocodage';
    }
  }

  /// Calcule la distance entre deux points
  static double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  }

  /// Vérifie si la localisation est disponible
  static Future<bool> isLocationAvailable() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      return permission != LocationPermission.denied && permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  /// Ouvre les paramètres de l'application pour la localisation
  static Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('Erreur lors de l\'ouverture des paramètres: $e');
      return false;
    }
  }

  /// Obtient un stream de positions (pour suivi en temps réel)
  static Stream<Position> getPositionStream({LocationAccuracy accuracy = LocationAccuracy.high, int distanceFilter = 10}) {
    const LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}

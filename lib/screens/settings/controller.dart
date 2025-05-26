// lib/screens/settings/controller.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/navigation_service.dart';

/// Controller pour gérer la logique de la page des paramètres
class SettingsController {
  // Données utilisateur
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String? _userPhoto;

  // Getters pour les données utilisateur
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String? get userPhoto => _userPhoto;
  bool get hasEmail => _userEmail.isNotEmpty;

  /// Initialise le controller et charge les données utilisateur
  void initialize(Function(void Function()) setState) {
    _loadUserData(setState);
  }

  /// Charge les données utilisateur depuis Hive
  void _loadUserData(Function(void Function()) setState) {
    try {
      final box = Hive.box('auth');
      setState(() {
        _userName = box.get('fullName', defaultValue: '');
        _userEmail = box.get('email', defaultValue: '');
        _userPhone = box.get('phoneNumber', defaultValue: '');
        _userPhoto = box.get('photo');
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  void navigateToProfile() {
    Routes.navigateTo(Routes.profile);
  }

  /// Navigue vers les numéros de sécurité
  void navigateToSafeNumbers() {
    Routes.navigateTo(Routes.safeContacts);
  }

  /// Navigue vers les lieux importants
  void navigateToImportantPlaces() {
    // TODO: Implémenter la navigation vers les lieux importants
    debugPrint('Navigation vers lieux importants - À implémenter');
  }

  /// Affiche la boîte de dialogue de confirmation de déconnexion
  void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Fermer le dialog
                await _performLogout(context);
              },
              child: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: Color(0xFFFF3333), // AppColors.primary
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Effectue la déconnexion
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Nettoyer toutes les boîtes Hive
      await Hive.box('auth').clear();

      if (Hive.isBoxOpen('notifications')) {
        await Hive.box('notifications').clear();
      }

      if (Hive.isBoxOpen('user')) {
        await Hive.box('user').clear();
      }

      if (Hive.isBoxOpen('temp')) {
        await Hive.box('temp').clear();
      }

      if (context.mounted) {
        // Naviguer vers la page de connexion et effacer l'historique
        Routes.navigateAndRemoveAll(Routes.registration);
      }
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erreur lors de la déconnexion'), backgroundColor: Colors.red));
      }
    }
  }

  /// Formate le numéro de téléphone pour l'affichage
  String getFormattedPhone() {
    if (_userPhone.isEmpty) return '';

    String cleanNumber = _userPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.startsWith('225')) {
      cleanNumber = cleanNumber.substring(3);
    }

    if (cleanNumber.length != 10) {
      return _userPhone;
    }

    return '+225 ${cleanNumber.replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)} ').trim()}';
  }

  /// Obtient l'URL complète de la photo de profil
  String? getProfilePhotoUrl() {
    if (_userPhoto == null || _userPhoto!.isEmpty) return null;

    // Si c'est déjà une URL complète, la retourner
    if (_userPhoto!.startsWith('http')) {
      return _userPhoto;
    }

    // Sinon, construire l'URL complète
    return 'http://46.202.170.228:3000/$_userPhoto';
  }

  /// Obtient les initiales du nom pour l'avatar par défaut
  String getUserInitials() {
    if (_userName.isEmpty) return '?';

    final parts = _userName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return _userName[0].toUpperCase();
    }
  }

  /// Nettoie les ressources
  void dispose() {
    // Rien à nettoyer pour l'instant
  }
}

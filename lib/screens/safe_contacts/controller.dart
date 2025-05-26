// lib/screens/safe_contacts/controller.dart
import 'package:flutter/material.dart';
import '../../data/models/safe_contact_models.dart';
import '../../services/safe_contacts_service.dart';

/// Controller pour gérer la logique des contacts de sécurité
class SafeContactsController {
  final SafeContactsService _service = SafeContactsService();

  // État du controller
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isDeletingContact = false;
  bool _isTestingMessage = false;
  bool _isUpdatingLocationSharing = false;
  String? _error;
  String? _successMessage;
  List<SafeContact> _contacts = [];
  LocationSharingConfig _locationConfig = LocationSharingConfig.defaultConfig;

  // Getters pour l'état
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isDeletingContact => _isDeletingContact;
  bool get isTestingMessage => _isTestingMessage;
  bool get isUpdatingLocationSharing => _isUpdatingLocationSharing;
  String? get error => _error;
  String? get successMessage => _successMessage;
  List<SafeContact> get contacts => List.unmodifiable(_contacts);
  LocationSharingConfig get locationConfig => _locationConfig;

  // Getters calculés
  bool get isEmpty => _contacts.isEmpty && !_isLoading;
  bool get canAddMore => _contacts.length < 5;
  int get remainingSlots => 5 - _contacts.length;
  bool get hasContacts => _contacts.isNotEmpty;

  /// Statistiques par catégorie
  Map<ContactCategory, int> get contactsByCategory {
    final Map<ContactCategory, int> stats = {};
    for (final category in ContactCategory.values) {
      stats[category] = _contacts.where((c) => c.category == category).length;
    }
    return stats;
  }

  /// Initialise le controller et charge les données
  Future<void> initialize(Function(void Function()) setState) async {
    await _loadData(setState);
  }

  /// Charge toutes les données (contacts + configuration de localisation)
  Future<void> _loadData(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger les contacts et la configuration en parallèle
      final results = await Future.wait([_service.fetchSafeContacts(), _service.getLocationSharingConfig()]);

      final contactsResult = results[0] as Map<String, dynamic>;
      final locationConfig = results[1] as LocationSharingConfig;

      setState(() {
        if (contactsResult['success']) {
          _contacts = List<SafeContact>.from(contactsResult['data']);
        } else {
          _contacts = List<SafeContact>.from(contactsResult['data'] ?? []);
          if (contactsResult['isOffline'] != true) {
            _error = contactsResult['message'];
          }
        }
        _locationConfig = locationConfig;
        _isLoading = false;
      });

      // Afficher un message si en mode offline
      if (contactsResult['isOffline'] == true) {
        _showSuccessMessage('Mode hors ligne - Données locales affichées');
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Rafraîchit les données (pull-to-refresh)
  Future<void> refreshData(Function(void Function()) setState) async {
    setState(() {
      _isRefreshing = true;
      _error = null;
    });

    try {
      final result = await _service.fetchSafeContacts();

      setState(() {
        if (result['success']) {
          _contacts = List<SafeContact>.from(result['data']);
          _showSuccessMessage('Données mises à jour');
        } else {
          _error = result['message'];
        }
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du rafraîchissement: ${e.toString()}';
        _isRefreshing = false;
      });
    }
  }

  /// Supprime un contact avec confirmation
  Future<void> deleteContact(SafeContact contact, Function(void Function()) setState) async {
    setState(() {
      _isDeletingContact = true;
      _error = null;
    });

    try {
      final result = await _service.deleteSafeContacts([contact.id]);

      if (result['success']) {
        setState(() {
          _contacts.removeWhere((c) => c.id == contact.id);
          _isDeletingContact = false;
        });
        _showSuccessMessage(result['message']);
      } else {
        setState(() {
          _error = result['message'];
          _isDeletingContact = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la suppression: ${e.toString()}';
        _isDeletingContact = false;
      });
    }
  }

  /// Affiche la confirmation de suppression
  void showDeleteConfirmation(BuildContext context, SafeContact contact, Function(void Function()) setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmer la suppression',
            style: TextStyle(fontFamily: "Poppins", fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Voulez-vous vraiment supprimer "${contact.description}" de vos contacts de sécurité ?',
            style: const TextStyle(fontFamily: "Poppins"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontFamily: "Poppins")),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red, fontFamily: "Poppins", fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteContact(contact, setState);
              },
            ),
          ],
        );
      },
    );
  }

  /// Met à jour la catégorie d'un contact
  Future<void> updateContactCategory(SafeContact contact, ContactCategory newCategory, Function(void Function()) setState) async {
    try {
      final result = await _service.updateContactCategory(contact.id, newCategory);

      if (result['success']) {
        setState(() {
          final index = _contacts.indexWhere((c) => c.id == contact.id);
          if (index != -1) {
            _contacts[index] = _contacts[index].copyWith(category: newCategory);
          }
        });
        _showSuccessMessage('Catégorie mise à jour');
      } else {
        setState(() => _error = result['message']);
      }
    } catch (e) {
      setState(() => _error = 'Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  /// Affiche le sélecteur de catégorie
  void showCategorySelector(BuildContext context, SafeContact contact, Function(void Function()) setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Catégorie pour ${contact.description}',
            style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                ContactCategory.values.map((category) {
                  final isSelected = contact.category == category;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.lightColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: category.borderColor),
                      ),
                      child: Icon(category.icon, color: category.color, size: 20),
                    ),
                    title: Text(
                      category.label,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? category.color : null,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check, color: category.color) : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (!isSelected) {
                        updateContactCategory(contact, category, setState);
                      }
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  /// Envoie un message de test
  Future<void> sendTestMessage(SafeContact contact, Function(void Function()) setState) async {
    setState(() {
      _isTestingMessage = true;
      _error = null;
    });

    try {
      final result = await _service.sendTestMessage(contact);

      setState(() => _isTestingMessage = false);

      if (result['success']) {
        _showSuccessMessage(result['message']);
      } else {
        setState(() => _error = result['message']);
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'envoi: ${e.toString()}';
        _isTestingMessage = false;
      });
    }
  }

  /// Met à jour la configuration de partage de localisation
  Future<void> updateLocationSharing(bool enabled, Function(void Function()) setState) async {
    setState(() {
      _isUpdatingLocationSharing = true;
      _error = null;
    });

    try {
      final newConfig = LocationSharingConfig(isEnabled: enabled, mode: _locationConfig.mode, lastUpdated: DateTime.now());

      final result = await _service.updateLocationSharingConfig(newConfig);

      if (result['success']) {
        setState(() {
          _locationConfig = newConfig;
          _isUpdatingLocationSharing = false;
        });
        _showSuccessMessage(enabled ? 'Partage de localisation activé' : 'Partage de localisation désactivé');
      } else {
        setState(() {
          _error = result['message'];
          _isUpdatingLocationSharing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la mise à jour: ${e.toString()}';
        _isUpdatingLocationSharing = false;
      });
    }
  }

  /// Met à jour le mode de partage de localisation
  Future<void> updateLocationSharingMode(LocationSharingMode mode, Function(void Function()) setState) async {
    try {
      final newConfig = LocationSharingConfig(isEnabled: _locationConfig.isEnabled, mode: mode, lastUpdated: DateTime.now());

      final result = await _service.updateLocationSharingConfig(newConfig);

      if (result['success']) {
        setState(() => _locationConfig = newConfig);
        _showSuccessMessage('Mode de partage mis à jour');
      } else {
        setState(() => _error = result['message']);
      }
    } catch (e) {
      setState(() => _error = 'Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  /// Affiche le sélecteur de mode de partage
  void showLocationSharingModeSelector(BuildContext context, Function(void Function()) setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mode de partage', style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                LocationSharingMode.values.map((mode) {
                  final isSelected = _locationConfig.mode == mode;
                  return ListTile(
                    title: Text(
                      mode.label,
                      style: TextStyle(fontFamily: "Poppins", fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                    ),
                    subtitle: Text(mode.description, style: const TextStyle(fontFamily: "Poppins", fontSize: 12)),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFFF3333)) : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (!isSelected) {
                        updateLocationSharingMode(mode, setState);
                      }
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  /// Callback après ajout de contacts réussi
  void onContactsAdded(List<SafeContact> newContacts, Function(void Function()) setState) {
    setState(() {
      _contacts.addAll(newContacts);
    });
    _showSuccessMessage(
      newContacts.length == 1 ? 'Contact ajouté avec succès' : '${newContacts.length} contacts ajoutés avec succès',
    );
  }

  /// Efface l'erreur
  void clearError(Function(void Function()) setState) {
    setState(() => _error = null);
  }

  /// Efface le message de succès
  void clearSuccessMessage(Function(void Function()) setState) {
    setState(() => _successMessage = null);
  }

  /// Affiche un message de succès
  void _showSuccessMessage(String message) {
    _successMessage = message;
    // Le message sera affiché par l'UI et effacé automatiquement
  }

  /// Nettoie les ressources
  void dispose() {
    // Rien à nettoyer pour l'instant
  }
}

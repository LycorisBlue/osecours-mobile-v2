// lib/services/safe_contacts_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api.dart';
import '../data/models/safe_contact_models.dart';
import 'api_service.dart';

/// Service complet pour la gestion des contacts de sécurité
class SafeContactsService extends ApiService {
  static const String _hiveBoxKey = 'safeContacts';
  static const String _locationSharingKey = 'locationSharing';

  /// Récupère tous les contacts de sécurité depuis le serveur
  Future<Map<String, dynamic>> fetchSafeContacts() async {
    try {
      final response = await getRequest(SafeNumberEndpoints.get);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final contactsData = responseData['data'] as List<dynamic>? ?? [];
        final contacts = contactsData.map((json) => SafeContact.fromJson(json as Map<String, dynamic>)).toList();

        // Synchroniser avec le cache local
        await _syncToLocal(contacts);

        return {'success': true, 'data': contacts, 'message': 'Contacts récupérés avec succès'};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de la récupération',
          'data': <SafeContact>[],
        };
      }
    } catch (e) {
      // En cas d'erreur réseau, retourner les données locales
      final localContacts = await getLocalSafeContacts();
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}', 'data': localContacts, 'isOffline': true};
    }
  }

  /// Ajoute de nouveaux contacts de sécurité
  Future<Map<String, dynamic>> addSafeContacts(List<SafeContactData> contactsData) async {
    try {
      // Validation
      final request = SafeContactRequest(safeNumbers: contactsData);
      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        return {'success': false, 'message': validationErrors.first};
      }

      // Vérifier la limite avec les contacts existants
      final existingContacts = await getLocalSafeContacts();
      if (existingContacts.length + contactsData.length > 5) {
        return {
          'success': false,
          'message': 'Impossible d\'ajouter ${contactsData.length} contacts. Limite de 5 contacts au total.',
        };
      }

      // Envoyer vers l'API
      final response = await postRequest(SafeNumberEndpoints.add, request.toJson());

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final newContactsData = responseData['data'] as List<dynamic>? ?? [];
        final newContacts = newContactsData.map((json) => SafeContact.fromJson(json as Map<String, dynamic>)).toList();

        // Mettre à jour le cache local
        await _addToLocal(newContacts);

        return {'success': true, 'data': newContacts, 'message': 'Contacts ajoutés avec succès'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors de l\'ajout'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de l\'ajout: ${e.toString()}'};
    }
  }

  /// Supprime des contacts de sécurité
  Future<Map<String, dynamic>> deleteSafeContacts(List<String> contactIds) async {
    try {
      if (contactIds.isEmpty) {
        return {'success': false, 'message': 'Aucun contact à supprimer'};
      }

      final response = await http.delete(
        Uri.parse(ApiHelper.buildUrl(SafeNumberEndpoints.delete)),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${getToken()}'},
        body: json.encode({'safeNumberIds': contactIds}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Supprimer du cache local
        await _removeFromLocal(contactIds);

        return {
          'success': true,
          'message': contactIds.length == 1 ? 'Contact supprimé avec succès' : 'Contacts supprimés avec succès',
        };
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors de la suppression'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la suppression: ${e.toString()}'};
    }
  }

  /// Récupère les contacts depuis le cache local
  Future<List<SafeContact>> getLocalSafeContacts() async {
    try {
      final box = Hive.box('auth');
      final contactsData = box.get(_hiveBoxKey, defaultValue: <dynamic>[]) as List<dynamic>;

      return contactsData.map((data) => SafeContact.fromHive(Map<String, dynamic>.from(data as Map))).toList();
    } catch (e) {
      return <SafeContact>[];
    }
  }

  /// Met à jour la catégorie locale d'un contact
  Future<Map<String, dynamic>> updateContactCategory(String contactId, ContactCategory category) async {
    try {
      final contacts = await getLocalSafeContacts();
      final contactIndex = contacts.indexWhere((c) => c.id == contactId);

      if (contactIndex == -1) {
        return {'success': false, 'message': 'Contact non trouvé'};
      }

      // Mettre à jour la catégorie
      contacts[contactIndex] = contacts[contactIndex].copyWith(category: category, updatedAt: DateTime.now());

      // Sauvegarder
      await _saveContactsToLocal(contacts);

      return {'success': true, 'message': 'Catégorie mise à jour'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la mise à jour: ${e.toString()}'};
    }
  }

  /// Simule l'envoi d'un message de test
  Future<Map<String, dynamic>> sendTestMessage(SafeContact contact) async {
    try {
      // Simulation d'envoi (remplacer par vraie logique si nécessaire)
      await Future.delayed(const Duration(seconds: 2));

      // Simuler un succès/échec aléatoire pour les tests
      final success = DateTime.now().millisecond % 2 == 0;

      if (success) {
        return {'success': true, 'message': 'Message de test envoyé à ${contact.description} (${contact.formattedNumber})'};
      } else {
        return {'success': false, 'message': 'Échec d\'envoi du message de test à ${contact.description}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de l\'envoi: ${e.toString()}'};
    }
  }

  /// Récupère la configuration de partage de localisation
  Future<LocationSharingConfig> getLocationSharingConfig() async {
    try {
      final box = Hive.box('auth');
      final configData = box.get(_locationSharingKey, defaultValue: <String, dynamic>{}) as Map<dynamic, dynamic>;

      if (configData.isEmpty) {
        return LocationSharingConfig.defaultConfig;
      }

      return LocationSharingConfig.fromJson(Map<String, dynamic>.from(configData));
    } catch (e) {
      return LocationSharingConfig.defaultConfig;
    }
  }

  /// Met à jour la configuration de partage de localisation
  Future<Map<String, dynamic>> updateLocationSharingConfig(LocationSharingConfig config) async {
    try {
      final box = Hive.box('auth');
      await box.put(_locationSharingKey, config.toJson());

      // TODO: Synchroniser avec le serveur si nécessaire

      return {'success': true, 'message': 'Configuration de partage mise à jour'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la mise à jour: ${e.toString()}'};
    }
  }

  /// Synchronise les contacts du serveur vers le local
  Future<void> _syncToLocal(List<SafeContact> serverContacts) async {
    try {
      // Récupérer les contacts locaux pour préserver les catégories
      final localContacts = await getLocalSafeContacts();
      final localContactsMap = {for (var c in localContacts) c.id: c};

      // Merger les données serveur avec les catégories locales
      final mergedContacts =
          serverContacts.map((serverContact) {
            final localContact = localContactsMap[serverContact.id];
            if (localContact != null) {
              // Préserver la catégorie locale
              return serverContact.copyWith(category: localContact.category);
            }
            return serverContact;
          }).toList();

      await _saveContactsToLocal(mergedContacts);
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  /// Ajoute des contacts au cache local
  Future<void> _addToLocal(List<SafeContact> newContacts) async {
    try {
      final existingContacts = await getLocalSafeContacts();
      final allContacts = [...existingContacts, ...newContacts];
      await _saveContactsToLocal(allContacts);
    } catch (e) {
      print('Erreur lors de l\'ajout local: $e');
    }
  }

  /// Supprime des contacts du cache local
  Future<void> _removeFromLocal(List<String> contactIds) async {
    try {
      final contacts = await getLocalSafeContacts();
      final filteredContacts = contacts.where((c) => !contactIds.contains(c.id)).toList();
      await _saveContactsToLocal(filteredContacts);
    } catch (e) {
      print('Erreur lors de la suppression locale: $e');
    }
  }

  /// Sauvegarde les contacts dans le cache local
  Future<void> _saveContactsToLocal(List<SafeContact> contacts) async {
    try {
      final box = Hive.box('auth');
      final contactsData = contacts.map((c) => c.toHiveMap()).toList();
      await box.put(_hiveBoxKey, contactsData);
    } catch (e) {
      print('Erreur lors de la sauvegarde locale: $e');
    }
  }

  /// Nettoie le cache local
  Future<void> clearLocalCache() async {
    try {
      final box = Hive.box('auth');
      await box.delete(_hiveBoxKey);
      await box.delete(_locationSharingKey);
    } catch (e) {
      print('Erreur lors du nettoyage du cache: $e');
    }
  }
}

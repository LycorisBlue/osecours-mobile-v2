// lib/screens/profile/controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/profile_service.dart';

/// Controller pour gérer la logique de la page de profil
class ProfileController {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController emailController = TextEditingController();

  // État du controller
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _isAddingEmail = false;
  String? _error;
  Map<String, dynamic> _profileData = {};

  // Getters pour l'état
  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;
  bool get isAddingEmail => _isAddingEmail;
  String? get error => _error;
  Map<String, dynamic> get profileData => Map.unmodifiable(_profileData);

  // Getters pour les données du profil
  String get userId => _profileData['userId']?.toString() ?? '';
  String get fullName => _profileData['fullName'] ?? '';
  String get phoneNumber => _profileData['phoneNumber'] ?? '';
  String get email => _profileData['email'] ?? '';
  String? get photo => _profileData['photo'];
  String get role => _profileData['role'] ?? '';
  bool get isActive => _profileData['isActive'] ?? false;

  // Getters calculés
  bool get hasEmail => email.isNotEmpty;
  String get formattedPhoneNumber => _profileService.formatPhoneNumber(phoneNumber);
  String? get fullPhotoUrl => _profileService.getFullPhotoUrl(photo);
  String get userInitials => _profileService.getUserInitials(fullName);

  /// Initialise le controller et charge les données du profil
  Future<void> initialize(Function(void Function()) setState) async {
    await loadProfileData(setState);
  }

  /// Charge les données du profil depuis le service
  Future<void> loadProfileData(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _profileService.getProfileInfo();

      if (result['success']) {
        setState(() {
          _profileData = result['data'] ?? {};
          // Pré-remplir le controller d'email si disponible
          if (hasEmail) {
            emailController.text = email;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Erreur lors du chargement du profil';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Affiche le sélecteur de source d'image
  void showImageSourceSelector(BuildContext context, Function(void Function()) setState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Changer la photo de profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFF3333)),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, setState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFF3333)),
                title: const Text('Choisir dans la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, setState);
                },
              ),
              if (photo != null && photo!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer la photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfilePhoto(setState);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Sélectionne et upload une image
  Future<void> _pickImage(ImageSource source, Function(void Function()) setState) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 70);

      if (image != null) {
        await _uploadImage(File(image.path), setState);
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la sélection de l\'image: ${e.toString()}';
      });
    }
  }

  /// Upload l'image vers le serveur
  Future<void> _uploadImage(File imageFile, Function(void Function()) setState) async {
    setState(() {
      _isUploadingImage = true;
      _error = null;
    });

    try {
      // Valider le fichier avant l'upload
      final validation = _profileService.validateImageFile(imageFile);
      if (!validation['isValid']) {
        setState(() {
          _error = validation['message'];
          _isUploadingImage = false;
        });
        return;
      }

      final result = await _profileService.uploadProfilePicture(imageFile);

      if (result['success']) {
        setState(() {
          _profileData['photo'] = result['data']['photoUrl'];
          _isUploadingImage = false;
        });

        _showSuccessMessage('Photo de profil mise à jour avec succès');
      } else {
        setState(() {
          _error = result['message'] ?? 'Erreur lors de l\'upload';
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'upload: ${e.toString()}';
        _isUploadingImage = false;
      });
    }
  }

  /// Supprime la photo de profil
  Future<void> _removeProfilePhoto(Function(void Function()) setState) async {
    setState(() {
      _profileData['photo'] = null;
    });

    // Mettre à jour localement (vous pouvez ajouter une API pour supprimer côté serveur)
    await _profileService.updateLocalProfileInfo({'photo': null});

    _showSuccessMessage('Photo de profil supprimée');
  }

  /// Affiche le dialog d'ajout d'email
  void showEmailDialog(BuildContext context, Function(void Function()) setState) {
    // Réinitialiser le controller si pas d'email
    if (!hasEmail) {
      emailController.clear();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(hasEmail ? 'Modifier votre email' : 'Ajouter votre email'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Entrez votre email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
                // Restaurer l'email original si modification annulée
                if (hasEmail) {
                  emailController.text = email;
                }
              },
            ),
            TextButton(
              child: Text(hasEmail ? 'Modifier' : 'Ajouter'),
              onPressed: () {
                Navigator.of(context).pop();
                _submitEmail(setState);
              },
            ),
          ],
        );
      },
    );
  }

  /// Soumet l'email vers le serveur
  Future<void> _submitEmail(Function(void Function()) setState) async {
    final emailText = emailController.text.trim();

    // Validation
    if (emailText.isEmpty) {
      setState(() => _error = 'Veuillez entrer un email');
      return;
    }

    if (!_profileService.isValidEmail(emailText)) {
      setState(() => _error = 'Format d\'email invalide');
      return;
    }

    setState(() {
      _isAddingEmail = true;
      _error = null;
    });

    try {
      final result = await _profileService.addEmail(email: emailText);

      if (result['success']) {
        setState(() {
          _profileData['email'] = emailText;
          _isAddingEmail = false;
        });

        _showSuccessMessage(hasEmail ? 'Email modifié avec succès' : 'Email ajouté avec succès');
      } else {
        setState(() {
          _error = result['message'] ?? 'Erreur lors de l\'ajout de l\'email';
          _isAddingEmail = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'ajout de l\'email: ${e.toString()}';
        _isAddingEmail = false;
      });
    }
  }

  /// Rafraîchit les données du profil
  Future<void> refreshProfile(Function(void Function()) setState) async {
    await loadProfileData(setState);
  }

  /// Efface l'erreur
  void clearError(Function(void Function()) setState) {
    setState(() {
      _error = null;
    });
  }

  /// Affiche un message de succès (à implémenter selon votre système de notification)
  void _showSuccessMessage(String message) {
    // Cette méthode peut être étendue pour utiliser votre système de notification
    debugPrint('SUCCESS: $message');
  }

  /// Nettoie les ressources du controller
  void dispose() {
    emailController.dispose();
  }
}

// lib/screens/home/controllers/alert_creation_controller.dart
import 'package:flutter/material.dart';
import '../../../services/alert_service.dart';

/// Controller pour gérer la logique de création d'alertes
class AlertCreationController {
  final AlertService _alertService = AlertService();

  // Controllers pour les champs de texte
  final TextEditingController descriptionController = TextEditingController();

  // État du controller
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // Médias sélectionnés
  final List<MediaFile?> _selectedMedia = List.generate(3, (_) => null);
  bool _hasVideo = false;

  // Getters pour l'état
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<MediaFile?> get selectedMedia => List.unmodifiable(_selectedMedia);
  bool get hasVideo => _hasVideo;
  bool get hasMedia => _selectedMedia.any((media) => media != null);
  int get mediaCount => _selectedMedia.where((media) => media != null).length;

  /// Initialise le controller
  void initialize() {
    _clearError();
    _resetMedia();
  }

  /// Efface les erreurs
  void _clearError() {
    _error = null;
  }

  /// Définit une erreur
  void _setError(String error) {
    _error = error;
  }

  /// Remet à zéro les médias
  void _resetMedia() {
    for (int i = 0; i < _selectedMedia.length; i++) {
      _selectedMedia[i] = null;
    }
    _hasVideo = false;
  }

  /// Affiche le sélecteur de média pour un slot donné
  void showMediaPicker(BuildContext context, int index, Function(void Function()) setState) {
    if (_selectedMedia[index] != null) {
      // Si un média existe déjà, proposer de le remplacer ou le supprimer
      _showMediaOptionsDialog(context, index, setState);
    } else {
      // Sinon, afficher le sélecteur de type de média
      _showMediaTypeDialog(context, index, setState);
    }
  }

  /// Affiche le dialog de sélection du type de média
  void _showMediaTypeDialog(BuildContext context, int index, Function(void Function()) setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir le type de média'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFF3333)),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(index, setState);
                },
              ),
              if (!_hasVideo) // Seulement si pas encore de vidéo
                ListTile(
                  leading: const Icon(Icons.videocam, color: Color(0xFFFF3333)),
                  title: const Text('Enregistrer une vidéo'),
                  subtitle: const Text('Durée maximale : 10 secondes'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo(index, setState);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // /// Affiche les options pour la galerie
  // void _showGalleryOptions(BuildContext context, int index, Function(void Function()) setState) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Galerie'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.photo, color: Color(0xFFFF3333)),
  //               title: const Text('Choisir une photo'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _pickFromGallery(index, false, setState);
  //               },
  //             ),
  //             if (!_hasVideo)
  //               ListTile(
  //                 leading: const Icon(Icons.video_library, color: Color(0xFFFF3333)),
  //                 title: const Text('Choisir une vidéo'),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _pickFromGallery(index, true, setState);
  //                 },
  //               ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  /// Affiche les options pour un média existant
  void _showMediaOptionsDialog(BuildContext context, int index, Function(void Function()) setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Options du média'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility, color: Color(0xFFFF3333)),
                title: const Text('Voir le média'),
                onTap: () {
                  Navigator.pop(context);
                  _viewMedia(context, index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh, color: Color(0xFFFF3333)),
                title: const Text('Remplacer'),
                onTap: () {
                  Navigator.pop(context);
                  _showMediaTypeDialog(context, index, setState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  removeMedia(index, setState);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Prend une photo
  Future<void> _pickImage(int index, Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _clearError();
    });

    try {
      final media = await _alertService.takePhoto();
      if (media != null) {
        setState(() {
          _selectedMedia[index] = media;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _setError(e.toString());
        _isLoading = false;
      });
    }
  }

  /// Enregistre une vidéo
  Future<void> _pickVideo(int index, Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _clearError();
    });

    try {
      final media = await _alertService.recordVideo();
      if (media != null) {
        setState(() {
          _selectedMedia[index] = media;
          _hasVideo = true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _setError(e.toString());
        _isLoading = false;
      });
    }
  }

  /// Sélectionne depuis la galerie
  // Future<void> _pickFromGallery(int index, bool isVideo, Function(void Function()) setState) async {
  //   setState(() {
  //     _isLoading = true;
  //     _clearError();
  //   });

  //   try {
  //     final media = await _alertService.pickFromGallery(isVideo: isVideo);
  //     if (media != null) {
  //       setState(() {
  //         _selectedMedia[index] = media;
  //         if (isVideo) _hasVideo = true;
  //         _isLoading = false;
  //       });
  //     } else {
  //       setState(() => _isLoading = false);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _setError(e.toString());
  //       _isLoading = false;
  //     });
  //   }
  // }

  /// Affiche un média
  void _viewMedia(BuildContext context, int index) {
    final media = _selectedMedia[index];
    if (media != null) {
      // Import de la fonction depuis media_viewer_popup
      // showMediaViewer(
      //   context,
      //   mediaPath: media.file.path,
      //   isVideo: media.isVideo,
      //   fileName: media.fileName,
      // );

      // Pour l'instant, on peut juste afficher un message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Média: ${media.fileName}')));
    }
  }

  /// Supprime un média
  void removeMedia(int index, Function(void Function()) setState) {
    setState(() {
      final media = _selectedMedia[index];
      if (media != null && media.isVideo) {
        _hasVideo = false;
      }
      _selectedMedia[index] = null;
    });
  }

  /// Valide les données avant soumission
  List<String> _validateData(AlertType alertType) {
    final errors = <String>[];

    // Vérifier qu'au moins un média est sélectionné
    if (!hasMedia) {
      errors.add('Au moins une photo ou vidéo est requise');
    }

    // Vérifier la longueur de la description
    if (descriptionController.text.length > 500) {
      errors.add('La description ne peut pas dépasser 500 caractères');
    }

    // Vérifier le nombre de médias
    if (mediaCount > 3) {
      errors.add('Maximum 3 médias autorisés');
    }

    // Vérifier le nombre de vidéos
    final videoCount = _selectedMedia.where((media) => media?.isVideo ?? false).length;
    if (videoCount > 1) {
      errors.add('Maximum 1 vidéo autorisée');
    }

    return errors;
  }

  /// Soumet l'alerte
  Future<Map<String, dynamic>> submitAlert(AlertType alertType, Function(void Function()) setState) async {
    setState(() {
      _isSubmitting = true;
      _clearError();
    });

    try {
      // Validation
      final validationErrors = _validateData(alertType);
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.first);
      }

      // Préparer la liste des médias valides
      final validMedia = _selectedMedia.where((media) => media != null).cast<MediaFile>().toList();

      // Créer l'alerte
      final result = await _alertService.createAlert(
        alertType: alertType,
        description: descriptionController.text,
        mediaFiles: validMedia,
      );

      setState(() => _isSubmitting = false);

      if (result['success']) {
        // Réinitialiser le formulaire en cas de succès
        _resetForm();
        return {'success': true, 'message': result['message'] ?? 'Alerte envoyée avec succès'};
      } else {
        _setError(result['message'] ?? 'Erreur lors de l\'envoi');
        return {'success': false, 'message': result['message'] ?? 'Erreur lors de l\'envoi'};
      }
    } catch (e) {
      setState(() {
        _setError(e.toString());
        _isSubmitting = false;
      });

      return {'success': false, 'message': e.toString()};
    }
  }

  /// Remet à zéro le formulaire
  void _resetForm() {
    descriptionController.clear();
    _resetMedia();
    _clearError();
  }

  /// Nettoie les ressources
  void dispose() {
    descriptionController.dispose();
  }
}

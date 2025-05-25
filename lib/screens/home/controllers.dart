// lib/screens/home/controllers.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/location_service.dart';
import '../../services/alert_service.dart';

/// Controller principal pour la page d'accueil
class HomeController {
  // Services
  final LocationService _locationService = LocationService();
  final AlertService _alertService = AlertService();

  // État de la page
  bool _isLoading = false;
  String _currentAddress = 'Chargement...';
  Map<String, dynamic>? _latestAlert;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String get currentAddress => _currentAddress;
  Map<String, dynamic>? get latestAlert => _latestAlert;
  String? get error => _error;

  /// Initialise les données de la page d'accueil
  Future<void> initialize(Function(void Function()) setState) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Charger l'adresse et la dernière alerte en parallèle
      await Future.wait([_loadCurrentAddress(setState), _loadLatestAlert(setState)]);
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Charge l'adresse actuelle
  Future<void> _loadCurrentAddress(Function(void Function()) setState) async {
    try {
      final address = await LocationService.getCurrentAddress();
      setState(() {
        _currentAddress = address;
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Localisation indisponible';
      });
    }
  }

  /// Charge la dernière alerte
  Future<void> _loadLatestAlert(Function(void Function()) setState) async {
    try {
      final result = await _alertService.getLatestAlert();
      if (result['success']) {
        setState(() {
          _latestAlert = result['data'];
        });
      }
    } catch (e) {
      // Pas d'alerte ou erreur - ce n'est pas critique
      setState(() {
        _latestAlert = null;
      });
    }
  }

  /// Rafraîchit toutes les données
  Future<void> refresh(Function(void Function()) setState) async {
    await initialize(setState);
  }

  /// Met à jour uniquement l'adresse
  Future<void> updateAddress(Function(void Function()) setState) async {
    await _loadCurrentAddress(setState);
  }
}

/// Controller pour la gestion des notifications
class NotificationController {
  /// Récupère le nombre de notifications non lues
  int getUnreadNotificationsCount() {
    try {
      final box = Hive.box('notifications');
      if (!box.isOpen) return 0;

      final notifications =
          box.values.where((item) {
            if (item is Map) {
              return !(item['is_read'] as bool? ?? true);
            }
            return false;
          }).length;

      return notifications;
    } catch (e) {
      return 0;
    }
  }

  /// Écoute les changements de notifications
  Stream<int> watchNotifications() {
    try {
      final box = Hive.box('notifications');
      return box.watch().map((event) => getUnreadNotificationsCount());
    } catch (e) {
      return Stream.value(0);
    }
  }
}

/// Controller pour la grille d'alertes
class AlertGridController {
  final AlertService _alertService = AlertService();

  /// Types d'alertes avec leurs configurations
  final List<AlertTypeConfig> alertTypes = [
    AlertTypeConfig(type: AlertType.accidents, title: 'Accidents', color: const Color(0xFFFF3333), icon: Icons.car_crash),
    AlertTypeConfig(
      type: AlertType.incendies,
      title: 'Incendies',
      color: const Color(0xFFF1C01F),
      icon: Icons.local_fire_department,
    ),
    AlertTypeConfig(type: AlertType.inondations, title: 'Inondations', color: const Color(0xFF189FFF), icon: Icons.water),
    AlertTypeConfig(type: AlertType.malaises, title: 'Malaises', color: const Color(0xFFFF6933), icon: Icons.medical_services),
    AlertTypeConfig(type: AlertType.noyade, title: 'Noyade', color: const Color(0xFF43BE33), icon: Icons.pool),
    AlertTypeConfig(type: AlertType.autre, title: 'Autre', color: const Color(0xFF717171), icon: Icons.more_horiz),
  ];

  /// Affiche le dialog de création d'alerte
  void showAlertDialog(BuildContext context, AlertType alertType) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertCreationDialog(alertType: alertType, alertService: _alertService),
    );
  }
}

/// Configuration pour un type d'alerte
class AlertTypeConfig {
  final AlertType type;
  final String title;
  final Color color;
  final IconData icon;

  AlertTypeConfig({required this.type, required this.title, required this.color, required this.icon});
}

/// Dialog pour la création d'une alerte
class AlertCreationDialog extends StatefulWidget {
  final AlertType alertType;
  final AlertService alertService;

  const AlertCreationDialog({super.key, required this.alertType, required this.alertService});

  @override
  State<AlertCreationDialog> createState() => _AlertCreationDialogState();
}

class _AlertCreationDialogState extends State<AlertCreationDialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<MediaFile?> _selectedMedia = List.generate(3, (_) => null);
  bool _isLoading = false;
  bool _hasVideo = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Affiche le sélecteur de média
  void _showMediaPicker(int index) {
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
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(index);
                },
              ),
              if (!_hasVideo)
                ListTile(
                  leading: const Icon(Icons.videocam, color: Color(0xFFFF3333)),
                  title: const Text('Enregistrer une vidéo'),
                  subtitle: const Text('Durée maximale : 10 secondes'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickVideo(index);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Prend une photo
  Future<void> _pickImage(int index) async {
    try {
      final media = await widget.alertService.takePhoto();
      if (media != null) {
        setState(() {
          _selectedMedia[index] = media;
        });
      }
    } catch (e) {
      _showErrorMessage('Impossible de prendre une photo');
    }
  }

  /// Enregistre une vidéo
  Future<void> _pickVideo(int index) async {
    try {
      final media = await widget.alertService.recordVideo();
      if (media != null) {
        setState(() {
          _selectedMedia[index] = media;
          _hasVideo = true;
        });
      }
    } catch (e) {
      _showErrorMessage('Impossible d\'enregistrer une vidéo');
    }
  }

  /// Supprime un média
  void _removeMedia(int index) {
    setState(() {
      if (_selectedMedia[index]?.isVideo ?? false) {
        _hasVideo = false;
      }
      _selectedMedia[index] = null;
    });
  }

  /// Affiche un message d'erreur
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  /// Soumet l'alerte
  Future<void> _submitAlert() async {
    // Vérifier qu'au moins un média est sélectionné
    final validMedia = _selectedMedia.where((media) => media != null).cast<MediaFile>().toList();
    if (validMedia.isEmpty) {
      _showErrorMessage('Veuillez ajouter au moins une photo ou vidéo');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.alertService.createAlert(
        alertType: widget.alertType,
        description: _messageController.text.isEmpty ? 'Aucune description soumise' : _messageController.text,
        mediaFiles: validMedia,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Alerte envoyée avec succès'), backgroundColor: Colors.green));
          Navigator.of(context).pop(); // Fermer le dialog
        } else {
          _showErrorMessage(result['message'] ?? 'Erreur lors de l\'envoi');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = _selectedMedia.any((media) => media != null);

    return AlertDialog(
      title: Text('Alerte ${widget.alertType.label}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section médias
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(3, (index) {
              final media = _selectedMedia[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF3333)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    media == null
                        ? InkWell(
                          onTap: () => _showMediaPicker(index),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Color(0xFFFF3333)),
                              Text('Ajouter', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        )
                        : Stack(
                          children: [
                            if (media.isVideo)
                              const Center(child: Icon(Icons.play_circle_outline, size: 40))
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(media.file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Champ de message
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Description (optionnelle)...', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: !hasMedia || _isLoading ? null : _submitAlert,
          child:
              _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Envoyer'),
        ),
      ],
    );
  }
}

// lib/screens/alerts/widgets/alert_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/themes.dart';
import 'status_badge.dart';

/// Bottom sheet pleine hauteur pour afficher les détails d'une alerte
class AlertDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> alert;
  static const String baseUrl = 'http://46.202.170.228:3000';

  const AlertDetailBottomSheet({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.95,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: Column(children: [_buildHeader(context), Expanded(child: SingleChildScrollView(child: _buildContent()))]),
    );
  }

  /// En-tête du bottom sheet avec bouton fermer
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.textLight.withOpacity(0.1), width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Détails de l\'alerte', style: AppTextStyles.heading3),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.text, size: AppSizes.iconMedium),
          ),
        ],
      ),
    );
  }

  /// Contenu principal du bottom sheet
  Widget _buildContent() {
    final description = alert['description'] ?? '';
    final status = alert['status'] ?? 'EN_ATTENTE';
    final category = alert['category'] ?? 'Autre';
    final address = alert['address'] ?? 'Adresse inconnue';
    final createdAt = alert['createdAt'] ?? '';
    final locationLat = double.tryParse(alert['location_lat']?.toString() ?? '0') ?? 0.0;
    final locationLng = double.tryParse(alert['location_lng']?.toString() ?? '0') ?? 0.0;
    final media = alert['media'] as List<dynamic>? ?? [];
    final intervention = alert['intervention'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte avec localisation
        _buildMapSection(locationLat, locationLng),

        // Section statut
        _buildStatusSection(status),

        // Informations générales
        _buildGeneralInfoSection(category, address, description, createdAt),

        // Section intervention (si disponible)
        if (intervention != null) _buildInterventionSection(intervention),

        // Section médias (si disponibles)
        if (media.isNotEmpty) _buildMediaSection(media),

        // Boutons d'action
        _buildActionSection(),

        SizedBox(height: AppSizes.spacingLarge),
      ],
    );
  }

  /// Section carte avec localisation
  Widget _buildMapSection(double lat, double lng) {
    return Container(
      height: 200,
      margin: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.textLight.withOpacity(0.2), width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child:
          lat != 0.0 && lng != 0.0
              ? FlutterMap(
                options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 15),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: LatLng(lat, lng),
                        child: Icon(Icons.location_on, color: AppColors.primary, size: AppSizes.iconLarge),
                      ),
                    ],
                  ),
                ],
              )
              : Container(
                color: AppColors.background,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: AppSizes.iconLarge, color: AppColors.textLight),
                      SizedBox(height: AppSizes.spacingSmall),
                      Text('Localisation non disponible', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                    ],
                  ),
                ),
              ),
    );
  }

  /// Section statut de l'alerte
  Widget _buildStatusSection(String status) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Statut de l\'alerte : ', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            StatusBadge(status: status),
          ],
        ),
      ),
    );
  }

  /// Section informations générales
  Widget _buildGeneralInfoSection(String category, String address, String description, String createdAt) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informations générales', style: AppTextStyles.heading3),
          SizedBox(height: AppSizes.spacingMedium),

          _buildInfoRow(Icons.category, 'Catégorie', category, AppColors.primary),
          SizedBox(height: AppSizes.spacingMedium),

          _buildInfoRow(Icons.location_on, 'Localisation', address, Colors.red),
          SizedBox(height: AppSizes.spacingMedium),

          _buildInfoRow(Icons.access_time, 'Date et heure', _formatDateTime(createdAt), AppColors.textLight),

          if (description.isNotEmpty && description != 'Aucune description soumise') ...[
            SizedBox(height: AppSizes.spacingMedium),
            _buildInfoRow(Icons.description, 'Description', description, AppColors.primary),
          ],
        ],
      ),
    );
  }

  /// Section intervention
  Widget _buildInterventionSection(Map<String, dynamic> intervention) {
    final rescueMember = intervention['rescueMember'] as Map<String, dynamic>?;
    final interventionStatus = intervention['status'] ?? '';
    final arrivalTime = intervention['arrivalTime'];

    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Détails de l\'intervention', style: AppTextStyles.heading3),
          SizedBox(height: AppSizes.spacingMedium),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusCard)),
            child: Column(
              children: [
                if (rescueMember != null) ...[
                  _buildInfoRow(
                    Icons.person,
                    'Secouriste',
                    "${rescueMember['firstName']} ${rescueMember['lastName']}",
                    AppColors.primary,
                  ),
                  SizedBox(height: AppSizes.spacingMedium),

                  _buildInfoRow(Icons.badge, 'Position', rescueMember['position'] ?? '', AppColors.primary),
                  SizedBox(height: AppSizes.spacingMedium),
                ],

                _buildInfoRow(
                  Icons.timer,
                  'Statut intervention',
                  _formatInterventionStatus(interventionStatus),
                  AppColors.primary,
                ),

                if (arrivalTime != null) ...[
                  SizedBox(height: AppSizes.spacingMedium),
                  _buildInfoRow(Icons.schedule, 'Heure d\'arrivée', _formatDateTime(arrivalTime), AppColors.primary),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section médias
  /// 
  /// /// Section médias
  Widget _buildMediaSection(List<dynamic> media) {
    // Debug pour voir les liens complets des images
    print('=== DEBUG MÉDIAS ALERTE ===');
    print('Nombre de médias: ${media.length}');

    for (int i = 0; i < media.length; i++) {
      final mediaItem = media[i];

      // Les vraies clés sont : media_type et media_url (pas type et url)
      final mediaUrl = mediaItem['media_url'] ?? '';
      final mediaType = mediaItem['media_type']?.toString().toUpperCase() ?? 'UNKNOWN';
      final fullUrl = '$baseUrl/$mediaUrl';

      print('Média $i:');
      print('  - Type: $mediaType');
      print('  - URL relative: $mediaUrl');
      print('  - URL complète: $fullUrl');
      print('  - Objet complet: $mediaItem');
    }
    print('==========================');

    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photos & Vidéos envoyées', style: AppTextStyles.heading3),
          SizedBox(height: AppSizes.spacingMedium),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: AppSizes.spacingMedium,
            crossAxisSpacing: AppSizes.spacingMedium,
            children:
                media.map((mediaItem) {
                  final mediaUrl = mediaItem['media_url'] ?? ''; // Changé ici
                  final isVideo = mediaItem['media_type']?.toString().toUpperCase() == 'VIDEO'; // Changé ici
                  final fullUrl = '$baseUrl/$mediaUrl';

                  return _buildMediaContainer(fullUrl, isVideo);
                }).toList(),
          ),
        ],
      ),
    );
  }
/// Section boutons d'action
  Widget _buildActionSection() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Implémenter l'action d'envoi de message aux secours
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
          ),
          icon: Icon(Icons.message, color: AppColors.white),
          label: Text('Envoyer un message aux secours', style: AppTextStyles.buttonText),
        ),
      ),
    );
  }

  /// Widget pour une ligne d'information
  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: iconColor),
        SizedBox(width: AppSizes.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w600)),
              SizedBox(height: AppSizes.spacingXSmall),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget pour un conteneur de média
  Widget _buildMediaContainer(String mediaUrl, bool isVideo) {
    return GestureDetector(
      onTap: () {
        // TODO: Ouvrir le viewer de média
        // showMediaViewer(context, mediaPath: mediaUrl, isVideo: isVideo, isNetworkImage: true);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          border: Border.all(color: AppColors.textLight.withOpacity(0.2), width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                    color: AppColors.primary,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  child: Center(child: Icon(Icons.error_outline, color: AppColors.textLight, size: AppSizes.iconMedium)),
                );
              },
            ),
            if (isVideo)
              Center(
                child: Container(
                  padding: EdgeInsets.all(AppSizes.spacingSmall),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow, color: AppColors.white, size: AppSizes.iconMedium),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Formate la date et l'heure
  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  /// Formate le statut d'intervention
  String _formatInterventionStatus(String status) {
    switch (status.toUpperCase()) {
      case 'EN_COURS':
        return 'En cours';
      case 'TERMINEE':
        return 'Terminée';
      default:
        return status;
    }
  }
}

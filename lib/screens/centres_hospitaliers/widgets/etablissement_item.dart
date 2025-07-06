// lib/screens/centres_hospitaliers/widgets/etablissement_item.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';

class EtablissementItem extends StatelessWidget {
  final Map<String, dynamic> etablissement;
  final VoidCallback? onTap;

  const EtablissementItem({super.key, required this.etablissement, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.textLight.withOpacity(0.1), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            child: Row(
              children: [
                // Icône selon la catégorie
                Container(
                  padding: EdgeInsets.all(AppSizes.spacingSmall),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Icon(_getCategoryIcon(), size: AppSizes.iconMedium, color: _getCategoryColor()),
                ),
                SizedBox(width: AppSizes.spacingMedium),

                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom de l'établissement
                      Text(
                        etablissement['nom']?.isNotEmpty == true ? etablissement['nom'] : 'Établissement de santé',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.spacingXSmall),

                      // Localisation (quartier + commune)
                      Text(
                        _buildLocationText(),
                        style: AppTextStyles.caption.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Badge de catégorie
                      SizedBox(height: AppSizes.spacingSmall),
                      _buildCategoryBadge(),
                    ],
                  ),
                ),

                // Actions à droite
                Column(
                  children: [
                    // Distance
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Text(
                        '${(etablissement['distance'] ?? 0).toStringAsFixed(1)} km',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingSmall),

                    // Bouton directions
                    GestureDetector(
                      onTap: () => _openDirections(etablissement),
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.spacingSmall),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        child: Icon(Icons.directions, size: AppSizes.iconSmall, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit le texte de localisation (quartier, commune)
  String _buildLocationText() {
    List<String> locationParts = [];

    if (etablissement['quartier']?.isNotEmpty == true) {
      locationParts.add(etablissement['quartier']);
    }

    if (etablissement['commune']?.isNotEmpty == true) {
      locationParts.add(etablissement['commune']);
    }

    return locationParts.isNotEmpty ? locationParts.join(', ') : 'Localisation non disponible';
  }

  /// Badge de catégorie
  Widget _buildCategoryBadge() {
    final category = etablissement['categorie'] ?? 'Établissement';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _getCategoryColor().withOpacity(0.3)),
      ),
      child: Text(
        category,
        style: AppTextStyles.caption.copyWith(color: _getCategoryColor(), fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }

  /// Retourne l'icône selon la catégorie
  IconData _getCategoryIcon() {
    final category = etablissement['categorie'] ?? '';
    switch (category.toLowerCase()) {
      case 'hôpital':
        return Icons.local_hospital;
      case 'clinique médicale':
        return Icons.medical_services;
      default:
        return Icons.health_and_safety;
    }
  }

  /// Retourne la couleur selon la catégorie
  Color _getCategoryColor() {
    final category = etablissement['categorie'] ?? '';
    switch (category.toLowerCase()) {
      case 'hôpital':
        return AppColors.primary; // Rouge pour les hôpitaux
      case 'clinique médicale':
        return Colors.blue; // Bleu pour les cliniques
      default:
        return Colors.green; // Vert par défaut
    }
  }

  /// Ouvre les directions vers l'établissement
  void _openDirections(Map<String, dynamic> etablissement) async {
    try {
      final coordinates = etablissement['coordinates'];
      if (coordinates == null) {
        debugPrint('Coordonnées non disponibles pour cet établissement');
        return;
      }

      final lat = coordinates['latitude'];
      final lng = coordinates['longitude'];
      final name = etablissement['nom'] ?? 'Établissement de santé';

      debugPrint('Tentative d\'ouverture des directions pour: $name');
      debugPrint('Coordonnées: $lat, $lng');

      // Essayer d'abord avec Google Maps
      final googleMapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name');

      debugPrint('URI généré: $googleMapsUri');

      final canLaunch = await canLaunchUrl(googleMapsUri);
      debugPrint('Can launch URL: $canLaunch');

      if (canLaunch) {
        final launched = await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        debugPrint('Launch result: $launched');
      } else {
        // Fallback avec geo: scheme
        final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
        if (await canLaunchUrl(geoUri)) {
          await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('Impossible d\'ouvrir une application de navigation');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'ouverture des directions: $e');
    }
  }
}

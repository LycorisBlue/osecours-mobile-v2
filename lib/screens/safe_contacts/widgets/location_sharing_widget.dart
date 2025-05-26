// lib/screens/safe_contacts/widgets/location_sharing_widget.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import '../../../data/models/safe_contact_models.dart';

/// Widget pour gérer la configuration de partage de localisation
class LocationSharingWidget extends StatelessWidget {
  final LocationSharingConfig config;
  final Function(bool) onToggle;
  final VoidCallback onModeSelect;
  final bool isUpdating;

  const LocationSharingWidget({
    super.key,
    required this.config,
    required this.onToggle,
    required this.onModeSelect,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône et titre
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.spacingSmall),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Icon(Icons.location_on, color: AppColors.primary, size: AppSizes.iconMedium),
              ),

              SizedBox(width: AppSizes.spacingMedium),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Partage de localisation', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: AppSizes.spacingXSmall),
                    Text(
                      'Partager votre position avec vos proches',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),

              // Switch avec indicateur de chargement
              if (isUpdating)
                SizedBox(
                  width: AppSizes.iconMedium,
                  height: AppSizes.iconMedium,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else
                CupertinoSwitch(value: config.isEnabled, onChanged: onToggle, activeColor: AppColors.primary),
            ],
          ),

          // Configuration du mode (visible seulement si activé)
          if (config.isEnabled) ...[
            SizedBox(height: AppSizes.spacingMedium),

            Container(
              padding: EdgeInsets.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.textLight.withOpacity(0.1), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode de partage',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSizes.spacingSmall),

                  // Sélecteur de mode
                  InkWell(
                    onTap: onModeSelect,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingSmall, horizontal: AppSizes.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(_getModeIcon(config.mode), color: AppColors.primary, size: AppSizes.iconMedium),
                          SizedBox(width: AppSizes.spacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(config.mode.label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                Text(config.mode.description, style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textLight, size: AppSizes.iconMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dernière mise à jour
            if (config.lastUpdated != null) ...[
              SizedBox(height: AppSizes.spacingSmall),
              Text(
                'Mis à jour ${_formatLastUpdate(config.lastUpdated!)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
              ),
            ],
          ],

          // Message d'information
          if (!config.isEnabled) ...[
            SizedBox(height: AppSizes.spacingMedium),
            Container(
              padding: EdgeInsets.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: AppSizes.iconMedium),
                  SizedBox(width: AppSizes.spacingMedium),
                  Expanded(
                    child: Text(
                      'Activez cette option pour permettre à vos proches de vous localiser en cas d\'urgence.',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Obtient l'icône appropriée selon le mode
  IconData _getModeIcon(LocationSharingMode mode) {
    switch (mode) {
      case LocationSharingMode.always:
        return Icons.location_on;
      case LocationSharingMode.emergency:
        return Icons.emergency;
    }
  }

  /// Formate la dernière mise à jour
  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return "à l'instant";
    } else if (difference.inMinutes < 60) {
      return "il y a ${difference.inMinutes} min";
    } else if (difference.inHours < 24) {
      return "il y a ${difference.inHours}h";
    } else {
      final days = difference.inDays;
      if (days == 1) {
        return "hier";
      } else if (days < 7) {
        return "il y a $days jours";
      } else {
        return "il y a plus d'une semaine";
      }
    }
  }
}

/// Widget compact pour afficher le statut de partage
class LocationSharingStatus extends StatelessWidget {
  final LocationSharingConfig config;

  const LocationSharingStatus({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: config.isEnabled ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: (config.isEnabled ? Colors.green : Colors.grey).withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.isEnabled ? Icons.location_on : Icons.location_off,
            size: AppSizes.iconSmall,
            color: config.isEnabled ? Colors.green : Colors.grey,
          ),
          SizedBox(width: AppSizes.spacingXSmall),
          Text(
            config.isEnabled ? 'Partage activé' : 'Partage désactivé',
            style: AppTextStyles.caption.copyWith(
              color: config.isEnabled ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

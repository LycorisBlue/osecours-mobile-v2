// lib/screens/alerts/widgets/alert_card.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/themes.dart';
import 'status_badge.dart';

/// Widget de carte pour afficher une alerte dans la liste
class AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onTap;

  const AlertCard({super.key, required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final description = alert['description'] ?? '';
    final status = alert['status'] ?? 'EN_ATTENTE';
    final category = alert['category'] ?? 'Autre';
    final createdAt = alert['createdAt'] ?? '';
    final address = alert['address'] ?? 'Adresse inconnue';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard - 2),
          border: Border.all(color: AppColors.textLight.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec catégorie et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _getCategoryIcon(category),
                    SizedBox(width: AppSizes.spacingSmall),
                    Text(category, style: AppTextStyles.label.copyWith(color: AppColors.text, fontWeight: FontWeight.w600)),
                  ],
                ),
                StatusBadge(status: status),
              ],
            ),

            SizedBox(height: AppSizes.spacingSmall),

            // Description
            if (description.isNotEmpty && description != 'Aucune description soumise')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: AppTextStyles.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: AppSizes.spacingSmall),
                ],
              ),

            // Localisation
            Row(
              children: [
                Icon(Icons.location_on, size: AppSizes.iconSmall, color: AppColors.textLight),
                SizedBox(width: AppSizes.spacingXSmall),
                Expanded(
                  child: Text(
                    _formatAddress(address),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizes.spacingSmall),

            // Ligne du bas avec date et action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                Row(
                  children: [
                    Text(
                      'Voir détails',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: AppSizes.spacingXSmall),
                    Icon(Icons.arrow_forward_ios, size: AppSizes.iconSmall, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Obtient l'icône selon la catégorie
  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color iconColor;

    switch (category.toLowerCase()) {
      case 'accidents':
        iconData = Icons.car_crash;
        iconColor = Colors.red;
        break;
      case 'incendies':
        iconData = Icons.local_fire_department;
        iconColor = Colors.orange;
        break;
      case 'inondations':
        iconData = Icons.water;
        iconColor = Colors.blue;
        break;
      case 'malaises':
        iconData = Icons.medical_services;
        iconColor = Colors.purple;
        break;
      case 'noyade':
        iconData = Icons.pool;
        iconColor = Colors.blue.shade700;
        break;
      default:
        iconData = Icons.warning;
        iconColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(AppSizes.spacingXSmall),
      decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      child: Icon(iconData, size: AppSizes.iconMedium, color: iconColor),
    );
  }

  /// Formate l'adresse
  String _formatAddress(String address) {
    if (address.isEmpty || address == 'Adresse inconnue') {
      return 'Localisation non disponible';
    }

    // Limiter la longueur de l'adresse affichée
    if (address.length > 50) {
      return '${address.substring(0, 47)}...';
    }

    return address;
  }

  /// Formate le temps écoulé
  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return "À l'instant";
      } else if (difference.inMinutes < 60) {
        return "Il y a ${difference.inMinutes} min";
      } else if (difference.inHours < 24) {
        return "Il y a ${difference.inHours}h";
      } else {
        final days = difference.inDays;
        if (days == 1) {
          return "Il y a 1 jour";
        } else if (days < 7) {
          return "Il y a $days jours";
        } else {
          final weeks = (days / 7).floor();
          if (weeks == 1) {
            return "Il y a 1 semaine";
          } else if (weeks < 4) {
            return "Il y a $weeks semaines";
          } else {
            final months = (days / 30).floor();
            return "Il y a $months mois";
          }
        }
      }
    } catch (e) {
      return dateString;
    }
  }
}

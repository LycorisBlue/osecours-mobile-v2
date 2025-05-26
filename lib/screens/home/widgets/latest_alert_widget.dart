// lib/screens/home/widgets/latest_alert_widget.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/themes.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../services/alert_service.dart';
import '../../../services/navigation_service.dart';
import '../../alerts/widgets/alert_detail_bottom_sheet.dart';

class LatestAlertWidget extends StatelessWidget {
  final Map<String, dynamic>? latestAlert;
  final VoidCallback onViewAllAlerts;
  final Function(String) onAlertTap;

  LatestAlertWidget({super.key, this.latestAlert, required this.onViewAllAlerts, required this.onAlertTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre et bouton "Tout voir"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes alertes', style: AppTextStyles.heading3),
              TextButton(
                onPressed: () => Routes.navigateTo(Routes.alerts),
                child: Text(
                  'Tout voir',
                  style: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingMedium),

          // Contenu de l'alerte
          if (latestAlert == null) _buildEmptyState() else _buildAlertCard(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Text("Aucune alerte n'a été émise", style: TextStyle(fontSize: AppSizes.bodyMedium, color: AppColors.textLight));
  }

  Widget _buildAlertCard(BuildContext context) {
    final description = latestAlert!['description'] ?? '';
    final status = latestAlert!['status'] ?? 'EN_ATTENTE';
    final createdAt = latestAlert!['createdAt'] ?? '';
    final alertId = latestAlert!['id']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _showAlertDetails(context, latestAlert!),
      child: Container(
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status et temps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getStatusIcon(status), color: AppColors.primary, size: 24),
                    SizedBox(width: AppSizes.spacingSmall),
                    Text(
                      _formatStatus(status),
                      style: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                  ],
                ),
                Text(_formatTime(createdAt), style: TextStyle(fontSize: AppSizes.bodySmall, color: AppColors.textLight)),
              ],
            ),
            SizedBox(height: AppSizes.spacingSmall),

            // Description
            Text(
              description,
              style: TextStyle(fontSize: AppSizes.bodySmall, color: AppColors.text),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.spacingMedium),

            // Action
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Contacter les secours', style: TextStyle(fontSize: AppSizes.bodySmall, color: AppColors.primary)),
                Icon(Icons.local_fire_department, color: AppColors.primary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche les détails de l'alerte dans un bottom sheet
  void _showAlertDetails(BuildContext context, Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertDetailBottomSheet(alert: alert),
    );
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'EN_COURS':
        return 'En cours';
      case 'RESOLUE':
        return 'Résolue';
      default:
        return 'En attente';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'EN_ATTENTE':
        return Icons.hourglass_empty;
      case 'ACCEPTEE':
        return Icons.check_circle;
      case 'EN_COURS':
        return Icons.autorenew;
      case 'RESOLUE':
        return Icons.done_all;
      default:
        return Icons.hourglass_empty;
    }
  }

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
        return "Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
      }
    } catch (e) {
      return dateString;
    }
  }
}

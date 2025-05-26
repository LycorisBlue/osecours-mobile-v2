// lib/screens/alerts/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/sizes.dart';
import 'package:osecours/core/constants/themes.dart';

/// Widget badge pour afficher le statut d'une alerte avec couleurs appropriées
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: statusInfo['color'].withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo['icon'], size: AppSizes.iconSmall, color: statusInfo['color']),
          SizedBox(width: AppSizes.spacingXSmall),
          Text(
            statusInfo['label'],
            style: AppTextStyles.caption.copyWith(color: statusInfo['color'], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Obtient les informations de style selon le statut
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'EN_ATTENTE':
        return {'label': 'En attente', 'color': Colors.orange, 'icon': Icons.hourglass_empty};
      case 'ACCEPTEE':
        return {'label': 'Acceptée', 'color': Colors.blue, 'icon': Icons.check_circle_outline};
      case 'EN_COURS':
        return {'label': 'En cours', 'color': Colors.green, 'icon': Icons.autorenew};
      case 'RESOLUE':
        return {'label': 'Résolue', 'color': Colors.grey, 'icon': Icons.done_all};
      default:
        return {'label': 'En attente', 'color': Colors.orange, 'icon': Icons.hourglass_empty};
    }
  }
}

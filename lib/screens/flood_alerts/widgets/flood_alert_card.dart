// lib/screens/flood_alerts/widgets/flood_alert_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/themes.dart';
import '../../../data/models/flood_alert_models.dart';

/// Widget pour afficher une carte d'alerte d'inondation
class FloodAlertCard extends StatelessWidget {
  final FloodAlert alert;
  final VoidCallback onTap;

  const FloodAlertCard({super.key, required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône et adresse
              Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 24),
                  SizedBox(width: AppSizes.spacingSmall),
                  Expanded(child: Text(alert.address, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
                ],
              ),

              SizedBox(height: AppSizes.spacingSmall),

              // Description
              Text(alert.description, style: AppTextStyles.bodySmall),

              SizedBox(height: AppSizes.spacingSmall),

              // Statut et distance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                        decoration: BoxDecoration(
                          color: alert.getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          alert.getStatusText(),
                          style: TextStyle(color: alert.getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingSmall),
                      Text("À ${alert.distance.toStringAsFixed(1)} km", style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

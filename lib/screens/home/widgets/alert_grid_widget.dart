// lib/screens/home/widgets/alert_grid_widget.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/themes.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../controllers.dart';

class AlertGridWidget extends StatelessWidget {
  const AlertGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final alertGridController = AlertGridController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Envoyer une alerte',
                style: AppTextStyles.heading3,
              ),
              SizedBox(height: AppSizes.spacingXSmall),
              Text(
                'Appuyez sur un bouton pour soumettre une alerte',
                style: TextStyle(fontSize: AppSizes.bodyMedium, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.spacingLarge),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: AppSizes.spacingMedium,
            crossAxisSpacing: AppSizes.spacingMedium,
            children:
                alertGridController.alertTypes.map((alertConfig) {
                  return _buildAlertButton(
                    context: context,
                    config: alertConfig,
                    onTap: () => alertGridController.showAlertDialog(context, alertConfig.type),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertButton({required BuildContext context, required AlertTypeConfig config, required VoidCallback onTap}) {
    return Material(
      color: config.color,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      elevation: AppSizes.elevationSmall,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.all(AppSizes.spacingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(config.icon, size: 28, color: AppColors.white),
              SizedBox(height: AppSizes.spacingSmall),
              Text(
                config.title,
                style: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.w600, color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

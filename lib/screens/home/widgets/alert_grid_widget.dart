// lib/screens/home/widgets/alert_grid_widget.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/themes.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../services/alert_service.dart';
import 'alert_dialog.dart' as custom_dialog;

class AlertGridWidget extends StatelessWidget {
  const AlertGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Envoyer une alerte', style: AppTextStyles.heading3),
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
            children: _buildAlertButtons(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAlertButtons(BuildContext context) {
    final alertTypes = [
      _AlertTypeConfig(type: AlertType.accidents, title: 'Accidents', color: const Color(0xFFFF3333), icon: Icons.car_crash),
      _AlertTypeConfig(
        type: AlertType.incendies,
        title: 'Incendies',
        color: const Color(0xFFF1C01F),
        icon: Icons.local_fire_department,
      ),
      _AlertTypeConfig(type: AlertType.inondations, title: 'Inondations', color: const Color(0xFF189FFF), icon: Icons.water),
      _AlertTypeConfig(type: AlertType.malaises, title: 'Malaises', color: const Color(0xFFFF6933), icon: Icons.medical_services),
      _AlertTypeConfig(type: AlertType.noyade, title: 'Agressions', color: const Color(0xFF43BE33), icon: Icons.crisis_alert),
      _AlertTypeConfig(type: AlertType.autre, title: 'Autre', color: const Color(0xFF717171), icon: Icons.more_horiz),
    ];

    return alertTypes.map((config) => _buildAlertButton(context, config)).toList();
  }

  Widget _buildAlertButton(BuildContext context, _AlertTypeConfig config) {
    return Material(
      color: config.color,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      elevation: AppSizes.elevationSmall,
      child: InkWell(
        onTap: () => _showAlertDialog(context, config.type),
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

  void _showAlertDialog(BuildContext context, AlertType alertType) {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture en tapant à côté
      builder: (BuildContext context) => custom_dialog.AlertDialog(alertType: alertType),
    ).then((result) {
      // Si l'alerte a été envoyée avec succès (result == true)
      if (result == true) {
        // Ici on peut ajouter des actions supplémentaires si nécessaire
        // Par exemple : rafraîchir la liste des alertes, naviguer vers une autre page, etc.
        _onAlertSentSuccessfully(context);
      }
    });
  }

  void _onAlertSentSuccessfully(BuildContext context) {
    // Actions à effectuer après l'envoi réussi d'une alerte
    // Par exemple : déclencher un refresh de la page home, envoyer un event, etc.

    // Pour l'instant, on peut juste logger ou ne rien faire
    // Le message de succès est déjà affiché par le dialog
    debugPrint('Alerte envoyée avec succès');

    // Si on veut déclencher un refresh de la page parent, on peut utiliser un callback
    // ou un state management solution
  }
}

/// Configuration pour un type d'alerte
class _AlertTypeConfig {
  final AlertType type;
  final String title;
  final Color color;
  final IconData icon;

  const _AlertTypeConfig({required this.type, required this.title, required this.color, required this.icon});
}

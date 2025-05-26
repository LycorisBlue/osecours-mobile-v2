// lib/screens/notifications/widgets/notification_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import '../../../data/models/notification_models.dart';
import '../../../services/navigation_service.dart';

/// Bottom sheet pour afficher les détails complets d'une notification
class NotificationDetailBottomSheet extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailBottomSheet({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85, minHeight: screenHeight * 0.4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle du bottom sheet
          _buildHandle(),

          // En-tête
          _buildHeader(context),

          // Contenu scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de l'expéditeur
                  _buildSenderInfo(),

                  SizedBox(height: AppSizes.spacingLarge),

                  // Message complet
                  _buildFullMessage(),

                  SizedBox(height: AppSizes.spacingLarge),

                  // Métadonnées
                  _buildMetadata(),

                  // Actions si la notification est liée à une alerte
                  if (notification.hasAlert) ...[SizedBox(height: AppSizes.spacingLarge), _buildAlertActions(context)],

                  SizedBox(height: AppSizes.spacingXLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle visuel du bottom sheet
  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.spacingMedium),
      width: 40,
      height: 4,
      decoration: BoxDecoration(color: AppColors.textLight.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
    );
  }

  /// En-tête avec titre et bouton fermer
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.textLight.withOpacity(0.1), width: 1))),
      child: Row(
        children: [
          // Icône du type de notification
          Container(
            padding: EdgeInsets.all(AppSizes.spacingSmall),
            decoration: BoxDecoration(
              color: notification.type.lightColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: notification.type.borderColor, width: 1),
            ),
            child: Icon(notification.type.icon, color: notification.type.color, size: AppSizes.iconMedium),
          ),

          SizedBox(width: AppSizes.spacingMedium),

          // Titre
          Expanded(child: Text('Notification', style: AppTextStyles.heading3)),

          // Bouton fermer
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.text, size: AppSizes.iconMedium),
          ),
        ],
      ),
    );
  }

  /// Informations détaillées sur l'expéditeur
  Widget _buildSenderInfo() {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: notification.type.borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Avatar de l'expéditeur
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: notification.type.lightColor,
              shape: BoxShape.circle,
              border: Border.all(color: notification.type.borderColor, width: 2),
            ),
            child:
                notification.sender.initials.isNotEmpty
                    ? Center(
                      child: Text(
                        notification.sender.initials,
                        style: AppTextStyles.heading3.copyWith(color: notification.type.color, fontWeight: FontWeight.bold),
                      ),
                    )
                    : Icon(notification.type.icon, color: notification.type.color, size: AppSizes.iconLarge),
          ),

          SizedBox(width: AppSizes.spacingMedium),

          // Informations textuelles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom de l'expéditeur
                Text(
                  notification.sender.fullName.isNotEmpty ? notification.sender.fullName : 'Système',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),

                SizedBox(height: AppSizes.spacingXSmall),

                // Type/rôle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                  decoration: BoxDecoration(
                    color: notification.type.lightColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: notification.type.borderColor, width: 1),
                  ),
                  child: Text(
                    notification.type.label,
                    style: AppTextStyles.caption.copyWith(color: notification.type.color, fontWeight: FontWeight.w600),
                  ),
                ),

                SizedBox(height: AppSizes.spacingSmall),

                // Date et heure
                Row(
                  children: [
                    Icon(Icons.access_time, size: AppSizes.iconSmall, color: AppColors.textLight),
                    SizedBox(width: AppSizes.spacingXSmall),
                    Text(
                      _formatDateTime(notification.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Message complet de la notification
  Widget _buildFullMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Message', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),

        SizedBox(height: AppSizes.spacingMedium),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(color: AppColors.textLight.withOpacity(0.2), width: 1),
          ),
          child: Text(notification.message, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ),
      ],
    );
  }

  /// Métadonnées et informations supplémentaires
  Widget _buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),

        SizedBox(height: AppSizes.spacingMedium),

        // État de lecture
        _buildInfoRow(
          Icons.mark_email_read,
          'État',
          notification.isRead ? 'Lue' : 'Non lue',
          notification.isRead ? Colors.green : AppColors.primary,
        ),

        SizedBox(height: AppSizes.spacingMedium),

        // ID de la notification
        _buildInfoRow(Icons.tag, 'ID', notification.id, AppColors.textLight),

        // Alerte liée si applicable
        if (notification.hasAlert) ...[
          SizedBox(height: AppSizes.spacingMedium),
          _buildInfoRow(Icons.warning_outlined, 'Alerte liée', notification.alertId!, Colors.orange),
        ],

        // Métadonnées personnalisées
        if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
          SizedBox(height: AppSizes.spacingMedium),
          ...notification.metadata!.entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.spacingSmall),
              child: _buildInfoRow(Icons.info_outline, entry.key, entry.value.toString(), AppColors.textLight),
            ),
          ),
        ],
      ],
    );
  }

  /// Widget pour une ligne d'information
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: color),
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

  /// Actions liées à l'alerte
  Widget _buildAlertActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),

        SizedBox(height: AppSizes.spacingMedium),

        // Bouton voir l'alerte
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigation vers les détails de l'alerte
              Routes.navigateTo(Routes.alerts);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
            ),
            icon: Icon(Icons.visibility, size: AppSizes.iconMedium),
            label: Text('Voir l\'alerte associée', style: AppTextStyles.buttonText),
          ),
        ),
      ],
    );
  }

  /// Formate la date et l'heure
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}

/// Fonction utilitaire pour afficher le bottom sheet
void showNotificationDetail(BuildContext context, AppNotification notification) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NotificationDetailBottomSheet(notification: notification),
  );
}

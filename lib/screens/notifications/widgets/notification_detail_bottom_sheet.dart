// lib/screens/notifications/widgets/notification_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import 'notification_card.dart'; // Pour utiliser l'enum NotificationType

/// Bottom sheet pour afficher les détails complets d'une notification
class NotificationDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailBottomSheet({super.key, required this.notification});

  /// Détermine le type de notification
  NotificationType _getNotificationType() {
    if (notification['type'] == 'ALERT' || notification.containsKey('alert_id')) {
      return NotificationType.alert;
    }

    final sender = notification['sender'];
    if (sender != null) {
      final role = sender['role'] as String?;
      switch (role?.toUpperCase()) {
        case 'ADMIN':
          return NotificationType.admin;
        case 'RESCUE_MEMBER':
          return NotificationType.rescueMember;
        default:
          return NotificationType.system;
      }
    }

    return NotificationType.system;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final notifType = _getNotificationType();

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
          _buildHeader(context, notifType),

          // Contenu scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de l'expéditeur
                  _buildSenderInfo(notifType),

                  SizedBox(height: AppSizes.spacingLarge),

                  // Message complet
                  _buildFullMessage(),

                  SizedBox(height: AppSizes.spacingLarge),

                  // Métadonnées
                  _buildMetadata(),

                  // Actions si la notification est liée à une alerte
                  if (notification.containsKey('alert_id')) ...[
                    SizedBox(height: AppSizes.spacingLarge),
                    _buildAlertActions(context),
                  ],

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
  Widget _buildHeader(BuildContext context, NotificationType notifType) {
    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.textLight.withOpacity(0.1), width: 1))),
      child: Row(
        children: [
          // Icône du type de notification
          Container(
            padding: EdgeInsets.all(AppSizes.spacingSmall),
            decoration: BoxDecoration(
              color: notifType.lightColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: notifType.borderColor, width: 1),
            ),
            child: Icon(notifType.icon, color: notifType.color, size: AppSizes.iconMedium),
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
  Widget _buildSenderInfo(NotificationType notifType) {
    final sender = notification['sender'];

    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: notifType.borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Avatar de l'expéditeur
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: notifType.lightColor,
              shape: BoxShape.circle,
              border: Border.all(color: notifType.borderColor, width: 2),
            ),
            child:
                sender != null && sender['first_name'] != null && sender['last_name'] != null
                    ? Center(
                      child: Text(
                        "${sender['first_name'][0]}${sender['last_name'][0]}".toUpperCase(),
                        style: AppTextStyles.heading3.copyWith(color: notifType.color, fontWeight: FontWeight.bold),
                      ),
                    )
                    : Icon(notifType.icon, color: notifType.color, size: AppSizes.iconLarge),
          ),

          SizedBox(width: AppSizes.spacingMedium),

          // Informations textuelles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom de l'expéditeur
                Text(
                  sender != null ? "${sender['first_name']} ${sender['last_name']}" : 'Système',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),

                SizedBox(height: AppSizes.spacingXSmall),

                // Type/rôle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                  decoration: BoxDecoration(
                    color: notifType.lightColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: notifType.borderColor, width: 1),
                  ),
                  child: Text(
                    notifType.label,
                    style: AppTextStyles.caption.copyWith(color: notifType.color, fontWeight: FontWeight.w600),
                  ),
                ),

                SizedBox(height: AppSizes.spacingSmall),

                // Date et heure
                Row(
                  children: [
                    Icon(Icons.access_time, size: AppSizes.iconSmall, color: AppColors.textLight),
                    SizedBox(width: AppSizes.spacingXSmall),
                    Text(
                      _formatDateTime(DateTime.parse(notification['createdAt'])),
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
          child: Text(notification['message'], style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ),
      ],
    );
  }

  /// Métadonnées et informations supplémentaires
  Widget _buildMetadata() {
    final isRead = notification['is_read'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations', style: AppTextStyles.heading3.copyWith(fontSize: AppSizes.h3 * 0.9)),

        SizedBox(height: AppSizes.spacingMedium),

        // État de lecture
        _buildInfoRow(Icons.mark_email_read, 'État', isRead ? 'Lue' : 'Non lue', isRead ? Colors.green : AppColors.primary),

        SizedBox(height: AppSizes.spacingMedium),

        // ID de la notification
        _buildInfoRow(Icons.tag, 'ID', notification['id'].toString(), AppColors.textLight),

        // Alerte liée si applicable
        if (notification.containsKey('alert_id')) ...[
          SizedBox(height: AppSizes.spacingMedium),
          _buildInfoRow(Icons.warning_outlined, 'Alerte liée', notification['alert_id'].toString(), Colors.orange),
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
              // Routes.navigateTo(Routes.alerts);
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
void showNotificationDetail(BuildContext context, Map<String, dynamic> notification) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NotificationDetailBottomSheet(notification: notification),
  );
}

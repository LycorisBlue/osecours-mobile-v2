// lib/screens/notifications/widgets/notification_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import '../../../core/utils/utils.dart';

/// Widget pour afficher une carte de notification individuelle
class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final bool showUnreadIndicator;

  const NotificationCard({super.key, required this.notification, required this.onTap, this.showUnreadIndicator = true});

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
    final notifType = _getNotificationType();
    final isRead = notification['is_read'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: AppSizes.spacingSmall,
          left: AppSizes.screenPaddingHorizontal,
          right: AppSizes.screenPaddingHorizontal,
        ),
        decoration: BoxDecoration(
          color: isRead ? AppColors.white : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          border: Border.all(
            color: isRead ? AppColors.textLight.withOpacity(0.1) : notifType.borderColor,
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar de l'expéditeur
              _buildSenderAvatar(notifType),

              SizedBox(width: AppSizes.spacingMedium),

              // Contenu principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec nom et temps
                    _buildHeader(notifType),

                    SizedBox(height: AppSizes.spacingSmall),

                    // Message de la notification
                    _buildMessage(),

                    // Badge d'alerte si applicable
                    if (notification.containsKey('alert_id')) ...[SizedBox(height: AppSizes.spacingSmall), _buildAlertBadge()],
                  ],
                ),
              ),

              // Indicateur de lecture
              if (showUnreadIndicator && !isRead) ...[SizedBox(width: AppSizes.spacingMedium), _buildUnreadIndicator()],
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'avatar de l'expéditeur
  Widget _buildSenderAvatar(NotificationType notifType) {
    final sender = notification['sender'];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: notifType.lightColor,
        shape: BoxShape.circle,
        border: Border.all(color: notifType.borderColor, width: 1),
      ),
      child:
          sender != null && sender['first_name'] != null && sender['last_name'] != null
              ? Center(
                child: Text(
                  "${sender['first_name'][0]}${sender['last_name'][0]}".toUpperCase(),
                  style: AppTextStyles.bodyMedium.copyWith(color: notifType.color, fontWeight: FontWeight.bold),
                ),
              )
              : Icon(notifType.icon, color: notifType.color, size: AppSizes.iconMedium),
    );
  }

  /// Construit l'en-tête avec le nom de l'expéditeur et l'heure
  Widget _buildHeader(NotificationType notifType) {
    final sender = notification['sender'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom de l'expéditeur et type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender != null ? "${sender['first_name']} ${sender['last_name']}" : notifType.label,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (sender != null) ...[
                SizedBox(height: AppSizes.spacingXSmall),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                  decoration: BoxDecoration(
                    color: notifType.lightColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: notifType.borderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(notifType.icon, size: AppSizes.iconSmall, color: notifType.color),
                      SizedBox(width: AppSizes.spacingXSmall),
                      Text(
                        notifType.label,
                        style: AppTextStyles.caption.copyWith(color: notifType.color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Heure de la notification
        Text(Utils.timeAgo(notification['createdAt']), style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
      ],
    );
  }

  /// Construit le message de la notification
  Widget _buildMessage() {
    final message = notification['message'] as String;

    return Text(
      message.length > 80 ? '${message.substring(0, 80)}...' : message,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, height: 1.4),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construit le badge d'alerte
  Widget _buildAlertBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_outlined, size: AppSizes.iconSmall, color: Colors.orange),
          SizedBox(width: AppSizes.spacingXSmall),
          Text('Liée à une alerte', style: AppTextStyles.caption.copyWith(color: Colors.orange, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Construit l'indicateur de notification non lue
  Widget _buildUnreadIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 1))],
      ),
    );
  }
}

/// Enum pour les types de notifications
enum NotificationType {
  admin('ADMIN', 'Administrateur', Icons.admin_panel_settings, Colors.blue),
  rescueMember('RESCUE_MEMBER', 'Secouriste', Icons.local_hospital, Color(0xFFFF3333)),
  system('SYSTEM', 'Système', Icons.settings, Colors.grey),
  alert('ALERT', 'Alerte', Icons.warning, Colors.orange);

  const NotificationType(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  Color get lightColor => color.withOpacity(0.1);
  Color get borderColor => color.withOpacity(0.3);
}

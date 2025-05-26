// lib/screens/notifications/widgets/notification_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../data/models/notification_models.dart';

/// Widget pour afficher une carte de notification individuelle
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final bool showUnreadIndicator;

  const NotificationCard({super.key, required this.notification, required this.onTap, this.showUnreadIndicator = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: AppSizes.spacingSmall,
          left: AppSizes.screenPaddingHorizontal,
          right: AppSizes.screenPaddingHorizontal,
        ),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.white : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          border: Border.all(
            color: notification.isRead ? AppColors.textLight.withOpacity(0.1) : notification.type.borderColor,
            width: notification.isRead ? 1 : 1.5,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar de l'expéditeur
              _buildSenderAvatar(),

              SizedBox(width: AppSizes.spacingMedium),

              // Contenu principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec nom et temps
                    _buildHeader(),

                    SizedBox(height: AppSizes.spacingSmall),

                    // Message de la notification
                    _buildMessage(),

                    // Badge d'alerte si applicable
                    if (notification.hasAlert) ...[SizedBox(height: AppSizes.spacingSmall), _buildAlertBadge()],
                  ],
                ),
              ),

              // Indicateur de lecture
              if (showUnreadIndicator && !notification.isRead) ...[
                SizedBox(width: AppSizes.spacingMedium),
                _buildUnreadIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'avatar de l'expéditeur
  Widget _buildSenderAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: notification.type.lightColor,
        shape: BoxShape.circle,
        border: Border.all(color: notification.type.borderColor, width: 1),
      ),
      child:
          notification.sender.initials.isNotEmpty
              ? Center(
                child: Text(
                  notification.sender.initials,
                  style: AppTextStyles.bodyMedium.copyWith(color: notification.type.color, fontWeight: FontWeight.bold),
                ),
              )
              : Icon(notification.type.icon, color: notification.type.color, size: AppSizes.iconMedium),
    );
  }

  /// Construit l'en-tête avec le nom de l'expéditeur et l'heure
  Widget _buildHeader() {
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
                notification.sender.fullName.isNotEmpty ? notification.sender.fullName : notification.type.label,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (notification.sender.fullName.isNotEmpty) ...[
                SizedBox(height: AppSizes.spacingXSmall),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                  decoration: BoxDecoration(
                    color: notification.type.lightColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: notification.type.borderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(notification.type.icon, size: AppSizes.iconSmall, color: notification.type.color),
                      SizedBox(width: AppSizes.spacingXSmall),
                      Text(
                        notification.type.label,
                        style: AppTextStyles.caption.copyWith(color: notification.type.color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Heure de la notification
        Text(
          Utils.timeAgo(notification.createdAt.toIso8601String()),
          style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }

  /// Construit le message de la notification
  Widget _buildMessage() {
    return Text(
      notification.previewMessage,
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

/// Widget pour afficher l'état vide des notifications
class EmptyNotificationsWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyNotificationsWidget({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppEdgeInsets.large,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppColors.textLight.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.notifications_off_outlined, size: AppSizes.iconLarge, color: AppColors.textLight),
            ),

            SizedBox(height: AppSizes.spacingLarge),

            Text('Aucune notification', style: AppTextStyles.heading3.copyWith(color: AppColors.textLight)),

            SizedBox(height: AppSizes.spacingSmall),

            Text(
              'Vous n\'avez pas encore reçu de notifications.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),

            if (onRefresh != null) ...[
              SizedBox(height: AppSizes.spacingLarge),

              ElevatedButton.icon(
                onPressed: onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingLarge, vertical: AppSizes.spacingMedium),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
                ),
                icon: Icon(Icons.refresh, size: AppSizes.iconMedium, color: AppColors.background,),
                label: Text('Actualiser', style: AppTextStyles.buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget pour les statistiques de notifications en en-tête
class NotificationStatsHeader extends StatelessWidget {
  final NotificationStats stats;
  final VoidCallback? onMarkAllAsRead;
  final bool isMarkingAllAsRead;

  const NotificationStatsHeader({super.key, required this.stats, this.onMarkAllAsRead, this.isMarkingAllAsRead = false});

  @override
  Widget build(BuildContext context) {
    if (stats.total == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal, vertical: AppSizes.spacingMedium),
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          // Statistiques
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Icon(Icons.notifications, color: AppColors.primary, size: AppSizes.iconMedium),
                ),

                SizedBox(width: AppSizes.spacingMedium),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.total} notification${stats.total > 1 ? 's' : ''}',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (stats.hasUnread)
                      Text(
                        '${stats.unread} non lue${stats.unread > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton marquer tout comme lu
          if (stats.hasUnread && onMarkAllAsRead != null)
            ElevatedButton.icon(
              onPressed: isMarkingAllAsRead ? null : onMarkAllAsRead,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
              ),
              icon:
                  isMarkingAllAsRead
                      ? SizedBox(
                        width: AppSizes.iconSmall,
                        height: AppSizes.iconSmall,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                      : Icon(Icons.mark_email_read, size: AppSizes.iconSmall, color: AppColors.background,),
              label: Text(
                'Tout lire',
                style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

// lib/screens/notifications/index.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/themes.dart';
import '../../data/models/notification_models.dart';
import 'controller.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_detail_bottom_sheet.dart';

/// Écran principal pour afficher toutes les notifications de l'utilisateur
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.initialize(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Rafraîchit les notifications
  Future<void> _handleRefresh() async {
    await _controller.refreshNotifications(setState);
  }

  /// Gère le tap sur une notification
  void _handleNotificationTap(AppNotification notification) {
    // Marquer comme lue si nécessaire
    _controller.onNotificationTapped(notification, setState);

    // Afficher les détails
    showNotificationDetail(context, notification);
  }

  /// Marque toutes les notifications comme lues
  void _handleMarkAllAsRead() async {
    await _controller.markAllAsRead(setState);

    if (_controller.error == null) {
      _showSuccessSnackBar('Toutes les notifications ont été marquées comme lues');
    } else {
      _showErrorSnackBar(_controller.error!);
    }
  }

  /// Affiche un message de succès
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: AppEdgeInsets.medium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        action: SnackBarAction(label: 'OK', textColor: AppColors.white, onPressed: () => _controller.clearError(setState)),
      ),
    );
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: AppEdgeInsets.medium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: AppColors.white,
          onPressed: () {
            _controller.clearError(setState);
            _handleRefresh();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Afficher les messages d'erreur
    if (_controller.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(_controller.error!);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text, size: AppSizes.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppTextStyles.heading3),
        centerTitle: true,
        actions: [
          // Bouton marquer tout comme lu
          ValueListenableBuilder(
            valueListenable: Hive.isBoxOpen('notifications') ? Hive.box('notifications').listenable() : ValueNotifier(null),
            builder: (context, dynamic box, _) {
              final hasUnread = _controller.hasUnread;

              return IconButton(
                onPressed: hasUnread && !_controller.isMarkingAllAsRead ? _handleMarkAllAsRead : null,
                icon:
                    _controller.isMarkingAllAsRead
                        ? SizedBox(
                          width: AppSizes.iconMedium,
                          height: AppSizes.iconMedium,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                        : Icon(Icons.mark_email_read_outlined),
                color: hasUnread ? AppColors.primary : AppColors.textLight,
                tooltip: 'Tout marquer comme lu',
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.notifications.isEmpty) {
      return _buildLoadingState();
    }

    if (_controller.isEmpty) {
      return EmptyNotificationsWidget(onRefresh: _handleRefresh);
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: ValueListenableBuilder(
        valueListenable: Hive.isBoxOpen('notifications') ? Hive.box('notifications').listenable() : ValueNotifier(null),
        builder: (context, dynamic box, _) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // En-tête avec statistiques
              SliverToBoxAdapter(
                child: NotificationStatsHeader(
                  stats: _controller.stats,
                  onMarkAllAsRead: _controller.hasUnread ? _handleMarkAllAsRead : null,
                  isMarkingAllAsRead: _controller.isMarkingAllAsRead,
                ),
              ),

              // Indicateur de rafraîchissement
              if (_controller.isRefreshing)
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.spacingMedium),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: AppSizes.iconMedium,
                            height: AppSizes.iconMedium,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                          SizedBox(width: AppSizes.spacingMedium),
                          Text('Actualisation...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                        ],
                      ),
                    ),
                  ),
                ),

              // Liste des notifications
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final notification = _controller.notifications[index];

                  return Padding(
                    padding: EdgeInsets.only(bottom: index == _controller.notifications.length - 1 ? AppSizes.spacingXLarge : 0),
                    child: NotificationCard(
                      notification: notification,
                      onTap: () => _handleNotificationTap(notification),
                      showUnreadIndicator: true,
                    ),
                  );
                }, childCount: _controller.notifications.length),
              ),
            ],
          );
        },
      ),
    );
  }

  /// État de chargement initial
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSizes.spacingMedium),
          Text('Chargement des notifications...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }
}

/// Page des notifications avec filtre par type
class FilteredNotificationsScreen extends StatefulWidget {
  final NotificationType? filterType;
  final String title;

  const FilteredNotificationsScreen({super.key, this.filterType, this.title = 'Notifications'});

  @override
  State<FilteredNotificationsScreen> createState() => _FilteredNotificationsScreenState();
}

class _FilteredNotificationsScreenState extends State<FilteredNotificationsScreen> {
  late NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.initialize(setState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<AppNotification> get _filteredNotifications {
    if (widget.filterType == null) {
      return _controller.notifications;
    }
    return _controller.getNotificationsByType(widget.filterType!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text, size: AppSizes.iconMedium),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body:
          _filteredNotifications.isEmpty
              ? EmptyNotificationsWidget(onRefresh: () => _controller.refreshNotifications(setState))
              : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
                itemCount: _filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = _filteredNotifications[index];

                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      _controller.onNotificationTapped(notification, setState);
                      showNotificationDetail(context, notification);
                    },
                    showUnreadIndicator: true,
                  );
                },
              ),
    );
  }
}

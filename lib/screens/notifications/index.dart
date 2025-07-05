// lib/screens/notifications/index.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:osecours/services/navigation_service.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/themes.dart';
import '../../core/utils/utils.dart';
import 'controller.dart';

/// Écran principal pour afficher toutes les notifications de l'utilisateur
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late Box _notificationsBox;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _initializeHive();
    _controller.initialize(setState);
  }

  /// Initialise Hive si nécessaire
  Future<void> _initializeHive() async {
    try {
      if (!Hive.isBoxOpen('notifications')) {
        _notificationsBox = await Hive.openBox('notifications');
      } else {
        _notificationsBox = Hive.box('notifications');
      }
    } catch (e) {
      debugPrint('Erreur initialisation Hive: $e');
    }
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
  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Marquer comme lue si nécessaire
    _controller.onNotificationTapped(notification, setState);

    // Afficher les détails
    _showNotificationBottomSheet(notification);
  }

  /// Détermine le type de notification
/// Détermine le type de notification
  NotificationType _getNotificationType(Map<String, dynamic> notification) {
    if (notification['type'] == 'ALERT' || notification.containsKey('alert_id')) {
      return NotificationType.alert;
    }

    final sender = notification['sender'];
    if (sender != null && sender is Map) {
      final role = sender['role'];
      if (role != null) {
        switch (role.toString().toUpperCase()) {
          case 'ADMIN':
            return NotificationType.admin;
          case 'RESCUE_MEMBER':
            return NotificationType.rescueMember;
          default:
            return NotificationType.system;
        }
      }
    }

    return NotificationType.system;
  }

/// Affiche le bottom sheet de détail
  void _showNotificationBottomSheet(Map<String, dynamic> notification) {
    final sender = notification['sender'];
    final message = notification['message'];
    final notifType = _getNotificationType(notification);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête avec l'icône et le nom de l'expéditeur
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: notifType.color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(notifType.icon, color: notifType.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSenderDisplayName(sender, notifType), // Utiliser la même méthode
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Utils.timeAgo(notification['createdAt']),
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Message
                Text(message, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
                const SizedBox(height: 24),
                // Bouton Fermer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: notifType.color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Fermer", style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
    );
  }
  /// Marque toutes les notifications comme lues
  void _handleMarkAllAsRead() async {
    await _controller.markAllAsRead(setState);

    if (_controller.error == null) {
      _showSuccessSnackBar('Toutes les notifications ont été marquées comme lues');
    }
  }

  /// Affiche un message de succès
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: AppEdgeInsets.medium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      ),
    );
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
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

  /// Construit une carte de notification
  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final sender = notification['sender']; // Garde comme dynamic
    final isRead = notification['is_read'] as bool? ?? false;
    final message = notification['message'];
    final notifType = _getNotificationType(notification);

    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notifType.lightColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: notifType.borderColor, width: 1),
                ),
                child: _buildAvatar(sender, notifType),
              ),

              SizedBox(width: AppSizes.spacingMedium),

              // Contenu principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec nom et temps
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom de l'expéditeur et type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getSenderDisplayName(sender, notifType),
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Badge du type de notification
                              SizedBox(height: AppSizes.spacingXSmall),
                              
                            ],
                          ),
                        ),

                        // Heure de la notification
                        Text(
                          Utils.timeAgo(notification['createdAt']),
                          style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizes.spacingSmall),

                    // Message de la notification
                    Text(
                      message.length > 80 ? '${message.substring(0, 80)}...' : message,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Indicateur de lecture
              if (!isRead) ...[
                SizedBox(width: AppSizes.spacingMedium),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 1))],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'avatar de l'expéditeur
  Widget _buildAvatar(dynamic sender, NotificationType notifType) {
    if (sender != null && sender is Map) {
      final firstName = sender['first_name'];
      final lastName = sender['last_name'];

      if (firstName != null && lastName != null && firstName.toString().isNotEmpty && lastName.toString().isNotEmpty) {
        return Center(
          child: Text(
            "${firstName.toString()[0]}${lastName.toString()[0]}".toUpperCase(),
            style: AppTextStyles.bodyMedium.copyWith(color: notifType.color, fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    return Icon(notifType.icon, color: notifType.color, size: AppSizes.iconMedium);
  }

  /// Détermine le nom d'affichage de l'expéditeur
  String _getSenderDisplayName(dynamic sender, NotificationType notifType) {
    if (sender != null && sender is Map) {
      final firstName = sender['first_name'];
      final lastName = sender['last_name'];

      if (firstName != null && lastName != null && firstName.toString().isNotEmpty && lastName.toString().isNotEmpty) {
        return "${firstName} ${lastName}";
      }
    }

    // Si pas de sender valide, utiliser le label du type
    return notifType.label;
  }


  @override
  Widget build(BuildContext context) {
    // Afficher les messages d'erreur
    if (_controller.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(_controller.error!);
        _controller.clearError(setState);
      });
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Si l'utilisateur glisse de gauche à droite (vitesse positive en x)
        if (details.primaryVelocity! > 0) {
          // Vérifier si nous pouvons retourner en arrière
          if (Navigator.of(context).canPop()) {
            Routes.goBack();
          }
        }
      },
      child: Scaffold(
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
            // Bouton marquer tout comme lu avec ValueListenableBuilder
            FutureBuilder(
              future: _initializeHive(),
              builder: (context, snapshot) {
                if (!Hive.isBoxOpen('notifications')) {
                  return IconButton(onPressed: null, icon: Icon(Icons.mark_email_read_outlined), color: AppColors.textLight);
                }
      
                return ValueListenableBuilder(
                  valueListenable: Hive.box('notifications').listenable(),
                  builder: (context, Box box, _) {
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
                );
              },
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.notifications.isEmpty) {
      return _buildLoadingState();
    }

    if (_controller.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: FutureBuilder(
        future: _initializeHive(),
        builder: (context, snapshot) {
          if (!Hive.isBoxOpen('notifications')) {
            return _buildLoadingState();
          }

          return ValueListenableBuilder(
            valueListenable: Hive.box('notifications').listenable(),
            builder: (context, Box box, Widget? child) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

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
                        padding: EdgeInsets.only(
                          bottom: index == _controller.notifications.length - 1 ? AppSizes.spacingXLarge : 0,
                        ),
                        child: _buildNotificationCard(notification),
                      );
                    }, childCount: _controller.notifications.length),
                  ),
                ],
              );
            },
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

  /// État vide
  Widget _buildEmptyState() {
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
            SizedBox(height: AppSizes.spacingLarge),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingLarge, vertical: AppSizes.spacingMedium),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
              ),
              icon: Icon(Icons.refresh, size: AppSizes.iconMedium),
              label: Text('Actualiser', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  /// En-tête avec statistiques
  Widget _buildStatsHeader() {
    if (_controller.totalCount == 0) return const SizedBox.shrink();

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
                      '${_controller.totalCount} notification${_controller.totalCount > 1 ? 's' : ''}',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (_controller.hasUnread)
                      Text(
                        '${_controller.unreadCount} non lue${_controller.unreadCount > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Bouton marquer tout comme lu
          if (_controller.hasUnread)
            ElevatedButton.icon(
              onPressed: _controller.isMarkingAllAsRead ? null : _handleMarkAllAsRead,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
              ),
              icon:
                  _controller.isMarkingAllAsRead
                      ? SizedBox(
                        width: AppSizes.iconSmall,
                        height: AppSizes.iconSmall,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                      : Icon(Icons.mark_email_read, size: AppSizes.iconSmall),
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

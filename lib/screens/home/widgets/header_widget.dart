// Version complète du HeaderWidget avec le logo correct
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../controllers.dart';

class HeaderWidget extends StatelessWidget {
  final String currentAddress;
  final VoidCallback onRefreshLocation;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;

  HeaderWidget({
    super.key,
    required this.currentAddress,
    required this.onRefreshLocation,
    required this.onMenuTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal, vertical: AppSizes.spacingSmall),
      child: Row(
        children: [
          // Menu button
          SizedBox(width: 48, height: 48, child: IconButton(icon: Icon(Icons.menu), onPressed: onMenuTap)),

          // Logo et localisation
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo comme dans l'ancienne app
                Image.asset('assets/pictures/logo.png', height: 30),
                SizedBox(height: AppSizes.spacingSmall),

                // Localisation
                GestureDetector(
                  onTap: onRefreshLocation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.textLight),
                      SizedBox(width: AppSizes.spacingSmall),
                      Flexible(
                        child: Text(
                          currentAddress.length > 30 ? '${currentAddress.substring(0, 30)}...' : currentAddress,
                          style: TextStyle(fontSize: AppSizes.bodySmall, color: AppColors.textLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.refresh, size: 14, color: AppColors.textLight),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notification badge (reste identique)
          SizedBox(
            width: 48,
            height: 48,
            child: ValueListenableBuilder(
              valueListenable: Hive.isBoxOpen('notifications') ? Hive.box('notifications').listenable() : ValueNotifier(null),
              builder: (context, dynamic box, _) {
                int unreadCount = 0;

                if (Hive.isBoxOpen('notifications')) {
                  try {
                    final notificationController = NotificationController();
                    unreadCount = notificationController.getUnreadNotificationsCount();
                  } catch (e) {
                    unreadCount = 0;
                  }
                }

                return Stack(
                  children: [
                    IconButton(icon: Icon(Icons.notifications_none, color: AppColors.text), onPressed: onNotificationTap),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            unreadCount.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

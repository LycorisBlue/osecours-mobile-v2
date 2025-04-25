// lib/core/utils/notification_service.dart

import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/texts.dart';
import 'package:osecours/core/utils/utils.dart';

class NotificationInfos {
  static void showErrorBottomSheet(
    BuildContext context, {
    required String message,
    String buttonText = "Fermer",
    VoidCallback? onPressed,
  }) {
    _showCustomBottomSheet(
      context,
      icon: Icons.error_outline,
      iconColor: AppColors.primary,
      message: message,
      buttonText: buttonText,
      buttonColor: AppColors.primary,
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }

  static void showSuccessBottomSheet(
    BuildContext context, {
    required String message,
    String buttonText = "Fermer",
    VoidCallback? onPressed,
  }) {
    _showCustomBottomSheet(
      context,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      message: message,
      buttonText: buttonText,
      buttonColor: Colors.green,
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }

  static void showInfoBottomSheet(
    BuildContext context, {
    required String message,
    required String validateButtonText,
    required VoidCallback onValidate,
    String cancelButtonText = "Annuler",
  }) {
    _showInfoBottomSheet(
      context,
      icon: Icons.info_outline,
      iconColor: AppColors.primary,
      message: message,
      validateButtonText: validateButtonText,
      cancelButtonText: cancelButtonText,
      onValidate: onValidate,
    );
  }

  static void _showCustomBottomSheet(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String message,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: iconColor),
                const SizedBox(height: 16),
                Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(buttonText, style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Dans lib/core/utils/notification_service.dart

  static void showNotificationBottomSheet(BuildContext context, {required Map<String, dynamic> notification}) {
    final sender = notification['sender'];
    final message = notification['message'];
    final role = sender['role'] as String;

    Color getNotificationColor() {
      switch (role.toUpperCase()) {
        case 'ADMIN':
          return Colors.blue;
        case 'RESCUE_MEMBER':
          return AppColors.primary;
        default:
          return Colors.grey;
      }
    }

    IconData getNotificationIcon() {
      switch (role.toUpperCase()) {
        case 'ADMIN':
          return Icons.admin_panel_settings;
        case 'RESCUE_MEMBER':
          return Icons.local_hospital;
        default:
          return Icons.notifications;
      }
    }

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
                      decoration: BoxDecoration(color: getNotificationColor().withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(getNotificationIcon(), color: getNotificationColor(), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${sender['first_name']} ${sender['last_name']}",
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
                      backgroundColor: getNotificationColor(),
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

  static void _showInfoBottomSheet(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String message,
    required String validateButtonText,
    required String cancelButtonText,
    required VoidCallback onValidate,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: iconColor),
                const SizedBox(height: 16),
                Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(cancelButtonText, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onValidate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(validateButtonText, style: AppTextStyles.buttonText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

// lib/screens/profile/widgets/profile_info_item.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';

/// Widget réutilisable pour les éléments d'information du profil
class ProfileInfoItem extends StatelessWidget {
  final String text;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? label;

  const ProfileInfoItem({
    super.key,
    required this.text,
    this.leadingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.onTap,
    this.isLoading = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.textLight.withOpacity(0.1), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.spacingMedium),
            child: Row(
              children: [
                // Leading icon ou widget
                if (leadingIcon != null || leadingWidget != null) ...[
                  leadingWidget ?? Icon(leadingIcon, size: AppSizes.iconMedium, color: AppColors.primary),
                  SizedBox(width: AppSizes.spacingMedium),
                ],

                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label si fourni
                      if (label != null) ...[
                        Text(
                          label!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: AppSizes.spacingXSmall),
                      ],

                      // Texte principal
                      Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.text, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),

                // Trailing widget avec indicateur de chargement
                if (trailingWidget != null || isLoading) ...[
                  SizedBox(width: AppSizes.spacingMedium),
                  if (isLoading)
                    SizedBox(
                      width: AppSizes.iconMedium,
                      height: AppSizes.iconMedium,
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    )
                  else
                    trailingWidget!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget spécialisé pour les informations éditables
class EditableProfileInfoItem extends StatelessWidget {
  final String text;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isEmpty;

  const EditableProfileInfoItem({
    super.key,
    required this.text,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileInfoItem(
      text: isEmpty ? 'Appuyez pour ajouter' : text,
      label: label,
      leadingIcon: icon,
      onTap: onTap,
      isLoading: isLoading,
      trailingWidget: Icon(
        isEmpty ? Icons.add : Icons.edit_outlined,
        size: AppSizes.iconMedium,
        color: isEmpty ? AppColors.primary : AppColors.textLight,
      ),
    );
  }
}

/// Widget pour les informations non-éditables
class ReadOnlyProfileInfoItem extends StatelessWidget {
  final String text;
  final String label;
  final IconData icon;
  final Widget? customLeading;

  const ReadOnlyProfileInfoItem({super.key, required this.text, required this.label, required this.icon, this.customLeading});

  @override
  Widget build(BuildContext context) {
    return ProfileInfoItem(
      text: text,
      label: label,
      leadingIcon: customLeading == null ? icon : null,
      leadingWidget: customLeading,
    );
  }
}

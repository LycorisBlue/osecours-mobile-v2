// lib/screens/safe_contacts/widgets/safe_contact_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/themes.dart';
import '../../../data/models/safe_contact_models.dart';

/// Widget pour afficher une carte de contact de sécurité
class SafeContactCard extends StatelessWidget {
  final SafeContact contact;
  final VoidCallback onDelete;
  final VoidCallback onCategoryTap;
  final VoidCallback onTestMessage;
  final bool isDeleting;
  final bool isTesting;

  const SafeContactCard({
    super.key,
    required this.contact,
    required this.onDelete,
    required this.onCategoryTap,
    required this.onTestMessage,
    this.isDeleting = false,
    this.isTesting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: contact.category.borderColor, width: 1.5),
        boxShadow: [BoxShadow(color: contact.category.color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        child: Column(
          children: [
            // En-tête avec avatar et informations principales
            Row(
              children: [
                // Avatar avec initiales
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: contact.category.lightColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                    border: Border.all(color: contact.category.borderColor, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      contact.initials,
                      style: AppTextStyles.heading3.copyWith(color: contact.category.color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(width: AppSizes.spacingMedium),

                // Informations du contact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du contact
                      Text(
                        contact.description,
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: AppSizes.spacingXSmall),

                      // Numéro de téléphone
                      Text(contact.formattedNumber, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
                    ],
                  ),
                ),

                // Badge de catégorie
                GestureDetector(
                  onTap: onCategoryTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
                    decoration: BoxDecoration(
                      color: contact.category.lightColor,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(color: contact.category.borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(contact.category.icon, size: AppSizes.iconSmall, color: contact.category.color),
                        SizedBox(width: AppSizes.spacingXSmall),
                        Text(
                          contact.category.label,
                          style: AppTextStyles.caption.copyWith(color: contact.category.color, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizes.spacingMedium),

            // Actions
            Row(
              children: [
                // Bouton de test de message
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isTesting ? null : onTestMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: contact.category.color,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
                      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingSmall),
                    ),
                    icon:
                        isTesting
                            ? SizedBox(
                              width: AppSizes.iconSmall,
                              height: AppSizes.iconSmall,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                            )
                            : Icon(Icons.message, size: AppSizes.iconSmall),
                    label: Text(
                      isTesting ? 'Test...' : 'Tester',
                      style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                SizedBox(width: AppSizes.spacingMedium),

                // Bouton de suppression
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                    border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                  ),
                  child: IconButton(
                    onPressed: isDeleting ? null : onDelete,
                    icon:
                        isDeleting
                            ? SizedBox(
                              width: AppSizes.iconMedium,
                              height: AppSizes.iconMedium,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                            )
                            : Icon(Icons.delete_outline, color: Colors.red, size: AppSizes.iconMedium),
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

/// Widget pour afficher une carte vide (état d'ajout)
class EmptySafeContactCard extends StatelessWidget {
  final VoidCallback onTap;
  final int remainingSlots;

  const EmptySafeContactCard({super.key, required this.onTap, required this.remainingSlots});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2, style: BorderStyle.solid),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.spacingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(Icons.add, color: AppColors.primary, size: AppSizes.iconLarge),
                ),

                SizedBox(height: AppSizes.spacingMedium),

                Text(
                  'Ajouter un contact',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),

                SizedBox(height: AppSizes.spacingSmall),

                Text(
                  remainingSlots == 1 ? '1 emplacement disponible' : '$remainingSlots emplacements disponibles',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

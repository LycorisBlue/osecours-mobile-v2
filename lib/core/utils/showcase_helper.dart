// lib/core/utils/showcase_helper.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../constants/themes.dart';

/// Utilitaire pour gérer les showcases dans l'application
class ShowcaseHelper {
  static const String _showcaseBoxName = 'showcase';

  /// Vérifie si un showcase a déjà été vu
  static bool hasSeenShowcase(String showcaseKey) {
    try {
      final box = Hive.box(_showcaseBoxName);
      return box.get(showcaseKey, defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  /// Marque un showcase comme vu
  static Future<void> markShowcaseAsSeen(String showcaseKey) async {
    try {
      final box = Hive.box(_showcaseBoxName);
      await box.put(showcaseKey, true);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du showcase: $e');
    }
  }


  /// Crée un widget Showcase avec le style de l'application
  static Widget createShowcase({
    required GlobalKey key,
    required Widget child,
    required String title,
    required String description,
    VoidCallback? onTargetClick,
    VoidCallback? onToolTipClick,
    bool showArrow = true,
    TooltipPosition? tooltipPosition,
    bool disposeOnTap = false,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      tooltipBackgroundColor: AppColors.white,
      textColor: AppColors.text,
      titleTextStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
      descTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight, height: 1.4),
      tooltipBorderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      tooltipPadding: EdgeInsets.all(AppSizes.spacingMedium),
      targetPadding: EdgeInsets.all(AppSizes.spacingSmall),
      overlayColor: AppColors.text,
      overlayOpacity: 0.8,
      showArrow: showArrow,
      tooltipPosition: tooltipPosition,
      onTargetClick: onTargetClick,
      onToolTipClick: onToolTipClick,
      disposeOnTap: disposeOnTap,
      child: child,
    );
  }



}

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

  /// Remet à zéro tous les showcases (utile pour les tests)
  static Future<void> resetAllShowcases() async {
    try {
      final box = Hive.box(_showcaseBoxName);
      await box.clear();
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation des showcases: $e');
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

  /// Crée un widget Showcase avec un widget personnalisé
  static Widget createShowcaseWithWidget({
    required GlobalKey key,
    required Widget child,
    required Widget container,
    double? height,
    double? width,
    VoidCallback? onTargetClick,
    TooltipPosition? tooltipPosition,
  }) {
    return Showcase.withWidget(
      key: key,
      container: container,
      height: height,
      width: width,
      targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      targetPadding: EdgeInsets.all(AppSizes.spacingSmall),
      overlayColor: AppColors.text,
      overlayOpacity: 0.8,
      tooltipPosition: tooltipPosition,
      onTargetClick: onTargetClick,
      disposeOnTap: true,
      child: child,
    );
  }

  /// Démarre un showcase automatiquement si ce n'est pas déjà vu
  static void autoStartShowcase({
    required BuildContext context,
    required String showcaseKey,
    required List<GlobalKey> keys,
    VoidCallback? onFinish,
  }) {
    if (!hasSeenShowcase(showcaseKey)) {
      // Attendre que le contexte soit disponible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Vérifier que le contexte est toujours valide
        if (context.mounted) {
          try {
            ShowCaseWidget.of(context).startShowCase(keys);
          } catch (e) {
            debugPrint('Erreur lors du démarrage du showcase: $e');
          }
        }
      });
    }
  }

  /// Démarre un showcase manuellement
  static void startShowcase({required BuildContext context, required List<GlobalKey> keys}) {
    ShowCaseWidget.of(context).startShowCase(keys);
  }

  /// Configuration par défaut pour ShowCaseWidget
  static Widget wrapWithShowcase({
    required Widget child,
    VoidCallback? onFinish,
    Function(int?, GlobalKey)? onStart,
    Function(int?, GlobalKey)? onComplete,
    bool autoPlay = false,
    Duration autoPlayDelay = const Duration(seconds: 3),
    bool enableAutoScroll = false,
    double blurValue = 1.0,
  }) {
    return ShowCaseWidget(
      onFinish: onFinish,
      onStart: onStart,
      onComplete: onComplete,
      autoPlay: autoPlay,
      autoPlayDelay: autoPlayDelay,
      enableAutoScroll: enableAutoScroll,
      blurValue: blurValue,
      builder: (context) => child,
    );
  }
}

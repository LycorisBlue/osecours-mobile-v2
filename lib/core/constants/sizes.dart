// lib/core/constants/sizes.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Classe contenant toutes les tailles responsives pour l'application
/// Utilise flutter_screenutil pour l'adaptation automatique
abstract class AppSizes {
  // ===================
  // TAILLES DE POLICE (RESPONSIVE)
  // ===================

  /// Titre principal - très grand
  static double get h1 => 26.5.sp;

  /// Titre secondaire - grand
  static double get h2 => 22.5.sp;

  /// Titre tertiaire - moyen
  static double get h3 => 18.5.sp;

  /// Corps de texte - grand
  static double get bodyLarge => 13.5.sp;

  /// Corps de texte - moyen
  static double get bodyMedium => 12.5.sp;

  /// Corps de texte - petit
  static double get bodySmall => 10.5.sp;

  /// Texte de bouton
  static double get buttonText => 16.sp;

  /// Texte de caption/légende
  static double get caption => 12.sp;

  // ===================
  // ESPACEMENTS (RESPONSIVE)
  // ===================

  /// Espacement très petit
  static double get spacingXSmall => 4.w;

  /// Espacement petit
  static double get spacingSmall => 8.w;

  /// Espacement moyen
  static double get spacingMedium => 12.w;

  /// Espacement grand
  static double get spacingLarge => 16.w;

  /// Espacement très grand
  static double get spacingXLarge => 22.w;

  /// Espacement énorme
  static double get spacingXXLarge => 32.w;

  // ===================
  // PADDINGS SPÉCIFIQUES (RESPONSIVE)
  // ===================

  /// Padding horizontal pour les écrans
  static double get screenPaddingHorizontal => 20.w;

  /// Padding vertical pour les écrans
  static double get screenPaddingVertical => 24.h;

  /// Padding horizontal pour les boutons
  static double get buttonPaddingHorizontal => 16.w;

  /// Padding vertical pour les boutons
  static double get buttonPaddingVertical => 12.h;

  /// Padding pour les cards
  static double get cardPadding => 16.w;

  // ===================
  // HAUTEURS RESPONSIVES
  // ===================

  /// Hauteur des boutons
  static double get buttonHeight => 48.h;

  /// Hauteur des champs de texte
  static double get inputHeight => 48.h;

  /// Hauteur de l'AppBar
  static double get appBarHeight => 56.h;

  /// Hauteur des éléments de liste
  static double get listItemHeight => 64.h;

  // ===================
  // BORDER RADIUS (RESPONSIVE)
  // ===================

  /// Border radius petit
  static double get radiusSmall => 8.r;

  /// Border radius moyen
  static double get radiusMedium => 12.r;

  /// Border radius grand
  static double get radiusLarge => 16.r;

  /// Border radius pour les boutons
  static double get radiusButton => 8.r;

  /// Border radius pour les cards
  static double get radiusCard => 12.r;

  // ===================
  // ÉLÉVATIONS (RESPONSIVE)
  // ===================

  /// Élévation petite
  static double get elevationSmall => 2.r;

  /// Élévation moyenne
  static double get elevationMedium => 4.r;

  /// Élévation grande
  static double get elevationLarge => 8.r;

  // ===================
  // TAILLES D'ICÔNES (RESPONSIVE)
  // ===================

  /// Icône petite
  static double get iconSmall => 16.w;

  /// Icône moyenne
  static double get iconMedium => 24.w;

  /// Icône grande
  static double get iconLarge => 32.w;

  // ===================
  // CONSTANTES DE TEXTE (FIXES)
  // ===================

  /// Line heights (multiplicateurs - restent fixes)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  /// Letter spacing (restent fixes)
  static const double letterSpacingTight = -0.25;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
}

/// Classe utilitaire pour créer des EdgeInsets responsifs
abstract class AppEdgeInsets {
  // ===================
  // PADDINGS UNIFORMES (RESPONSIVE)
  // ===================

  /// Padding très petit
  static EdgeInsets get xSmall => EdgeInsets.all(AppSizes.spacingXSmall);

  /// Padding petit
  static EdgeInsets get small => EdgeInsets.all(AppSizes.spacingSmall);

  /// Padding moyen
  static EdgeInsets get medium => EdgeInsets.all(AppSizes.spacingMedium);

  /// Padding grand
  static EdgeInsets get large => EdgeInsets.all(AppSizes.spacingLarge);

  /// Padding très grand
  static EdgeInsets get xLarge => EdgeInsets.all(AppSizes.spacingXLarge);

  // ===================
  // PADDINGS HORIZONTAUX (RESPONSIVE)
  // ===================

  /// Padding horizontal très petit
  static EdgeInsets get horizontalXSmall => EdgeInsets.symmetric(horizontal: AppSizes.spacingXSmall);

  /// Padding horizontal petit
  static EdgeInsets get horizontalSmall => EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall);

  /// Padding horizontal moyen
  static EdgeInsets get horizontalMedium => EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium);

  /// Padding horizontal grand
  static EdgeInsets get horizontalLarge => EdgeInsets.symmetric(horizontal: AppSizes.spacingLarge);

  /// Padding horizontal pour les écrans
  static EdgeInsets get horizontalScreen => EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal);

  // ===================
  // PADDINGS VERTICAUX (RESPONSIVE)
  // ===================

  /// Padding vertical très petit
  static EdgeInsets get verticalXSmall => EdgeInsets.symmetric(vertical: AppSizes.spacingXSmall);

  /// Padding vertical petit
  static EdgeInsets get verticalSmall => EdgeInsets.symmetric(vertical: AppSizes.spacingSmall);

  /// Padding vertical moyen
  static EdgeInsets get verticalMedium => EdgeInsets.symmetric(vertical: AppSizes.spacingMedium);

  /// Padding vertical grand
  static EdgeInsets get verticalLarge => EdgeInsets.symmetric(vertical: AppSizes.spacingLarge);

  /// Padding vertical pour les écrans
  static EdgeInsets get verticalScreen => EdgeInsets.symmetric(vertical: AppSizes.screenPaddingVertical);

  // ===================
  // PADDINGS POUR COMPOSANTS SPÉCIFIQUES (RESPONSIVE)
  // ===================

  /// Padding pour les boutons
  static EdgeInsets get button =>
      EdgeInsets.symmetric(horizontal: AppSizes.buttonPaddingHorizontal, vertical: AppSizes.buttonPaddingVertical);

  /// Padding pour les cards
  static EdgeInsets get card => EdgeInsets.all(AppSizes.cardPadding);

  /// Padding pour l'écran entier
  static EdgeInsets get screen =>
      EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingHorizontal, vertical: AppSizes.screenPaddingVertical);
}

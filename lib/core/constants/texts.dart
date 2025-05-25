// lib/core/constants/text_styles.dart
import 'package:flutter/material.dart';
import '../responsive/responsive_sizes.dart';
import 'colors.dart';

abstract class AppTextStyles {
  // ===================
  // STYLES POUR LES TITRES (RESPONSIVE)
  // ===================

  static TextStyle get heading1 => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.h1,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    letterSpacing: ResponsiveSizes.letterSpacingTight,
    height: ResponsiveSizes.lineHeightNormal,
  );

  static TextStyle get heading2 => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.h2,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    letterSpacing: ResponsiveSizes.letterSpacingTight,
    height: ResponsiveSizes.lineHeightNormal,
  );

  static TextStyle get heading3 => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.h3,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
    height: ResponsiveSizes.lineHeightNormal,
  );

  // ===================
  // STYLES POUR LE CORPS DU TEXTE (RESPONSIVE)
  // ===================

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyLarge,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: ResponsiveSizes.lineHeightRelaxed,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyMedium,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: ResponsiveSizes.lineHeightNormal,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodySmall,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: ResponsiveSizes.lineHeightTight,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
  );

  // ===================
  // STYLES POUR LES ÉLÉMENTS INTERACTIFS (RESPONSIVE)
  // ===================

  static TextStyle get buttonText => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.buttonText,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: ResponsiveSizes.letterSpacingWide,
    height: ResponsiveSizes.lineHeightNormal,
  );

  static TextStyle get label => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
    height: ResponsiveSizes.lineHeightTight,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.caption,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
    height: ResponsiveSizes.lineHeightTight,
  );

  // ===================
  // STYLES POUR LES LIENS ET ÉLÉMENTS D'ACCENTUATION (RESPONSIVE)
  // ===================

  static TextStyle get link => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    height: ResponsiveSizes.lineHeightNormal,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
  );

  static TextStyle get emphasis => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyMedium,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
    height: ResponsiveSizes.lineHeightNormal,
  );

  // ===================
  // STYLES SPÉCIALISÉS (RESPONSIVE)
  // ===================

  /// Style pour les erreurs
  static TextStyle get error => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodySmall,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    height: ResponsiveSizes.lineHeightTight,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
  );

  /// Style pour les hints/placeholders
  static TextStyle get hint => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyMedium,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: ResponsiveSizes.lineHeightNormal,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
  );

  /// Style pour les badges/chips
  static TextStyle get badge => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodySmall,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: ResponsiveSizes.lineHeightTight,
    letterSpacing: ResponsiveSizes.letterSpacingWide,
  );

  /// Style pour les en-têtes de section
  static TextStyle get sectionHeader => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyLarge,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: ResponsiveSizes.lineHeightNormal,
    letterSpacing: ResponsiveSizes.letterSpacingTight,
  );

  /// Style pour les sous-titres
  static TextStyle get subtitle => TextStyle(
    fontFamily: 'Poppins',
    fontSize: ResponsiveSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: ResponsiveSizes.lineHeightNormal,
    letterSpacing: ResponsiveSizes.letterSpacingNormal,
  );

  // ===================
  // MÉTHODES UTILITAIRES POUR PERSONNALISATION
  // ===================

  /// Créer un style personnalisé basé sur bodyMedium
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize ?? ResponsiveSizes.bodyMedium,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.text,
      height: height ?? ResponsiveSizes.lineHeightNormal,
      letterSpacing: letterSpacing ?? ResponsiveSizes.letterSpacingNormal,
      decoration: decoration,
    );
  }

  /// Modifier un style existant
  static TextStyle modify(
    TextStyle baseStyle, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Créer un style avec une taille de police responsive personnalisée
  static TextStyle withCustomSize(
    double baseSize, {
    double? minSize,
    double? maxSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: ResponsiveSizes.customFontSize(baseSize, minSize: minSize, maxSize: maxSize),
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.text,
      height: height ?? ResponsiveSizes.lineHeightNormal,
      letterSpacing: letterSpacing ?? ResponsiveSizes.letterSpacingNormal,
    );
  }
}

// ===================
// EXTENSIONS POUR FACILITER L'UTILISATION
// ===================

extension TextStyleExtensions on TextStyle {
  /// Rendre le texte en gras
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Rendre le texte semi-gras
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Rendre le texte normal
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Rendre le texte léger
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Ajouter une couleur primaire
  TextStyle get primary => copyWith(color: AppColors.primary);

  /// Ajouter une couleur de texte secondaire
  TextStyle get secondary => copyWith(color: AppColors.textLight);

  /// Ajouter une couleur d'erreur
  TextStyle get error => copyWith(color: AppColors.error);

  /// Ajouter une couleur blanche
  TextStyle get white => copyWith(color: AppColors.white);

  /// Ajouter un soulignement
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);

  /// Supprimer la décoration
  TextStyle get noDecoration => copyWith(decoration: TextDecoration.none);
}

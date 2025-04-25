import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'package:osecours/core/constants/sizes.dart';

abstract class AppTextStyles {
  // Styles pour les titres
  static TextStyle heading1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.h1,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    letterSpacing: AppSizes.spacingTight, // Compression pour un look moderne
    height: AppSizes.lineHeightLarge, // Ajout pour une meilleure lisibilité
  );

  static TextStyle heading2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.h2,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    letterSpacing: AppSizes.spacingTight,
    height: AppSizes.lineHeightLarge,
  );

  static TextStyle heading3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.h3,
    fontWeight: FontWeight.w600, // Réduction du poids pour un contraste léger
    color: AppColors.text,
    letterSpacing: AppSizes.spacingMedium, // Plus espacé pour un style clair
    height: AppSizes.lineHeightMedium,
  );

  // Styles pour le corps du texte
  static TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyLarge,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: AppSizes.lineHeightLarge,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: AppSizes.lineHeightMedium,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodySmall,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: AppSizes.lineHeightSmall,
  );

  // Styles pour les labels et éléments interactifs
  static TextStyle buttonText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: AppSizes.spacingWide,
    height: AppSizes.lineHeightMedium,
  );

  static TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    letterSpacing: AppSizes.spacingMedium,
    height: AppSizes.lineHeightSmall,
  );

  static TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodySmall,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: AppSizes.spacingMedium,
    height: AppSizes.lineHeightSmall,
  );

  // Styles pour les liens et éléments d'accentuation
  static TextStyle link = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    height: AppSizes.lineHeightMedium,
  );

  static TextStyle emphasis = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: AppSizes.spacingMedium,
    height: AppSizes.lineHeightMedium,
  );
}

// lib/core/constants/themes.dart
import 'package:flutter/material.dart';
import 'sizes.dart';
import 'colors.dart';

/// Styles de texte de l'application utilisant les constantes fixes
abstract class AppTextStyles {
  // ===================
  // STYLES POUR LES TITRES
  // ===================

  static TextStyle heading1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.h1,
    fontWeight: FontWeight.w900,
    color: AppColors.text,
    letterSpacing: AppSizes.letterSpacingTight,
    height: AppSizes.lineHeightNormal,
  );

  static TextStyle heading2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.h2,
    fontWeight: FontWeight.w900,
    color: AppColors.text,
    letterSpacing: AppSizes.letterSpacingTight,
    height: AppSizes.lineHeightNormal,
  );

  static TextStyle heading3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.h3,
    fontWeight: FontWeight.w900,
    color: AppColors.text,
    letterSpacing: AppSizes.letterSpacingNormal,
    height: AppSizes.lineHeightNormal,
  );

  // ===================
  // STYLES POUR LE CORPS DU TEXTE
  // ===================

  static TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyLarge,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: AppSizes.lineHeightRelaxed,
    letterSpacing: AppSizes.letterSpacingNormal,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: AppSizes.lineHeightNormal,
    letterSpacing: AppSizes.letterSpacingNormal,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodySmall,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: AppSizes.lineHeightTight,
    letterSpacing: AppSizes.letterSpacingNormal,
  );

  // ===================
  // STYLES POUR LES ÉLÉMENTS INTERACTIFS
  // ===================

  static TextStyle buttonText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.buttonText,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: AppSizes.letterSpacingWide,
    height: AppSizes.lineHeightNormal,
  );

  static TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    letterSpacing: AppSizes.letterSpacingNormal,
    height: AppSizes.lineHeightTight,
  );

  static TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.caption,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: AppSizes.letterSpacingNormal,
    height: AppSizes.lineHeightTight,
  );

  // ===================
  // STYLES POUR LES LIENS ET ÉLÉMENTS D'ACCENTUATION
  // ===================

  static TextStyle link = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    height: AppSizes.lineHeightNormal,
    letterSpacing: AppSizes.letterSpacingNormal,
  );

  static TextStyle emphasis = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: AppSizes.letterSpacingNormal,
    height: AppSizes.lineHeightNormal,
  );

  // ===================
  // STYLES SPÉCIALISÉS
  // ===================

  /// Style pour les erreurs
  static TextStyle error = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodySmall,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    height: AppSizes.lineHeightTight,
    letterSpacing: AppSizes.letterSpacingNormal,
  );

  /// Style pour les hints/placeholders
  static TextStyle hint = TextStyle(
    fontFamily: 'Poppins',
    fontSize: AppSizes.bodyMedium,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: AppSizes.lineHeightNormal,
    letterSpacing: AppSizes.letterSpacingNormal,
  );
}

/// Thème principal de l'application
class AppTheme {
  // Couleurs personnalisées
  static Color primaryColor = AppColors.primary;
  static Color textColor = AppColors.text;
  static Color whiteColor = AppColors.white;

  // Thème clair avec constantes fixes
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: ColorScheme.light(primary: primaryColor, onPrimary: whiteColor, surface: whiteColor, onSurface: textColor),

    // AppBar Theme avec hauteur fixe
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: whiteColor),
      toolbarHeight: AppSizes.appBarHeight,
      titleTextStyle: TextStyle(color: whiteColor, fontSize: AppSizes.h3, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
    ),

    // Button Theme avec dimensions fixes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        minimumSize: Size(0, AppSizes.buttonHeight),
        padding: AppEdgeInsets.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
        textStyle: TextStyle(fontSize: AppSizes.buttonText, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
        textStyle: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
        minimumSize: Size(0, AppSizes.buttonHeight),
        padding: AppEdgeInsets.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusButton)),
        textStyle: TextStyle(fontSize: AppSizes.buttonText, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    ),

    // Input Decoration Theme avec dimensions fixes
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: whiteColor,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingMedium),

      // Bordures avec border radius fixe
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        borderSide: BorderSide(color: Colors.black54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        borderSide: BorderSide(color: Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),

      // Styles de texte fixes
      labelStyle: TextStyle(color: textColor, fontSize: AppSizes.bodyMedium, fontFamily: 'Poppins'),
      hintStyle: TextStyle(color: textColor.withOpacity(0.6), fontSize: AppSizes.bodyMedium, fontFamily: 'Poppins'),
      helperStyle: TextStyle(fontSize: AppSizes.bodySmall, fontFamily: 'Poppins'),
      errorStyle: TextStyle(fontSize: AppSizes.bodySmall, color: Colors.red, fontFamily: 'Poppins'),
    ),

    // Text Theme avec tailles fixes
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: AppSizes.h1, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Poppins'),
      displayMedium: TextStyle(fontSize: AppSizes.h2, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Poppins'),
      displaySmall: TextStyle(fontSize: AppSizes.h3, fontWeight: FontWeight.w600, color: textColor, fontFamily: 'Poppins'),
      bodyLarge: TextStyle(fontSize: AppSizes.bodyLarge, color: textColor, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(fontSize: AppSizes.bodyMedium, color: textColor, fontFamily: 'Poppins'),
      bodySmall: TextStyle(fontSize: AppSizes.bodySmall, color: textColor, fontFamily: 'Poppins'),
      labelLarge: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.w500, color: textColor, fontFamily: 'Poppins'),
    ),

    // Card Theme avec dimensions fixes
    cardTheme: CardTheme(
      color: whiteColor,
      elevation: AppSizes.elevationSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusCard)),
      margin: AppEdgeInsets.small,
    ),

    // List Tile Theme avec hauteur fixe
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium, vertical: AppSizes.spacingSmall),
      minVerticalPadding: AppSizes.spacingSmall,
      style: ListTileStyle.list,
      titleTextStyle: TextStyle(
        fontSize: AppSizes.bodyMedium,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: 'Poppins',
      ),
      subtitleTextStyle: TextStyle(fontSize: AppSizes.bodySmall, color: Colors.black54, fontFamily: 'Poppins'),
    ),

    // Dialog Theme avec dimensions fixes
    dialogTheme: DialogTheme(
      backgroundColor: whiteColor,
      elevation: AppSizes.elevationMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      titleTextStyle: TextStyle(fontSize: AppSizes.h3, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Poppins'),
      contentTextStyle: TextStyle(fontSize: AppSizes.bodyMedium, color: textColor, fontFamily: 'Poppins'),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: whiteColor,
      elevation: AppSizes.elevationLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge))),
    ),

    // Snack Bar Theme avec dimensions fixes
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: TextStyle(color: whiteColor, fontSize: AppSizes.bodyMedium, fontFamily: 'Poppins'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      insetPadding: AppEdgeInsets.medium,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      elevation: AppSizes.elevationMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
    ),

    // Icon Theme avec tailles fixes
    iconTheme: IconThemeData(color: textColor, size: AppSizes.iconMedium),

    // Primary Icon Theme
    primaryIconTheme: IconThemeData(color: whiteColor, size: AppSizes.iconMedium),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: whiteColor,
      deleteIconColor: primaryColor,
      disabledColor: Colors.grey[300],
      selectedColor: primaryColor.withOpacity(0.1),
      secondarySelectedColor: primaryColor.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingXSmall),
      labelPadding: EdgeInsets.symmetric(horizontal: AppSizes.spacingXSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
      labelStyle: TextStyle(fontSize: AppSizes.bodySmall, fontFamily: 'Poppins'),
      secondaryLabelStyle: TextStyle(fontSize: AppSizes.bodySmall, color: whiteColor, fontFamily: 'Poppins'),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(color: textColor.withOpacity(0.1), thickness: 1, space: AppSizes.spacingSmall),

    // Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: textColor.withOpacity(0.6),
      labelStyle: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      unselectedLabelStyle: TextStyle(fontSize: AppSizes.bodyMedium, fontWeight: FontWeight.w400, fontFamily: 'Poppins'),
      indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primaryColor, width: 2)),
    ),
  );

  // Thème sombre (identique pour l'instant)
  static ThemeData darkTheme = lightTheme;
}

// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../responsive/responsive_sizes.dart';

class AppTheme {
  // Couleurs personnalisées (maintenues pour compatibilité)
  static const Color primaryColor = Color(0xFFFF3333); // Rouge
  static const Color textColor = Color(0xFF000000); // Noir
  static const Color whiteColor = Color(0xFFFFFFFF); // Blanc

  // Thème clair avec système responsive intégré
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Poppins',
    useMaterial3: true,
    colorScheme: const ColorScheme.light(primary: primaryColor, onPrimary: whiteColor, surface: whiteColor, onSurface: textColor),

    // AppBar Theme avec hauteur responsive
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: whiteColor),
      toolbarHeight: ResponsiveSizes.appBarHeight, // Hauteur adaptative
      titleTextStyle: TextStyle(
        color: whiteColor,
        fontSize: ResponsiveSizes.h3, // Taille adaptative
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    // Button Theme avec dimensions responsives
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        minimumSize: Size(
          0, // Largeur flexible
          ResponsiveSizes.buttonHeight, // Hauteur adaptative
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSizes.buttonPaddingHorizontal, // Padding adaptatif
          vertical: ResponsiveSizes.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveSizes.radiusButton), // Border radius adaptatif
        ),
        textStyle: TextStyle(
          fontSize: ResponsiveSizes.buttonText, // Taille de texte adaptative
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingMedium, vertical: ResponsiveSizes.spacingSmall),
        textStyle: TextStyle(fontSize: ResponsiveSizes.bodyMedium, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        minimumSize: Size(0, ResponsiveSizes.buttonHeight),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSizes.buttonPaddingHorizontal,
          vertical: ResponsiveSizes.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveSizes.radiusButton)),
        textStyle: TextStyle(fontSize: ResponsiveSizes.buttonText, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
    ),

    // Input Decoration Theme avec dimensions responsives
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: whiteColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveSizes.spacingMedium, // Padding adaptatif
        vertical: ResponsiveSizes.spacingMedium,
      ),

      // Bordures avec border radius adaptatif
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveSizes.radiusSmall),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveSizes.radiusSmall),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveSizes.radiusSmall),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveSizes.radiusSmall),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),

      // Styles de texte adaptatifs
      labelStyle: TextStyle(color: textColor, fontSize: ResponsiveSizes.bodyMedium, fontFamily: 'Poppins'),
      hintStyle: TextStyle(color: textColor.withOpacity(0.6), fontSize: ResponsiveSizes.bodyMedium, fontFamily: 'Poppins'),
      helperStyle: TextStyle(fontSize: ResponsiveSizes.bodySmall, fontFamily: 'Poppins'),
      errorStyle: TextStyle(fontSize: ResponsiveSizes.bodySmall, color: Colors.red, fontFamily: 'Poppins'),
    ),

    // Text Theme avec tailles responsives
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: ResponsiveSizes.h1, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Poppins'),
      displayMedium: TextStyle(
        fontSize: ResponsiveSizes.h2,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: 'Poppins',
      ),
      displaySmall: TextStyle(fontSize: ResponsiveSizes.h3, fontWeight: FontWeight.w600, color: textColor, fontFamily: 'Poppins'),
      bodyLarge: TextStyle(fontSize: ResponsiveSizes.bodyLarge, color: textColor, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(fontSize: ResponsiveSizes.bodyMedium, color: textColor, fontFamily: 'Poppins'),
      bodySmall: TextStyle(fontSize: ResponsiveSizes.bodySmall, color: textColor, fontFamily: 'Poppins'),
      labelLarge: TextStyle(
        fontSize: ResponsiveSizes.bodyMedium,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: 'Poppins',
      ),
    ),

    // Card Theme avec dimensions responsives
    cardTheme: CardTheme(
      color: whiteColor,
      elevation: ResponsiveSizes.elevationSmall, // Élévation adaptative
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveSizes.radiusCard), // Border radius adaptatif
      ),
      margin: EdgeInsets.all(ResponsiveSizes.spacingSmall), // Marge adaptative
    ),

    // List Tile Theme avec hauteur responsive
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingMedium, vertical: ResponsiveSizes.spacingSmall),
      minVerticalPadding: ResponsiveSizes.spacingSmall,
      style: ListTileStyle.list,
      titleTextStyle: TextStyle(
        fontSize: ResponsiveSizes.bodyMedium,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: 'Poppins',
      ),
      subtitleTextStyle: TextStyle(fontSize: ResponsiveSizes.bodySmall, color: textColor.withOpacity(0.7), fontFamily: 'Poppins'),
    ),

    // Dialog Theme avec dimensions responsives
    dialogTheme: DialogTheme(
      backgroundColor: whiteColor,
      elevation: ResponsiveSizes.elevationMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveSizes.radiusMedium)),
      titleTextStyle: TextStyle(
        fontSize: ResponsiveSizes.h3,
        fontWeight: FontWeight.bold,
        color: textColor,
        fontFamily: 'Poppins',
      ),
      contentTextStyle: TextStyle(fontSize: ResponsiveSizes.bodyMedium, color: textColor, fontFamily: 'Poppins'),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: whiteColor,
      elevation: ResponsiveSizes.elevationLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveSizes.radiusLarge))),
    ),

    // Snack Bar Theme avec dimensions responsives
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: TextStyle(color: whiteColor, fontSize: ResponsiveSizes.bodyMedium, fontFamily: 'Poppins'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveSizes.radiusSmall)),
      insetPadding: EdgeInsets.all(ResponsiveSizes.spacingMedium),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      elevation: ResponsiveSizes.elevationMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveSizes.radiusMedium)),
    ),

    // Icon Theme avec tailles responsives
    iconTheme: IconThemeData(
      color: textColor,
      size: ResponsiveSizes.iconMedium, // Taille d'icône adaptative
    ),

    // Primary Icon Theme
    primaryIconTheme: IconThemeData(color: whiteColor, size: ResponsiveSizes.iconMedium),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: whiteColor,
      deleteIconColor: primaryColor,
      disabledColor: Colors.grey[300],
      selectedColor: primaryColor.withOpacity(0.1),
      secondarySelectedColor: primaryColor.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingSmall, vertical: ResponsiveSizes.spacingXSmall),
      labelPadding: EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingXSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveSizes.radiusSmall)),
      labelStyle: TextStyle(fontSize: ResponsiveSizes.bodySmall, fontFamily: 'Poppins'),
      secondaryLabelStyle: TextStyle(fontSize: ResponsiveSizes.bodySmall, color: whiteColor, fontFamily: 'Poppins'),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(color: textColor.withOpacity(0.1), thickness: 1, space: ResponsiveSizes.spacingSmall),

    // Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: textColor.withOpacity(0.6),
      labelStyle: TextStyle(fontSize: ResponsiveSizes.bodyMedium, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      unselectedLabelStyle: TextStyle(fontSize: ResponsiveSizes.bodyMedium, fontWeight: FontWeight.w400, fontFamily: 'Poppins'),
      indicator: UnderlineTabIndicator(borderSide: BorderSide(color: primaryColor, width: 2)),
    ),
  );

  // Thème sombre (maintenu pour compatibilité)
  static ThemeData darkTheme = lightTheme;
}

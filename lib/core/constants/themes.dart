// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';

class AppTheme {
  // Constantes pour les styles réutilisables
  static const BorderRadius _defaultBorderRadius = BorderRadius.all(Radius.circular(8));
  static const double _defaultElevation = 1.0;
  static const double _defaultPadding = 16.0;
  static const String _fontFamily = 'Poppins';

  /// Crée un thème de base personnalisé avec un ColorScheme donné
  static ThemeData _baseTheme(ColorScheme colorScheme, Brightness brightness) {
    // Ajustement des couleurs pour les contrastes et l'accessibilité
    final TextTheme textTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      bodyLarge: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      bodyMedium: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      labelLarge: TextStyle(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.w600),
    ).apply(fontFamily: _fontFamily);

    return ThemeData(
      // Propriétés globales
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme,

      // Card Theme
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: _defaultElevation,
        shape: const RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
        margin: const EdgeInsets.all(_defaultPadding),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.onSurface.withOpacity(0.5);
            return colorScheme.onPrimary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return colorScheme.primary.withOpacity(0.5);
            return colorScheme.primary;
          }),
          elevation: WidgetStateProperty.all(_defaultElevation),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colorScheme.surface,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: _defaultBorderRadius,
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _defaultBorderRadius,
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _defaultBorderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _defaultBorderRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: _defaultBorderRadius,
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(color: colorScheme.onSurface.withOpacity(0.2), thickness: 1, space: 1),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        elevation: 8,
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.error,
        contentTextStyle: TextStyle(color: colorScheme.onError),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: _defaultBorderRadius),
        elevation: 4,
      ),
    );
  }

  /// Thème clair basé sur les couleurs de l'application
  static ThemeData get lightTheme => _baseTheme(
    ColorScheme.light(
      primary: AppColors.primary, // Rouge défini dans AppColors
      onPrimary: AppColors.white, // Blanc pour contraste
      secondary: Colors.blue, // Bleu comme couleur secondaire
      onSecondary: AppColors.white,
      background: const Color(0xFFF5F5F5), // Gris clair pour fond
      onBackground: AppColors.text, // Noir/gris foncé pour texte
      surface: AppColors.white, // Blanc pour surfaces
      onSurface: AppColors.text, // Noir/gris foncé pour texte sur surfaces
      surfaceVariant: const Color(0xFFE0E0E0), // Gris pour variations
      onSurfaceVariant: const Color(0xFF333333), // Gris foncé pour texte secondaire
      error: AppColors.error, // Rouge/orange pour erreurs
      onError: AppColors.white, // Blanc sur erreurs
    ),
    Brightness.light,
  );

  /// Thème sombre basé sur les couleurs de l'application
  static ThemeData get darkTheme => _baseTheme(
    ColorScheme.dark(
      primary: AppColors.primary, // Rouge défini dans AppColors
      onPrimary: AppColors.white,
      secondary: Colors.blue, // Bleu comme couleur secondaire
      onSecondary: AppColors.white,
      background: const Color(0xFF1C2526), // Fond sombre
      onBackground: AppColors.white, // Texte blanc
      surface: const Color(0xFF2A2F31), // Surface sombre
      onSurface: AppColors.white, // Texte blanc sur surfaces
      surfaceVariant: const Color(0xFF3A3F41), // Variation sombre
      onSurfaceVariant: const Color(0xFFB0BEC5), // Gris clair pour texte secondaire
      error: AppColors.error, // Rouge/orange pour erreurs
      onError: AppColors.white,
    ),
    Brightness.dark,
  );
}

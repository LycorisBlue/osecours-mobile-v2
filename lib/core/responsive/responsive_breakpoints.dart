// lib/core/responsive/responsive_breakpoints.dart

/// Énumération des types d'écrans mobiles supportés
enum ScreenType {
  small, // < 360px
  regular, // 360px - 430px
  large, // > 430px
}

/// Classe contenant les breakpoints et utilitaires pour la responsivité mobile
abstract class ResponsiveBreakpoints {
  // Breakpoints en pixels
  static const double smallPhoneMaxWidth = 360.0;
  static const double regularPhoneMaxWidth = 430.0;

  // Hauteurs de référence pour différents types d'écrans
  static const double smallPhoneMaxHeight = 640.0;
  static const double regularPhoneMaxHeight = 800.0;

  // Facteurs de mise à l'échelle par type d'écran
  static const Map<ScreenType, double> scalingFactors = {
    ScreenType.small: 0.85, // Réduction pour petits écrans
    ScreenType.regular: 1.0, // Facteur de base
    ScreenType.large: 1.15, // Augmentation pour grands écrans
  };

  // Facteurs spécifiques pour les textes
  static const Map<ScreenType, double> textScalingFactors = {
    ScreenType.small: 0.9,
    ScreenType.regular: 1.0,
    ScreenType.large: 1.1,
  };

  // Facteurs pour les espacements
  static const Map<ScreenType, double> spacingScalingFactors = {
    ScreenType.small: 0.8,
    ScreenType.regular: 1.0,
    ScreenType.large: 1.2,
  };

  /// Détermine le type d'écran basé sur la largeur
  static ScreenType getScreenType(double width) {
    if (width < smallPhoneMaxWidth) {
      return ScreenType.small;
    } else if (width <= regularPhoneMaxWidth) {
      return ScreenType.regular;
    } else {
      return ScreenType.large;
    }
  }

  /// Vérifie si l'écran est considéré comme petit
  static bool isSmallScreen(double width) {
    return width < smallPhoneMaxWidth;
  }

  /// Vérifie si l'écran est considéré comme grand
  static bool isLargeScreen(double width) {
    return width > regularPhoneMaxWidth;
  }

  /// Obtient le facteur de mise à l'échelle général pour une largeur donnée
  static double getScalingFactor(double width) {
    final screenType = getScreenType(width);
    return scalingFactors[screenType] ?? 1.0;
  }

  /// Obtient le facteur de mise à l'échelle spécifique au texte
  static double getTextScalingFactor(double width) {
    final screenType = getScreenType(width);
    return textScalingFactors[screenType] ?? 1.0;
  }

  /// Obtient le facteur de mise à l'échelle pour les espacements
  static double getSpacingScalingFactor(double width) {
    final screenType = getScreenType(width);
    return spacingScalingFactors[screenType] ?? 1.0;
  }
}

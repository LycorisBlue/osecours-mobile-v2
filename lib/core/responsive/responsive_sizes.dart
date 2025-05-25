// lib/core/responsive/responsive_sizes.dart

import 'responsive_breakpoints.dart';
import 'responsive_manager.dart';

/// Système de tailles adaptatif remplaçant les constantes fixes
/// Toutes les valeurs sont calculées de façon fluide avec contraintes min/max
abstract class ResponsiveSizes {
  static final ResponsiveManager _manager = ResponsiveManager();

  // ===================
  // TAILLES DE POLICE
  // ===================

  /// Titre principal - très grand
  static double get h1 => _manager.scaledFontSize(28.0, minSize: 24.0, maxSize: 32.0);

  /// Titre secondaire - grand
  static double get h2 => _manager.scaledFontSize(24.0, minSize: 20.0, maxSize: 28.0);

  /// Titre tertiaire - moyen
  static double get h3 => _manager.scaledFontSize(20.0, minSize: 18.0, maxSize: 24.0);

  /// Corps de texte - grand
  static double get bodyLarge => _manager.scaledFontSize(16.0, minSize: 14.0, maxSize: 18.0);

  /// Corps de texte - moyen
  static double get bodyMedium => _manager.scaledFontSize(14.0, minSize: 12.0, maxSize: 16.0);

  /// Corps de texte - petit
  static double get bodySmall => _manager.scaledFontSize(12.0, minSize: 10.0, maxSize: 14.0);

  /// Texte de bouton
  static double get buttonText => _manager.scaledFontSize(16.0, minSize: 14.0, maxSize: 18.0);

  /// Texte de caption/légende
  static double get caption => _manager.scaledFontSize(12.0, minSize: 10.0, maxSize: 14.0);

  // ===================
  // ESPACEMENTS (PADDING/MARGIN)
  // ===================

  /// Espacement très petit
  static double get spacingXSmall => _manager.scaledSpacing(4.0, minSpacing: 2.0, maxSpacing: 6.0);

  /// Espacement petit
  static double get spacingSmall => _manager.scaledSpacing(8.0, minSpacing: 6.0, maxSpacing: 12.0);

  /// Espacement moyen
  static double get spacingMedium => _manager.scaledSpacing(16.0, minSpacing: 12.0, maxSpacing: 20.0);

  /// Espacement grand
  static double get spacingLarge => _manager.scaledSpacing(24.0, minSpacing: 20.0, maxSpacing: 32.0);

  /// Espacement très grand
  static double get spacingXLarge => _manager.scaledSpacing(32.0, minSpacing: 24.0, maxSpacing: 40.0);

  /// Espacement énorme
  static double get spacingXXLarge => _manager.scaledSpacing(48.0, minSpacing: 36.0, maxSpacing: 64.0);

  // ===================
  // PADDINGS SPÉCIFIQUES
  // ===================

  /// Padding horizontal pour les écrans
  static double get screenPaddingHorizontal => _manager.widthPercent(
    5.0, // 5% de la largeur
    minValue: 16.0,
    maxValue: 24.0,
  );

  /// Padding vertical pour les écrans
  static double get screenPaddingVertical => _manager.scaledSpacing(20.0, minSpacing: 16.0, maxSpacing: 28.0);

  /// Padding pour les boutons
  static double get buttonPaddingHorizontal => _manager.scaledSpacing(16.0, minSpacing: 12.0, maxSpacing: 20.0);

  static double get buttonPaddingVertical => _manager.scaledSpacing(12.0, minSpacing: 10.0, maxSpacing: 16.0);

  /// Padding pour les cards
  static double get cardPadding => _manager.scaledSpacing(16.0, minSpacing: 12.0, maxSpacing: 20.0);

  // ===================
  // HAUTEURS ADAPTATIVES
  // ===================

  /// Hauteur des boutons
  static double get buttonHeight => _manager.scaledSpacing(48.0, minSpacing: 44.0, maxSpacing: 56.0);

  /// Hauteur des champs de texte
  static double get inputHeight => _manager.scaledSpacing(48.0, minSpacing: 44.0, maxSpacing: 52.0);

  /// Hauteur de l'AppBar
  static double get appBarHeight => _manager.scaledSpacing(56.0, minSpacing: 52.0, maxSpacing: 64.0);

  /// Hauteur des éléments de liste
  static double get listItemHeight => _manager.scaledSpacing(60.0, minSpacing: 56.0, maxSpacing: 72.0);

  // ===================
  // BORDER RADIUS
  // ===================

  /// Border radius petit
  static double get radiusSmall => _manager.scaledSpacing(8.0, minSpacing: 6.0, maxSpacing: 10.0);

  /// Border radius moyen
  static double get radiusMedium => _manager.scaledSpacing(12.0, minSpacing: 10.0, maxSpacing: 16.0);

  /// Border radius grand
  static double get radiusLarge => _manager.scaledSpacing(16.0, minSpacing: 12.0, maxSpacing: 20.0);

  /// Border radius pour les boutons
  static double get radiusButton => radiusSmall;

  /// Border radius pour les cards
  static double get radiusCard => radiusMedium;

  // ===================
  // ÉLÉVATIONS
  // ===================

  /// Élévation petite
  static double get elevationSmall => _manager.screenType == ScreenType.small ? 1.0 : 2.0;

  /// Élévation moyenne
  static double get elevationMedium => _manager.screenType == ScreenType.small ? 2.0 : 4.0;

  /// Élévation grande
  static double get elevationLarge => _manager.screenType == ScreenType.small ? 4.0 : 8.0;

  // ===================
  // TAILLES D'ICÔNES
  // ===================

  /// Icône petite
  static double get iconSmall => _manager.scaledSpacing(16.0, minSpacing: 14.0, maxSpacing: 18.0);

  /// Icône moyenne
  static double get iconMedium => _manager.scaledSpacing(24.0, minSpacing: 20.0, maxSpacing: 28.0);

  /// Icône grande
  static double get iconLarge => _manager.scaledSpacing(32.0, minSpacing: 28.0, maxSpacing: 36.0);

  // ===================
  // CONSTANTES DE TEXTE
  // ===================

  /// Line heights (multiplicateurs)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  /// Letter spacing
  static const double letterSpacingTight = -0.25;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  // ===================
  // MÉTHODES UTILITAIRES
  // ===================

  /// Calcule un espacement personnalisé avec facteur
  static double customSpacing(double baseValue, {double? minValue, double? maxValue}) {
    return _manager.scaledSpacing(baseValue, minSpacing: minValue, maxSpacing: maxValue);
  }

  /// Calcule une taille de police personnalisée
  static double customFontSize(double baseSize, {double? minSize, double? maxSize}) {
    return _manager.scaledFontSize(baseSize, minSize: minSize, maxSize: maxSize);
  }

  /// Calcule un pourcentage de largeur d'écran
  static double widthPercent(double percent, {double? minValue, double? maxValue}) {
    return _manager.widthPercent(percent, minValue: minValue, maxValue: maxValue);
  }

  /// Calcule un pourcentage de hauteur d'écran
  static double heightPercent(double percent, {double? minValue, double? maxValue}) {
    return _manager.heightPercent(percent, minValue: minValue, maxValue: maxValue);
  }
}

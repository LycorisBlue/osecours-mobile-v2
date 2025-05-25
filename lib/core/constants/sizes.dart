// lib/core/constants/sizes.dart
import 'package:flutter/material.dart';
import '../responsive/responsive_manager.dart';
import '../responsive/responsive_sizes.dart';

/// Classe de transition pour maintenir la compatibilité pendant la migration
/// DÉPRÉCIÉ : Utilisez ResponsiveSizes à la place
class AppSizes {
  // Singleton pattern (maintenu pour compatibilité)
  static final AppSizes _instance = AppSizes._internal();
  factory AppSizes() => _instance;
  AppSizes._internal();

  // Variables d'état (conservées pour rétrocompatibilité)
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double _safeBlockHorizontal;
  static late double _safeBlockVertical;
  static late bool _isInitialized;

  /// Méthode d'initialisation (DÉPRÉCIÉ)
  /// Utilisez ResponsiveManager().initialize(context) à la place
  @Deprecated('Utilisez ResponsiveManager().initialize(context)')
  static void initialize(BuildContext context) {
    // Initialiser le nouveau système
    ResponsiveManager().initialize(context);

    // Maintenir l'ancien système pour compatibilité
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    _safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    _safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;

    _isInitialized = true;
  }

  static void _checkInitialization() {
    assert(_isInitialized, 'AppSizes n\'est pas initialisé. Appelez AppSizes.initialize(context) dans votre widget racine.');
  }

  // ===================
  // MÉTHODES DÉPRÉCIÉES - Redirection vers le nouveau système
  // ===================

  /// DÉPRÉCIÉ : Utilisez ResponsiveSizes.widthPercent()
  @Deprecated('Utilisez ResponsiveSizes.widthPercent()')
  static double percentWidth(double percent) {
    try {
      return ResponsiveSizes.widthPercent(percent);
    } catch (e) {
      // Fallback vers l'ancien système si le nouveau n'est pas initialisé
      _checkInitialization();
      return _safeBlockHorizontal * percent;
    }
  }

  /// DÉPRÉCIÉ : Utilisez ResponsiveSizes.heightPercent()
  @Deprecated('Utilisez ResponsiveSizes.heightPercent()')
  static double percentHeight(double percent) {
    try {
      return ResponsiveSizes.heightPercent(percent);
    } catch (e) {
      // Fallback vers l'ancien système si le nouveau n'est pas initialisé
      _checkInitialization();
      return _safeBlockVertical * percent;
    }
  }

  /// DÉPRÉCIÉ : Utilisez ResponsiveSizes.customFontSize()
  @Deprecated('Utilisez ResponsiveSizes.customFontSize()')
  static double scaledFontSize(double size) {
    try {
      return ResponsiveSizes.customFontSize(size);
    } catch (e) {
      // Fallback vers l'ancien système
      _checkInitialization();
      double scaleFactor = _screenWidth / 375;
      return size * scaleFactor;
    }
  }

  /// DÉPRÉCIÉ : Utilisez ResponsiveManager().widthPercent() avec useSafeArea: false
  @Deprecated('Utilisez ResponsiveManager().widthPercent() avec useSafeArea: false')
  static double fullPercentWidth(double percent) {
    try {
      return ResponsiveManager().widthPercent(percent, useSafeArea: false);
    } catch (e) {
      _checkInitialization();
      return _blockSizeHorizontal * percent;
    }
  }

  /// DÉPRÉCIÉ : Utilisez ResponsiveManager().heightPercent() avec useSafeArea: false
  @Deprecated('Utilisez ResponsiveManager().heightPercent() avec useSafeArea: false')
  static double fullPercentHeight(double percent) {
    try {
      return ResponsiveManager().heightPercent(percent, useSafeArea: false);
    } catch (e) {
      _checkInitialization();
      return _blockSizeVertical * percent;
    }
  }

  // ===================
  // NOUVELLES PROPRIÉTÉS - Redirection vers ResponsiveSizes
  // ===================

  /// Tailles de police adaptatives (NOUVEAU SYSTÈME)
  static double get h1 => ResponsiveSizes.h1;
  static double get h2 => ResponsiveSizes.h2;
  static double get h3 => ResponsiveSizes.h3;
  static double get bodyLarge => ResponsiveSizes.bodyLarge;
  static double get bodyMedium => ResponsiveSizes.bodyMedium;
  static double get bodySmall => ResponsiveSizes.bodySmall;

  /// Line heights (conservées)
  static const double lineHeightLarge = ResponsiveSizes.lineHeightRelaxed;
  static const double lineHeightMedium = ResponsiveSizes.lineHeightNormal;
  static const double lineHeightSmall = ResponsiveSizes.lineHeightTight;

  /// Letter spacing (conservées)
  static const double spacingTight = ResponsiveSizes.letterSpacingTight;
  static const double spacingMedium = ResponsiveSizes.letterSpacingNormal;
  static const double spacingWide = ResponsiveSizes.letterSpacingWide;

  /// Paddings responsifs (NOUVEAU SYSTÈME)
  static double get paddingSmall => ResponsiveSizes.spacingSmall;
  static double get paddingMedium => ResponsiveSizes.spacingMedium;
  static double get paddingLarge => ResponsiveSizes.spacingLarge;
  static double get paddingXLarge => ResponsiveSizes.spacingXLarge;

  /// Border radius (NOUVEAU SYSTÈME)
  static double get radiusSmall => ResponsiveSizes.radiusSmall;
  static double get radiusMedium => ResponsiveSizes.radiusMedium;

  /// Élévations (NOUVEAU SYSTÈME)
  static double get elevationSmall => ResponsiveSizes.elevationSmall;

  // ===================
  // GETTERS POUR COMPATIBILITÉ
  // ===================

  /// DÉPRÉCIÉ : Utilisez ResponsiveManager().screenWidth
  @Deprecated('Utilisez ResponsiveManager().screenWidth')
  static double get screenWidth {
    try {
      return ResponsiveManager().screenWidth;
    } catch (e) {
      return _screenWidth;
    }
  }

  /// DÉPRÉCIÉ : Utilisez ResponsiveManager().screenHeight
  @Deprecated('Utilisez ResponsiveManager().screenHeight')
  static double get screenHeight {
    try {
      return ResponsiveManager().screenHeight;
    } catch (e) {
      return _screenHeight;
    }
  }
}

// ===================
// EXTENSIONS POUR FACILITER LA MIGRATION
// ===================

extension ResponsiveExtensions on BuildContext {
  /// Extension pour accéder au manager responsive
  ResponsiveManager get responsive => ResponsiveManager();
}

// ===================
// FONCTIONS GLOBALES POUR MIGRATION RAPIDE
// ===================

/// Fonction globale pour faciliter la migration des tailles de police
double responsiveFont(double baseSize, {double? minSize, double? maxSize}) {
  return ResponsiveSizes.customFontSize(baseSize, minSize: minSize, maxSize: maxSize);
}

/// Fonction globale pour faciliter la migration des espacements
double responsiveSpacing(double baseSpacing, {double? minSpacing, double? maxSpacing}) {
  return ResponsiveSizes.customSpacing(baseSpacing, minValue: minSpacing, maxValue: maxSpacing);
}

/// Fonction globale pour faciliter la migration des pourcentages de largeur
double responsiveWidth(double percent, {double? minValue, double? maxValue}) {
  return ResponsiveSizes.widthPercent(percent, minValue: minValue, maxValue: maxValue);
}

/// Fonction globale pour faciliter la migration des pourcentages de hauteur
double responsiveHeight(double percent, {double? minValue, double? maxValue}) {
  return ResponsiveSizes.heightPercent(percent, minValue: minValue, maxValue: maxValue);
}

// lib/core/constants/sizes.dart
import 'package:flutter/material.dart';

class AppSizes {
  // Singleton pattern
  static final AppSizes _instance = AppSizes._internal();
  factory AppSizes() => _instance;
  AppSizes._internal();

  // État des dimensions
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _blockSizeHorizontal;
  static late double _blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double _safeBlockHorizontal;
  static late double _safeBlockVertical;
  static late bool _isInitialized;

  // Méthode d'initialisation à appeler dans votre main ou splash screen
  static void initialize(BuildContext context) {
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

  // Vérifier que les dimensions ont été initialisées
  static void _checkInitialization() {
    assert(_isInitialized, 'AppSizes n\'est pas initialisé. Appelez AppSizes.initialize(context) dans votre widget racine.');
  }

  // Récupérer un pourcentage de la largeur d'écran (utile pour les colonnes et layouts)
  static double percentWidth(double percent) {
    _checkInitialization();
    return _safeBlockHorizontal * percent;
  }

  // Récupérer un pourcentage de la hauteur d'écran (utile pour les lignes et espaces verticaux)
  static double percentHeight(double percent) {
    _checkInitialization();
    return _safeBlockVertical * percent;
  }

  // Fonction pour l'adaptation des tailles de police selon l'écran
  static double scaledFontSize(double size) {
    _checkInitialization();
    double scaleFactor = _screenWidth / 375; // Base sur iPhone 8 comme référence
    return size * scaleFactor;
  }

  // Récupérer un pourcentage de la largeur d'écran totale (sans tenir compte des zones de sécurité)
  static double fullPercentWidth(double percent) {
    _checkInitialization();
    return _blockSizeHorizontal * percent;
  }

  // Récupérer un pourcentage de la hauteur d'écran totale (sans tenir compte des zones de sécurité)
  static double fullPercentHeight(double percent) {
    _checkInitialization();
    return _blockSizeVertical * percent;
  }

  // Tailles de police adaptatives
  static double get h1 => scaledFontSize(28.0);
  static double get h2 => scaledFontSize(24.0);
  static double get h3 => scaledFontSize(20.0);
  static double get bodyLarge => scaledFontSize(16.0);
  static double get bodyMedium => scaledFontSize(14.0);
  static double get bodySmall => scaledFontSize(12.0);

  // Line heights (multiplicateurs)
  static const double lineHeightLarge = 1.6;
  static const double lineHeightMedium = 1.5;
  static const double lineHeightSmall = 1.4;

  // Letter spacing
  static const double spacingTight = -0.25;
  static const double spacingMedium = 0.0;
  static const double spacingWide = 0.5;

  // Paddings responsifs
  static double get paddingSmall => percentWidth(2.0); // ~8.0
  static double get paddingMedium => percentWidth(3.0); // ~12.0
  static double get paddingLarge => percentWidth(4.0); // ~16.0
  static double get paddingXLarge => percentWidth(6.0); // ~24.0

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;

  // Élévations
  static const double elevationSmall = 2.0;

  // Getters pour les dimensions de l'écran
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
}

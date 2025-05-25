// lib/core/responsive/responsive_manager.dart

import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Gestionnaire central du système responsive
/// Singleton qui gère les calculs de dimensions et la mise en cache
class ResponsiveManager {
  static final ResponsiveManager _instance = ResponsiveManager._internal();
  factory ResponsiveManager() => _instance;
  ResponsiveManager._internal();

  // Cache des valeurs calculées pour optimisation
  final Map<String, double> _cache = {};

  // Dimensions actuelles de l'écran
  late double _screenWidth;
  late double _screenHeight;
  late double _safeAreaHorizontal;
  late double _safeAreaVertical;
  late ScreenType _screenType;

  // États d'initialisation
  bool _isInitialized = false;

  /// Initialise le gestionnaire avec les dimensions de l'écran
  void initialize(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final EdgeInsets padding = mediaQuery.padding;

    _screenWidth = screenSize.width;
    _screenHeight = screenSize.height;
    _safeAreaHorizontal = padding.left + padding.right;
    _safeAreaVertical = padding.top + padding.bottom;
    _screenType = ResponsiveBreakpoints.getScreenType(_screenWidth);

    // Vider le cache lors de la réinitialisation
    _cache.clear();
    _isInitialized = true;
  }

  /// Vérifie que le gestionnaire est initialisé
  void _checkInitialization() {
    if (!_isInitialized) {
      throw StateError(
        'ResponsiveManager n\'est pas initialisé. '
        'Appelez ResponsiveManager().initialize(context) avant utilisation.',
      );
    }
  }

  // Getters pour les propriétés de base
  double get screenWidth {
    _checkInitialization();
    return _screenWidth;
  }

  double get screenHeight {
    _checkInitialization();
    return _screenHeight;
  }

  double get safeWidth {
    _checkInitialization();
    return _screenWidth - _safeAreaHorizontal;
  }

  double get safeHeight {
    _checkInitialization();
    return _screenHeight - _safeAreaVertical;
  }

  ScreenType get screenType {
    _checkInitialization();
    return _screenType;
  }

  /// Calcule une largeur en pourcentage avec contraintes min/max
  double widthPercent(double percent, {double? minValue, double? maxValue, bool useSafeArea = true}) {
    _checkInitialization();

    final String cacheKey = 'w_${percent}_${minValue}_${maxValue}_$useSafeArea';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final double baseWidth = useSafeArea ? safeWidth : _screenWidth;
    double result = (baseWidth * percent / 100);

    // Application des contraintes
    if (minValue != null) result = result.clamp(minValue, double.infinity);
    if (maxValue != null) result = result.clamp(0, maxValue);

    _cache[cacheKey] = result;
    return result;
  }

  /// Calcule une hauteur en pourcentage avec contraintes min/max
  double heightPercent(double percent, {double? minValue, double? maxValue, bool useSafeArea = true}) {
    _checkInitialization();

    final String cacheKey = 'h_${percent}_${minValue}_${maxValue}_$useSafeArea';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final double baseHeight = useSafeArea ? safeHeight : _screenHeight;
    double result = (baseHeight * percent / 100);

    // Application des contraintes
    if (minValue != null) result = result.clamp(minValue, double.infinity);
    if (maxValue != null) result = result.clamp(0, maxValue);

    _cache[cacheKey] = result;
    return result;
  }

  /// Calcule une taille de police adaptative
  double scaledFontSize(double baseSize, {double? minSize, double? maxSize}) {
    _checkInitialization();

    final String cacheKey = 'font_${baseSize}_${minSize}_${maxSize}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Calcul basé sur la largeur avec facteur d'écran
    final double scaleFactor = _screenWidth / 375; // iPhone 8 comme référence
    final double screenTypeFactor = ResponsiveBreakpoints.getTextScalingFactor(_screenWidth);

    double result = baseSize * scaleFactor * screenTypeFactor;

    // Application des contraintes
    if (minSize != null) result = result.clamp(minSize, double.infinity);
    if (maxSize != null) result = result.clamp(0, maxSize);

    _cache[cacheKey] = result;
    return result;
  }

  /// Calcule un espacement adaptatif
  double scaledSpacing(double baseSpacing, {double? minSpacing, double? maxSpacing}) {
    _checkInitialization();

    final String cacheKey = 'spacing_${baseSpacing}_${minSpacing}_${maxSpacing}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final double spacingFactor = ResponsiveBreakpoints.getSpacingScalingFactor(_screenWidth);
    final double widthFactor = _screenWidth / 375; // Base de référence

    double result = baseSpacing * widthFactor * spacingFactor;

    // Application des contraintes
    if (minSpacing != null) result = result.clamp(minSpacing, double.infinity);
    if (maxSpacing != null) result = result.clamp(0, maxSpacing);

    _cache[cacheKey] = result;
    return result;
  }

  /// Nettoie le cache (utile lors de rotations ou changements d'orientation)
  void clearCache() {
    _cache.clear();
  }

  /// Méthode de débogage pour afficher les informations d'écran
  Map<String, dynamic> getDebugInfo() {
    _checkInitialization();
    return {
      'screenWidth': _screenWidth,
      'screenHeight': _screenHeight,
      'safeWidth': safeWidth,
      'safeHeight': safeHeight,
      'screenType': _screenType.toString(),
      'cacheSize': _cache.length,
    };
  }
}

// lib/core/widgets/responsive_padding.dart

import 'package:flutter/material.dart';
import '../responsive/responsive_sizes.dart';

/// Widget helper pour padding adaptatif
/// Fournit des presets et des calculs automatiques pour les espacements
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ResponsivePaddingType? _type;
  final double? _customHorizontal;
  final double? _customVertical;

  const ResponsivePadding({super.key, required this.child, required this.padding})
    : _type = null,
      _customHorizontal = null,
      _customVertical = null;

  /// Padding très petit (adaptatif)
  const ResponsivePadding.xSmall({super.key, required this.child})
    : padding = null,
      _type = ResponsivePaddingType.xSmall,
      _customHorizontal = null,
      _customVertical = null;

  /// Padding petit (adaptatif)
  const ResponsivePadding.small({super.key, required this.child})
    : padding = null,
      _type = ResponsivePaddingType.small,
      _customHorizontal = null,
      _customVertical = null;

  /// Padding moyen (adaptatif)
  const ResponsivePadding.medium({super.key, required this.child})
    : padding = null,
      _type = ResponsivePaddingType.medium,
      _customHorizontal = null,
      _customVertical = null;

  /// Padding grand (adaptatif)
  const ResponsivePadding.large({super.key, required this.child})
    : padding = null,
      _type = ResponsivePaddingType.large,
      _customHorizontal = null,
      _customVertical = null;

  /// Padding très grand (adaptatif)
  const ResponsivePadding.xLarge({super.key, required this.child})
    : padding = null,
      _type = ResponsivePaddingType.xLarge,
      _customHorizontal = null,
      _customVertical = null;

  /// Padding horizontal pour les écrans
  const ResponsivePadding.screen({super.key, required this.child})
    : padding = null,
      _type = ResponsivePaddingType.screen,
      _customHorizontal = null,
      _customVertical = null;

  /// Padding horizontal seulement
  const ResponsivePadding.horizontal({super.key, required this.child, double? value})
    : padding = null,
      _type = ResponsivePaddingType.horizontal,
      _customHorizontal = value,
      _customVertical = null;

  /// Padding vertical seulement
  const ResponsivePadding.vertical({super.key, required this.child, double? value})
    : padding = null,
      _type = ResponsivePaddingType.vertical,
      _customHorizontal = null,
      _customVertical = value;

  /// Padding symétrique
  const ResponsivePadding.symmetric({super.key, required this.child, double? horizontal, double? vertical})
    : padding = null,
      _type = ResponsivePaddingType.symmetric,
      _customHorizontal = horizontal,
      _customVertical = vertical;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry effectivePadding;

    if (padding != null) {
      effectivePadding = padding!;
    } else {
      switch (_type) {
        case ResponsivePaddingType.xSmall:
          effectivePadding = EdgeInsets.all(ResponsiveSizes.spacingXSmall);
          break;
        case ResponsivePaddingType.small:
          effectivePadding = EdgeInsets.all(ResponsiveSizes.spacingSmall);
          break;
        case ResponsivePaddingType.medium:
          effectivePadding = EdgeInsets.all(ResponsiveSizes.spacingMedium);
          break;
        case ResponsivePaddingType.large:
          effectivePadding = EdgeInsets.all(ResponsiveSizes.spacingLarge);
          break;
        case ResponsivePaddingType.xLarge:
          effectivePadding = EdgeInsets.all(ResponsiveSizes.spacingXLarge);
          break;
        case ResponsivePaddingType.screen:
          effectivePadding = EdgeInsets.symmetric(
            horizontal: ResponsiveSizes.screenPaddingHorizontal,
            vertical: ResponsiveSizes.screenPaddingVertical,
          );
          break;
        case ResponsivePaddingType.horizontal:
          effectivePadding = EdgeInsets.symmetric(
            horizontal:
                _customHorizontal != null ? ResponsiveSizes.customSpacing(_customHorizontal!) : ResponsiveSizes.spacingMedium,
          );
          break;
        case ResponsivePaddingType.vertical:
          effectivePadding = EdgeInsets.symmetric(
            vertical: _customVertical != null ? ResponsiveSizes.customSpacing(_customVertical!) : ResponsiveSizes.spacingMedium,
          );
          break;
        case ResponsivePaddingType.symmetric:
          effectivePadding = EdgeInsets.symmetric(
            horizontal: _customHorizontal != null ? ResponsiveSizes.customSpacing(_customHorizontal!) : 0,
            vertical: _customVertical != null ? ResponsiveSizes.customSpacing(_customVertical!) : 0,
          );
          break;
        default:
          effectivePadding = EdgeInsets.all(ResponsiveSizes.spacingMedium);
      }
    }

    return Padding(padding: effectivePadding, child: child);
  }
}

/// Énumération pour les types de padding
enum ResponsivePaddingType { xSmall, small, medium, large, xLarge, screen, horizontal, vertical, symmetric }

/// Classe utilitaire pour créer des EdgeInsets responsifs
abstract class ResponsiveEdgeInsets {
  // ===================
  // PADDINGS UNIFORMES
  // ===================

  /// Padding très petit
  static EdgeInsets get xSmall => EdgeInsets.all(ResponsiveSizes.spacingXSmall);

  /// Padding petit
  static EdgeInsets get small => EdgeInsets.all(ResponsiveSizes.spacingSmall);

  /// Padding moyen
  static EdgeInsets get medium => EdgeInsets.all(ResponsiveSizes.spacingMedium);

  /// Padding grand
  static EdgeInsets get large => EdgeInsets.all(ResponsiveSizes.spacingLarge);

  /// Padding très grand
  static EdgeInsets get xLarge => EdgeInsets.all(ResponsiveSizes.spacingXLarge);

  /// Padding énorme
  static EdgeInsets get xxLarge => EdgeInsets.all(ResponsiveSizes.spacingXXLarge);

  // ===================
  // PADDINGS HORIZONTAUX
  // ===================

  /// Padding horizontal très petit
  static EdgeInsets get horizontalXSmall => EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingXSmall);

  /// Padding horizontal petit
  static EdgeInsets get horizontalSmall => EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingSmall);

  /// Padding horizontal moyen
  static EdgeInsets get horizontalMedium => EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingMedium);

  /// Padding horizontal grand
  static EdgeInsets get horizontalLarge => EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingLarge);

  /// Padding horizontal très grand
  static EdgeInsets get horizontalXLarge => EdgeInsets.symmetric(horizontal: ResponsiveSizes.spacingXLarge);

  /// Padding horizontal pour les écrans
  static EdgeInsets get horizontalScreen => EdgeInsets.symmetric(horizontal: ResponsiveSizes.screenPaddingHorizontal);

  // ===================
  // PADDINGS VERTICAUX
  // ===================

  /// Padding vertical très petit
  static EdgeInsets get verticalXSmall => EdgeInsets.symmetric(vertical: ResponsiveSizes.spacingXSmall);

  /// Padding vertical petit
  static EdgeInsets get verticalSmall => EdgeInsets.symmetric(vertical: ResponsiveSizes.spacingSmall);

  /// Padding vertical moyen
  static EdgeInsets get verticalMedium => EdgeInsets.symmetric(vertical: ResponsiveSizes.spacingMedium);

  /// Padding vertical grand
  static EdgeInsets get verticalLarge => EdgeInsets.symmetric(vertical: ResponsiveSizes.spacingLarge);

  /// Padding vertical très grand
  static EdgeInsets get verticalXLarge => EdgeInsets.symmetric(vertical: ResponsiveSizes.spacingXLarge);

  /// Padding vertical pour les écrans
  static EdgeInsets get verticalScreen => EdgeInsets.symmetric(vertical: ResponsiveSizes.screenPaddingVertical);

  // ===================
  // PADDINGS POUR COMPOSANTS SPÉCIFIQUES
  // ===================

  /// Padding pour les boutons
  static EdgeInsets get button =>
      EdgeInsets.symmetric(horizontal: ResponsiveSizes.buttonPaddingHorizontal, vertical: ResponsiveSizes.buttonPaddingVertical);

  /// Padding pour les cards
  static EdgeInsets get card => EdgeInsets.all(ResponsiveSizes.cardPadding);

  /// Padding pour l'écran entier
  static EdgeInsets get screen =>
      EdgeInsets.symmetric(horizontal: ResponsiveSizes.screenPaddingHorizontal, vertical: ResponsiveSizes.screenPaddingVertical);

  // ===================
  // MÉTHODES UTILITAIRES
  // ===================

  /// Crée un padding personnalisé avec des valeurs responsives
  static EdgeInsets custom({
    double? top,
    double? bottom,
    double? left,
    double? right,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    return EdgeInsets.only(
      top: ResponsiveSizes.customSpacing(top ?? vertical ?? all ?? 0),
      bottom: ResponsiveSizes.customSpacing(bottom ?? vertical ?? all ?? 0),
      left: ResponsiveSizes.customSpacing(left ?? horizontal ?? all ?? 0),
      right: ResponsiveSizes.customSpacing(right ?? horizontal ?? all ?? 0),
    );
  }

  /// Crée un padding symétrique avec des valeurs responsives
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? ResponsiveSizes.customSpacing(horizontal) : 0,
      vertical: vertical != null ? ResponsiveSizes.customSpacing(vertical) : 0,
    );
  }

  /// Crée un padding uniforme avec une valeur responsive
  static EdgeInsets all(double value) {
    return EdgeInsets.all(ResponsiveSizes.customSpacing(value));
  }

  /// Crée un padding avec des valeurs de base qui seront adaptées
  static EdgeInsets fromBase({double? top, double? bottom, double? left, double? right}) {
    return EdgeInsets.only(
      top: top != null ? ResponsiveSizes.customSpacing(top) : 0,
      bottom: bottom != null ? ResponsiveSizes.customSpacing(bottom) : 0,
      left: left != null ? ResponsiveSizes.customSpacing(left) : 0,
      right: right != null ? ResponsiveSizes.customSpacing(right) : 0,
    );
  }
}

/// Extension pour faciliter l'utilisation des paddings responsifs
extension ResponsivePaddingExtension on Widget {
  /// Ajoute un padding responsif autour du widget
  Widget paddingResponsive(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  /// Ajoute un padding petit
  Widget get paddingSmall => ResponsivePadding.small(child: this);

  /// Ajoute un padding moyen
  Widget get paddingMedium => ResponsivePadding.medium(child: this);

  /// Ajoute un padding grand
  Widget get paddingLarge => ResponsivePadding.large(child: this);

  /// Ajoute un padding d'écran
  Widget get paddingScreen => ResponsivePadding.screen(child: this);

  /// Ajoute un padding horizontal
  Widget paddingHorizontal(double? value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: value != null ? ResponsiveSizes.customSpacing(value) : ResponsiveSizes.spacingMedium,
      ),
      child: this,
    );
  }

  /// Ajoute un padding vertical
  Widget paddingVertical(double? value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: value != null ? ResponsiveSizes.customSpacing(value) : ResponsiveSizes.spacingMedium,
      ),
      child: this,
    );
  }
}

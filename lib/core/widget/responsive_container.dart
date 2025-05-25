// lib/core/widgets/responsive_container.dart

import 'package:flutter/material.dart';
import '../responsive/responsive_sizes.dart';

/// Container avec dimensions adaptatives et propriétés responsives
/// Remplace les Container avec des valeurs fixes
class ResponsiveContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final ResponsiveContainerType? _type;
  final double? _customWidth;
  final double? _customHeight;

  /// Container personnalisé avec dimensions adaptatives
  const ResponsiveContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : _type = null,
       _customWidth = null,
       _customHeight = null;

  /// Container avec hauteur de bouton adaptative
  const ResponsiveContainer.button({
    super.key,
    this.child,
    this.width,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : height = null,
       _type = ResponsiveContainerType.button,
       _customWidth = null,
       _customHeight = null;

  /// Container avec hauteur d'input adaptative
  const ResponsiveContainer.input({
    super.key,
    this.child,
    this.width,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : height = null,
       _type = ResponsiveContainerType.input,
       _customWidth = null,
       _customHeight = null;

  /// Container avec hauteur d'élément de liste
  const ResponsiveContainer.listItem({
    super.key,
    this.child,
    this.width,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : height = null,
       _type = ResponsiveContainerType.listItem,
       _customWidth = null,
       _customHeight = null;

  /// Container card avec padding et border radius adaptatifs
  const ResponsiveContainer.card({super.key, this.child, this.width, this.height, this.margin, this.color, this.alignment})
    : padding = null,
      decoration = null,
      _type = ResponsiveContainerType.card,
      _customWidth = null,
      _customHeight = null;

  /// Container avec largeur en pourcentage d'écran
  const ResponsiveContainer.widthPercent({
    super.key,
    this.child,
    required double percent,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : width = null,
       _type = ResponsiveContainerType.widthPercent,
       _customWidth = percent,
       _customHeight = null;

  /// Container avec hauteur en pourcentage d'écran
  const ResponsiveContainer.heightPercent({
    super.key,
    this.child,
    this.width,
    required double percent,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : height = null,
       _type = ResponsiveContainerType.heightPercent,
       _customWidth = null,
       _customHeight = percent;

  /// Container avec dimensions en pourcentages
  const ResponsiveContainer.sizePercent({
    super.key,
    this.child,
    required double widthPercent,
    required double heightPercent,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : width = null,
       height = null,
       _type = ResponsiveContainerType.sizePercent,
       _customWidth = widthPercent,
       _customHeight = heightPercent;

  /// Container adaptatif avec taille minimale et maximale
  const ResponsiveContainer.adaptive({
    super.key,
    this.child,
    required double baseWidth,
    required double baseHeight,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  }) : width = null,
       height = null,
       _type = ResponsiveContainerType.adaptive,
       _customWidth = baseWidth,
       _customHeight = baseHeight;

  @override
  Widget build(BuildContext context) {
    double? effectiveWidth = width;
    double? effectiveHeight = height;
    EdgeInsetsGeometry? effectivePadding = padding;
    Decoration? effectiveDecoration = decoration;

    // Calculer les dimensions selon le type
    switch (_type) {
      case ResponsiveContainerType.button:
        effectiveHeight = ResponsiveSizes.buttonHeight;
        effectivePadding ??= EdgeInsets.symmetric(
          horizontal: ResponsiveSizes.buttonPaddingHorizontal,
          vertical: ResponsiveSizes.buttonPaddingVertical,
        );
        break;

      case ResponsiveContainerType.input:
        effectiveHeight = ResponsiveSizes.inputHeight;
        break;

      case ResponsiveContainerType.listItem:
        effectiveHeight = ResponsiveSizes.listItemHeight;
        break;

      case ResponsiveContainerType.card:
        effectivePadding = EdgeInsets.all(ResponsiveSizes.cardPadding);
        effectiveDecoration = BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveSizes.radiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: ResponsiveSizes.elevationSmall,
              offset: Offset(0, ResponsiveSizes.elevationSmall / 2),
            ),
          ],
        );
        break;

      case ResponsiveContainerType.widthPercent:
        effectiveWidth = ResponsiveSizes.widthPercent(_customWidth!);
        break;

      case ResponsiveContainerType.heightPercent:
        effectiveHeight = ResponsiveSizes.heightPercent(_customHeight!);
        break;

      case ResponsiveContainerType.sizePercent:
        effectiveWidth = ResponsiveSizes.widthPercent(_customWidth!);
        effectiveHeight = ResponsiveSizes.heightPercent(_customHeight!);
        break;

      case ResponsiveContainerType.adaptive:
        effectiveWidth = ResponsiveSizes.customSpacing(_customWidth!);
        effectiveHeight = ResponsiveSizes.customSpacing(_customHeight!);
        break;

      default:
        // Utiliser les valeurs fournies ou nulles
        break;
    }

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: effectivePadding,
      margin: margin,
      decoration: effectiveDecoration ?? (color != null ? BoxDecoration(color: color) : null),
      alignment: alignment,
      child: child,
    );
  }
}

/// Énumération pour les types de container responsif
enum ResponsiveContainerType { button, input, listItem, card, widthPercent, heightPercent, sizePercent, adaptive }

/// Container responsif spécialisé pour les boutons
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final bool isLoading;
  final bool isEnabled;

  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer.button(
      width: width,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          minimumSize: Size.zero,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSizes.buttonPaddingHorizontal,
            vertical: ResponsiveSizes.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveSizes.radiusButton)),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: ResponsiveSizes.iconSmall,
                  height: ResponsiveSizes.iconSmall,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                : child,
      ),
    );
  }
}

/// Card responsif avec style prédéfini
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.color,
    this.width,
    this.height,
    this.margin,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = ResponsiveContainer.card(width: width, height: height, margin: margin, child: child);

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(ResponsiveSizes.radiusCard), child: cardContent),
      );
    }

    return cardContent;
  }
}

/// Extension pour ajouter des méthodes de container responsif aux widgets
extension ResponsiveContainerExtension on Widget {
  /// Entoure le widget dans un ResponsiveContainer
  Widget responsiveContainer({
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Decoration? decoration,
    AlignmentGeometry? alignment,
  }) {
    return ResponsiveContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      alignment: alignment,
      child: this,
    );
  }

  /// Entoure le widget dans un container card responsif
  Widget get responsiveCard => ResponsiveCard(child: this);

  /// Entoure le widget dans un container avec largeur en pourcentage
  Widget responsiveWidthPercent(double percent) {
    return ResponsiveContainer.widthPercent(percent: percent, child: this);
  }

  /// Entoure le widget dans un container avec hauteur en pourcentage
  Widget responsiveHeightPercent(double percent) {
    return ResponsiveContainer.heightPercent(percent: percent, child: this);
  }

  /// Entoure le widget dans un container avec dimensions adaptatives
  Widget responsiveAdaptive({
    required double baseWidth,
    required double baseHeight,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return ResponsiveContainer.adaptive(
      baseWidth: baseWidth,
      baseHeight: baseHeight,
      padding: padding,
      margin: margin,
      child: this,
    );
  }
}

/// Utilitaires pour créer des SizedBox responsifs
abstract class ResponsiveSizedBox {
  /// SizedBox avec largeur responsive
  static Widget width(double baseWidth) {
    return SizedBox(width: ResponsiveSizes.customSpacing(baseWidth));
  }

  /// SizedBox avec hauteur responsive
  static Widget height(double baseHeight) {
    return SizedBox(height: ResponsiveSizes.customSpacing(baseHeight));
  }

  /// SizedBox carré responsive
  static Widget square(double baseSize) {
    final size = ResponsiveSizes.customSpacing(baseSize);
    return SizedBox(width: size, height: size);
  }

  /// Espacements prédéfinis
  static Widget get spacingXSmall => SizedBox(height: ResponsiveSizes.spacingXSmall);
  static Widget get spacingSmall => SizedBox(height: ResponsiveSizes.spacingSmall);
  static Widget get spacingMedium => SizedBox(height: ResponsiveSizes.spacingMedium);
  static Widget get spacingLarge => SizedBox(height: ResponsiveSizes.spacingLarge);
  static Widget get spacingXLarge => SizedBox(height: ResponsiveSizes.spacingXLarge);

  /// Espacements horizontaux prédéfinis
  static Widget get horizontalXSmall => SizedBox(width: ResponsiveSizes.spacingXSmall);
  static Widget get horizontalSmall => SizedBox(width: ResponsiveSizes.spacingSmall);
  static Widget get horizontalMedium => SizedBox(width: ResponsiveSizes.spacingMedium);
  static Widget get horizontalLarge => SizedBox(width: ResponsiveSizes.spacingLarge);
  static Widget get horizontalXLarge => SizedBox(width: ResponsiveSizes.spacingXLarge);
}

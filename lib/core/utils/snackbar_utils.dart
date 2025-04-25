// lib/utils/snackbar_utils.dart
import 'package:flutter/material.dart';

class SnackBarUtils {
  /// Affiche un SnackBar d'erreur avec fond rouge
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    double bottomMargin = 20.0,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: bottomMargin, left: 20.0, right: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  /// Affiche un SnackBar d'information avec le fond de la couleur primaire
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    double bottomMargin = 20.0,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: bottomMargin, left: 20.0, right: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  /// Affiche un SnackBar de succès avec fond vert
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    double bottomMargin = 20.0,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: bottomMargin, left: 20.0, right: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }
}

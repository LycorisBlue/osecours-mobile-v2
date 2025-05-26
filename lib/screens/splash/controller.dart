// lib/screens/splash/controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/navigation_service.dart';

/// Controller pour gérer la logique du splash screen
class SplashController {
  Timer? _timer;

  // Controllers d'animation
  late AnimationController fadeController;
  late AnimationController scaleController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  /// Initialise les animations
  void initializeAnimations(TickerProvider vsync) {
    // Animation de fade-in
    fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: vsync);

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeInOut));

    // Animation de scaling (respiration)
    scaleController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: vsync);

    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: scaleController, curve: Curves.easeInOut));
  }

  /// Démarre les animations et le timer
  void startSplash() {
    // Démarrer le fade-in
    fadeController.forward();

    // Démarrer l'animation de respiration après le fade-in
    fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        scaleController.repeat(reverse: true);
      }
    });

    // Timer de 3 secondes pour la navigation
    _timer = Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  /// Détermine et navigue vers l'écran suivant
  Future<void> _navigateToNextScreen() async {
    try {
      final authBox = Hive.box('auth');
      final bool isLoggedIn = authBox.get('isLoggedIn', defaultValue: false);

      if (isLoggedIn) {
        Routes.navigateAndRemoveAll(Routes.home);
      } else {
        Routes.navigateAndRemoveAll(Routes.login);
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers l'inscription
      Routes.navigateAndRemoveAll(Routes.registration);
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _timer?.cancel();
    fadeController.dispose();
    scaleController.dispose();
  }
}

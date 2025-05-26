// lib/screens/splash/index.dart
import 'package:flutter/material.dart';
import 'package:osecours/core/constants/colors.dart';
import 'controller.dart';

/// Écran de splash avec logo blanc O'secours et animations élégantes
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController();
    _controller.initializeAnimations(this);

    // Démarrer le splash après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.startSplash();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller.fadeAnimation, _controller.scaleAnimation]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _controller.fadeAnimation,
              child: ScaleTransition(
                scale: _controller.scaleAnimation,
                child: Image.asset(
                  'assets/pictures/white-logo.png',
                  height: 80,
                  width: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback si l'image n'existe pas
                    return Container(
                      width: 200,
                      height: 80,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text(
                          "O'secours",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

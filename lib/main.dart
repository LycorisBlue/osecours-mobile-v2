import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:osecours/core/constants/themes.dart';
import 'package:osecours/services/navigation_service.dart';
import 'package:osecours/core/responsive/responsive_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('user');
  await Hive.openBox('temp');

  // Détermine la route initiale en fonction de l'état d'authentification
  final String initialRoute = await _determineInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
  final authBox = Hive.box('auth');
  final bool isLoggedIn = authBox.get('isLoggedIn', defaultValue: false);

  if (isLoggedIn) {
    return Routes.home;
  } else {
    return Routes.login;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Routes.navigatorKey,
      title: 'Mobile ARTCI',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      onGenerateRoute: Routes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
      // Wrapper pour initialiser le système responsive
      builder: (context, child) {
        return ResponsiveAppWrapper(child: child ?? const SizedBox());
      },
    );
  }
}

/// Widget wrapper qui initialise le système responsive
/// et s'assure que tous les écrans ont accès aux dimensions adaptatives
class ResponsiveAppWrapper extends StatefulWidget {
  final Widget child;

  const ResponsiveAppWrapper({super.key, required this.child});

  @override
  State<ResponsiveAppWrapper> createState() => _ResponsiveAppWrapperState();
}

class _ResponsiveAppWrapperState extends State<ResponsiveAppWrapper> with WidgetsBindingObserver {
  final ResponsiveManager _responsiveManager = ResponsiveManager();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Écouter les changements d'orientation/taille d'écran
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialiser le système responsive après que le contexte soit disponible
    if (!_isInitialized) {
      _initializeResponsiveSystem();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Réinitialiser lors des changements d'orientation ou de taille
    if (_isInitialized) {
      _reinitializeResponsiveSystem();
    }
  }

  /// Initialise le système responsive avec le contexte courant
  void _initializeResponsiveSystem() {
    try {
      _responsiveManager.initialize(context);
      _isInitialized = true;

      if (mounted) {
        debugPrint('ResponsiveManager initialisé avec succès');

        // Afficher les infos de debug en mode développement
        final debugInfo = _responsiveManager.getDebugInfo();
        debugPrint('=== RESPONSIVE DEBUG INFO ===');
        debugInfo.forEach((key, value) {
          debugPrint('$key: $value');
        });
        debugPrint('==============================');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de ResponsiveManager: $e');
    }
  }

  /// Réinitialise le système lors des changements d'orientation
  void _reinitializeResponsiveSystem() {
    try {
      // Nettoyer le cache avant réinitialisation
      _responsiveManager.clearCache();
      _responsiveManager.initialize(context);

      if (mounted) {
        debugPrint('ResponsiveManager réinitialisé après changement d\'orientation');
      }
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation de ResponsiveManager: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // S'assurer que le système est initialisé avant d'afficher l'interface
    if (!_isInitialized) {
      // Afficher un indicateur de chargement minimal pendant l'initialisation
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }

    return widget.child;
  }
}

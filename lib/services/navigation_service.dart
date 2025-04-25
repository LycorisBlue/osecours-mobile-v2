import 'package:flutter/material.dart';


class Routes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const String home = '/';


  static Map<String, Widget Function(BuildContext)> get routes => {
    home: (context) => const Text('Hello World!'),

  };

  // Navigation standard avec animation personnalisée
  static void navigateTo(String routeName) {
    final page = routes[routeName]!(navigatorKey.currentContext!);
    navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // Navigation avec paramètres et animation personnalisée
  static Future<T?> push<T>(Widget page) {
    return navigatorKey.currentState!.push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // Remplacement avec animation
  static void navigateAndReplace(String routeName) {
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: {'animate': true});
  }

  // Remplacement avec paramètres et animation
  static Future<T?> pushReplacement<T>(Widget page) {
    return navigatorKey.currentState!.pushReplacement<T, T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // Navigation avec effacement de l'historique et animation
  static void navigateAndRemoveAll(String routeName) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false, arguments: {'animate': true});
  }

  // Effacer tout avec paramètres et animation
  static Future<T?> pushAndRemoveAll<T>(Widget page) {
    return navigatorKey.currentState!.pushAndRemoveUntil<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // Retour avec animation
  static void goBack<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop<T>(result);
    }
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Vérification de sécurité pour la route
    final routeBuilder = routes[settings.name];
    if (routeBuilder == null) {
      // Si la route n'existe pas, retourner à l'écran splash
      return MaterialPageRoute(builder: routes[home]!, settings: const RouteSettings(name: home));
    }

    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final shouldAnimate = args['animate'] ?? false;

    if (!shouldAnimate) {
      return MaterialPageRoute(builder: routeBuilder, settings: settings);
    }

    // Animation par défaut
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => routeBuilder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      settings: settings,
    );
  }
}

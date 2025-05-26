import 'package:flutter/material.dart';
import 'package:osecours/screens/alerts/index.dart';
import 'package:osecours/screens/emergency/index.dart';
import 'package:osecours/screens/login/index.dart';
import 'package:osecours/screens/notifications/index.dart';
import 'package:osecours/screens/otp/index.dart';
import 'package:osecours/screens/profile/index.dart';
import 'package:osecours/screens/registration/index.dart';
import 'package:osecours/screens/home/index.dart';
import 'package:osecours/screens/settings/index.dart';
import 'package:osecours/screens/splash/index.dart';
import 'package:osecours/screens/safe_contacts/index.dart';

class Routes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const String splash = '/splash';
  static const String home = '/';
  static const String registration = '/registration';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String emergency = '/emergency';
  static const String alerts = '/alerts';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String safeContacts = '/safe-contacts';
  static const String notifications = '/notifications';


  static Map<String, Widget Function(BuildContext)> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => HomeScreen(),
    registration: (context) => const SignUpScreen(),
    login: (context) => const LoginScreen(),
    otp: (context) => OtpScreen(phoneNumber: "0759670150"),
    emergency: (context) => const EmergencyScreen(),
    alerts: (context) => const AlertsScreen(),
    settings: (context) => const SettingsScreen(),
    profile: (context) => const ProfileScreen(),
    safeContacts: (context) => const SafeContactsScreen(),
    notifications: (context) => const NotificationsScreen(),
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
      // Si la route n'existe pas, retourner au splash
      return MaterialPageRoute(builder: routes[splash]!, settings: RouteSettings(name: splash));
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:osecours/core/constants/themes.dart';
import 'package:osecours/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('user');
  await Hive.openBox('temp');
  await Hive.openBox('notifications');
  await Hive.openBox('showcase'); // Ajout du box pour les showcases

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
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Taille de design de référence (iPhone X)
      minTextAdapt: true, // Adaptation automatique du texte
      splitScreenMode: true, // Support pour écrans divisés
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: Routes.navigatorKey,
          title: 'Mobile ARTCI',
          theme: AppTheme.lightTheme,
          // darkTheme: AppTheme.darkTheme,
          // themeMode: ThemeMode.system,
          initialRoute: initialRoute,
          onGenerateRoute: Routes.onGenerateRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

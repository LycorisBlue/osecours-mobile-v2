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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          initialRoute: Routes.splash,
          onGenerateRoute: Routes.onGenerateRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();
  runApp(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: const GarzonFacebook(),
    ),
  );
}
 
class GarzonFacebook extends StatelessWidget {
  const GarzonFacebook({super.key});
 
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pongkan Social',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: FB_PRIMARY),
              scaffoldBackgroundColor: const Color(0xFFF4F5F7),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: FB_PRIMARY,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            initialRoute: '/splash',
            routes: <String, WidgetBuilder>{
              '/splash': (_) => const SplashScreen(),
              '/signin': (_) => const SignInScreen(),
              '/login': (_) => const SignInScreen(),
              '/home': (_) => const HomeScreen(),
            },
          ),
        );
      },
    );
  }
}
 

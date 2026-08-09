import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/onboarding_screen.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'screens/role_selector_screen.dart';
import 'services/favorites_service.dart';
import 'services/admin_price_service.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ypxojolsuajqiimcjacd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlweG9qb2xzdWFqcWlpbWNqYWNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMjk5MzAsImV4cCI6MjA5MjgwNTkzMH0.Zzp0W1M3POAmdWjTrfdWgYKCLG0KhEhMOyAgypqyH_w',
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();
  final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

  final user = Supabase.instance.client.auth.currentUser;
  final isLoggedIn = user != null;

  // Determine role from Supabase profiles table
  bool isAdmin = false;
  if (isLoggedIn) {
    final authService = AuthService();
    final role = await authService.getCurrentRole();
    isAdmin = role == AppRole.admin;
  }

  await AdminPriceService.instance.load();

  final favoritesService = FavoritesService();
  if (isLoggedIn) {
    await favoritesService.loadFromSupabase();
  }

  runApp(FurnitureARApp(
    onboardingSeen: onboardingSeen,
    isLoggedIn: isLoggedIn,
    isAdmin: isAdmin,
    favoritesService: favoritesService,
  ));
}

class FurnitureARApp extends StatelessWidget {
  final bool onboardingSeen;
  final bool isLoggedIn;
  final bool isAdmin;
  final FavoritesService favoritesService;

  const FurnitureARApp({
    super.key,
    required this.onboardingSeen,
    required this.isLoggedIn,
    required this.isAdmin,
    required this.favoritesService,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC97B4B);

    Widget home;
    if (!onboardingSeen) {
      home = const OnboardingScreen();
    } else if (!isLoggedIn) {
      home = RoleSelectorScreen(favoritesService: favoritesService);
    } else {
      home = AppShell(favoritesService: favoritesService, isAdmin: isAdmin);
    }

    return MaterialApp(
      title: 'FrameKart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Color(0xFF3D2B1F), fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Color(0xFF3D2B1F)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
      ),
      routes: {
        '/home': (_) => AppShell(favoritesService: favoritesService, isAdmin: isAdmin),
        '/login': (_) => LoginScreen(favoritesService: favoritesService),
        '/role':  (_) => RoleSelectorScreen(favoritesService: favoritesService),
      },
      home: home,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/app_state.dart';
import 'services/stripe_service.dart';
import 'services/stripe_debug.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/auth/auth_screen.dart';
import 'ui/main/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Debug Stripe configuration
  StripeDebug.validateConfiguration();
  
  // Initialize Stripe
  StripeService.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FoodgoSplashScreen(
        onFinished: (ctx) {
          // Check if user is already authenticated
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // User is logged in, go to main screen
            Navigator.of(ctx).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (_, __, ___) => const MainScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          } else {
            // User is not logged in, go to auth screen
            Navigator.of(ctx).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (_, __, ___) => const AuthScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          }
        },
      ),
    );
  }
}

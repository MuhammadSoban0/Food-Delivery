import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../auth/auth_screen.dart';
import '../main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _bgController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _bgRadialReveal;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _glowOpacity = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _bgRadialReveal = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('firstLaunch') ?? true;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Widget nextScreen;
    if (currentUser != null) {
      nextScreen = const MainScreen();
    } else {
      nextScreen = const AuthScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return nextScreen;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _bgController]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.splashGradientStart,
                  AppTheme.splashGradientEnd,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Main content with title and centered image
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Foodgo title with Hero animation
                      Hero(
                        tag: 'foodgo_logo',
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Text(
                              'Foodgo',
                              style: AppTheme.lobsterStyle.copyWith(
                                fontSize: 64,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 800.ms,
                                  curve: Curves.elasticOut,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Centered splash2.png image
                      Opacity(
                        opacity: _bgRadialReveal.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Image.asset(
                            'assets/images/splash2.png',
                            height: 200,
                            fit: BoxFit.fitHeight,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Icon(
                                  Icons.lunch_dining,
                                  size: 80,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              );
                            },
                          )
                              .animate()
                              .fadeIn(delay: 1000.ms, duration: 800.ms)
                              .scale(
                                begin: const Offset(0.5, 0.5),
                                end: const Offset(1.0, 1.0),
                                duration: 1000.ms,
                                curve: Curves.elasticOut,
                              )
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 800.ms,
                                curve: Curves.easeOutBack,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

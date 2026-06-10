import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/app_theme.dart';
import '../main/main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _submitGoogle() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('--- Google Sign In Started ---');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign In: User canceled the flow.');
        setState(() => _isLoading = false);
        return;
      }
      debugPrint('Google Sign In: Selected account -> ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('Google Sign In: Authentication obtained.');

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Google Sign In: Signing into Firebase.');
      await _auth.signInWithCredential(credential);
      debugPrint('Google Sign In: Firebase sign in successful.');
      if (mounted) _navigateToMain();
    } catch (e, stackTrace) {
      debugPrint('Google Sign In: Error occurred -> $e');
      debugPrint('Google Sign In: Stack trace -> $stackTrace');
      _showError('Google Sign-In failed: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Foodgo title with Hero animation
                     Hero(
                        tag: 'foodgo_logo',
                        child: Text(
                          'Foodgo',
                          style: AppTheme.lobsterStyle.copyWith(
                            fontSize: 48,
                            color: AppTheme.primaryColor, // Use red color for auth screen
                          ),
                        ),
                      ),
                    const SizedBox(height: 60),
                    Text(
                          'Welcome! 👋',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(fontSize: 32),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 4),
                    Text(
                          'Sign in with Google to continue your grocery shopping.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                    const Spacer(),
                    Container(
                      width: double.infinity,
                      height: 325,
                      decoration: ShapeDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/auth.png"),fit: BoxFit.cover),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x21000000),
                            blurRadius: 17,
                            offset: Offset(0, 6),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                    ),

                    const Spacer(),
                    // Google Button
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submitGoogle,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    LucideIcons.chrome,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isLoading ? 'Signing in...' : 'Continue with Google',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

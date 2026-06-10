import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_state.dart';
import '../splash/splash_screen.dart';
import '../notifications/in_app_notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedAvatar = '👤';
  final List<String> _avatars = [
    '👤',
    '👨‍🦱',
    '👩‍🦰',
    '🧔',
    '👱‍♀️',
    '😎',
    '🤖',
    '👻',
  ];

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Avatar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _avatars.map((avatar) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = avatar);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _selectedAvatar == avatar
                            ? AppTheme.primaryColor.withValues(alpha: 0.2)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: _selectedAvatar == avatar
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.logOut,
                  color: Colors.red,
                  size: 24,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              const Text(
                'Log Out',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to log out from your FreshCart account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.4,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(
                            bottomSheetContext,
                          ); // Close sheet first
                          await context.read<AppState>().signOut();

                          // After signing out, we must route back to SplashScreen
                          // so it evaluates the fresh empty auth state and pushes us to AuthScreen properly.
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const SplashScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Yes, Log Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          children: [
            // User Header
            Consumer<AppState>(
              builder: (context, state, child) {
                final user = state.user;
                final name = user?.displayName ?? 'Grocery Lover';
                final email = user?.email ?? 'Not logged in';

                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
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
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _selectedAvatar,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(
                          LucideIcons.edit2,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: _showAvatarPicker,
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.backgroundColor,
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Settings List
            _buildSectionHeader(
              context,
              'General Settings',
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
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
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildListTile(
                      icon: LucideIcons.mapPin,
                      title: 'Delivery Addresses',
                      delay: 150,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: LucideIcons.creditCard,
                      title: 'Payment Methods',
                      delay: 200,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: LucideIcons.bellRing,
                      title: 'Notifications',
                      delay: 250,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InAppNotificationsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            _buildSectionHeader(
              context,
              'About App',
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
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
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildListTile(
                      icon: LucideIcons.info,
                      title: 'About FreshCart',
                      delay: 350,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: LucideIcons.shieldCheck,
                      title: 'Privacy Policy',
                      delay: 400,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: LucideIcons.fileText,
                      title: 'Terms & Conditions',
                      delay: 450,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: LucideIcons.smartphone,
                      title: 'App Version',
                      trailing: 'v1.0.0',
                      delay: 500,
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: LucideIcons.logOut,
                      title: 'Log Out',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
                      hideTrailing: true,
                      delay: 550,
                      onTap: () {
                        _showLogoutConfirmation(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailing,
    required int delay,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
    Color? iconBackgroundColor,
    bool hideTrailing = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.textPrimaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (!hideTrailing)
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 64, color: Colors.grey.shade100);
  }
}

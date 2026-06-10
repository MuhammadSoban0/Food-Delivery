import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_theme.dart';
import '../../core/app_state.dart';
import '../home/home_screen.dart';
import '../cart/cart_screen.dart';
import '../delivery/delivery_tracking_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/in_app_notifications_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});
  
  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    InAppNotificationsScreen(),
    CartScreen(),
    DeliveryTrackingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Consumer<AppState>(
        builder: (context, appState, child) {
          // Force rebuild when unread count changes
          final unreadCount = appState.unreadNotificationsCount;
          
          return CrystalNavigationBar(
            borderWidth: 1,
            outlineBorderColor: AppTheme.primaryColor.withValues(alpha: 0.4),
            borderRadius: 24,
            curve: Curves.easeOutCubic,
            duration: const Duration(milliseconds: 300),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              
              // If notification tab is tapped, mark notifications as read
              if (index == 1) {
                appState.markAllNotificationsAsRead();
              }
            },
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            paddingR: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            marginR: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            items: [
              CrystalNavigationBarItem(
                icon: IconlyBold.home,
                unselectedIcon: IconlyLight.home,
                selectedColor: Colors.white,
                unselectedColor: Colors.white54,
              ),
              CrystalNavigationBarItem(
                icon: IconlyBold.notification,
                unselectedIcon: IconlyLight.notification,
                selectedColor: Colors.white,
                unselectedColor: Colors.white54,
                badge: unreadCount > 0
                    ? Badge(
                        label: Text(
                          unreadCount > 99
                              ? "99+"
                              : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.white54,
                      )
                    : null,
              ),
              CrystalNavigationBarItem(
                icon: IconlyBold.bag,
                unselectedIcon: IconlyLight.bag,
                selectedColor: Colors.white,
                unselectedColor: Colors.white54,
              ),
              CrystalNavigationBarItem(
                icon: LucideIcons.truck,
                unselectedIcon: LucideIcons.truck,
                selectedColor: Colors.white,
                unselectedColor: Colors.white54,
              ),
              CrystalNavigationBarItem(
                icon: IconlyBold.profile,
                unselectedIcon: IconlyLight.profile,
                selectedColor: Colors.white,
                unselectedColor: Colors.white54,
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../home/home_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CrystalNavigationBar(
        borderWidth: 2,
        outlineBorderColor: AppTheme.primaryColor.withValues(alpha: 0.25),
        borderRadius: 100,
        curve: Curves.easeOutQuint,
        duration: const Duration(milliseconds: 500),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white.withValues(
          alpha: 0.9,
        ), // Soft frosted glass appearance
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.primaryColor.withValues(alpha: 0.7),
        paddingR: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        marginR: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
        items: [
          CrystalNavigationBarItem(
            icon: CupertinoIcons.house_fill,
            unselectedIcon: CupertinoIcons.home,
            selectedColor: AppTheme.primaryColor,
            unselectedColor: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
          ),
          CrystalNavigationBarItem(
            icon: CupertinoIcons.bag_fill,
            unselectedIcon: CupertinoIcons.bag,
            selectedColor: AppTheme.primaryColor,
            unselectedColor: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
          ),
          CrystalNavigationBarItem(
            icon: CupertinoIcons.person_solid,
            unselectedIcon: CupertinoIcons.person,
            selectedColor: AppTheme.primaryColor,
            unselectedColor: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

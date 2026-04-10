import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'dashboard.dart';
import 'history.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  late final List<Widget> _screens = [
    DashboardScreen(onNavigate: changeTab),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,

      body: SafeArea(
        child: _screens[_currentIndex],
      ),

      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        elevation: 3,

        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
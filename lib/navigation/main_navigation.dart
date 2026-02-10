import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/soil_management_screen.dart';
import '../screens/plant_management_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const SoilManagementScreen(),
    const PlantManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Soil'),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Plants'),
        ],
      ),
    );
  }
}
import 'package:event_rfid_app/screens/reports/reports_home_view.dart';
import 'package:event_rfid_app/screens/settings/settings_home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home/home_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final NavigationController navController = Get.put(NavigationController());

  MainNavigationScreen({super.key});

  final List<Widget> _screens = [
    const HomeScreen(),

    const ReportsPlaceholderScreen(),
    const SettingsPlaceholderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.currentIndex.value,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF0043A4),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    navController.currentIndex.value == 0
                        ? Icons.home
                        : Icons.home_outlined,
                    size: 24,
                  ),
                ),
                label: 'Home',
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    navController.currentIndex.value == 1
                        ? Icons.bar_chart
                        : Icons.bar_chart_outlined,
                    size: 24,
                  ),
                ),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    navController.currentIndex.value == 2
                        ? Icons.settings
                        : Icons.settings_outlined,
                    size: 24,
                  ),
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:jeevan_vigyan/screens/home_page.dart';
import 'package:jeevan_vigyan/screens/members_page.dart';
import 'package:jeevan_vigyan/screens/reports_page.dart';
import 'package:jeevan_vigyan/screens/calculator_page.dart';

// Placeholder pages for other navigation items
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('सेटिङ्स Page'));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _pages(void Function(int) onItemTapped) {
    return [
      const HomePage(),
      const MembersPage(),
      const ReportsPage(),
      const SettingsPage(),
      CalculatorPage(onBackToHome: () => onItemTapped(0)),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages(_onItemTapped).elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 110,
          child: Column(
            // Use a Column to control vertical alignment of the Row
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 15), // Add a little space from the top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, 'गृह'),
                  _buildNavItem(1, Icons.people_outlined, 'सदस्य'),
                  _buildCalculatorButton(),
                  _buildNavItem(2, Icons.description_outlined, 'विवरण'),
                  _buildNavItem(3, Icons.settings_outlined, 'सेटिङ्स'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a standard navigation item
  Widget _buildNavItem(int index, IconData icon, String label) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start, // Align to top
          children: [
            Icon(
              icon,
              color: _selectedIndex == index
                  ? AppColors.maroonishRed
                  : AppColors.charcoalBlack,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Yantramanav',
                fontSize: 12,
                color: _selectedIndex == index
                    ? AppColors.maroonishRed
                    : AppColors.charcoalBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the central calculator button
  Widget _buildCalculatorButton() {
    return InkWell(
      onTap: () => _onItemTapped(4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppColors.maroonishRed,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.calculate_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

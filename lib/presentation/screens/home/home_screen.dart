// Home Screen with Premium Floating Bottom Navigation
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0), // Deep blue
            const Color(0xFF0D47A1).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.history_rounded,
                label: 'History',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.premiumGold.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(
                    color: AppTheme.premiumGold.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.premiumGold : Colors.white,
                size: isSelected ? 24 : 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.premiumGold : Colors.white.withValues(alpha: 0.8),
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

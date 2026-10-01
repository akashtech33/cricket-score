import 'package:flutter/material.dart';
import '../services/cricket_data_service.dart';
import '../theme/app_colors.dart';
import 'home_matches_screen.dart';
import 'standings_screen.dart';
import 'rankings_screen.dart';
import 'news_screen.dart';
import 'fan_zone_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final CricketDataService dataService;

  const MainNavigationScreen({
    super.key,
    required this.dataService,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeMatchesScreen(dataService: widget.dataService),
      StandingsScreen(dataService: widget.dataService),
      RankingsScreen(dataService: widget.dataService),
      NewsScreen(dataService: widget.dataService),
      FanZoneScreen(dataService: widget.dataService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.sports_cricket_outlined),
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.liveRed,
                      ),
                    ),
                  ),
                ],
              ),
              activeIcon: const Icon(Icons.sports_cricket, color: AppColors.primary),
              label: 'Matches',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined),
              activeIcon: Icon(Icons.table_chart, color: AppColors.primary),
              label: 'Table',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard, color: AppColors.primary),
              label: 'Rankings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper, color: AppColors.primary),
              label: 'News',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.celebration_outlined),
              activeIcon: Icon(Icons.celebration, color: AppColors.primary),
              label: 'Fan Zone',
            ),
          ],
        ),
      ),
    );
  }
}

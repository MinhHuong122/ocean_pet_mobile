// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import './home_screen.dart';
import 'diary_screen.dart';
import './care_screen.dart';
import './profile_screen.dart' as profile_screen;

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, this.currentIndex = 0});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  late int _selectedIndex;

  final List<_NavItemData> _items = [
    _NavItemData('Trang chủ', 'lib/res/drawables/setting/home.png'),
    _NavItemData('Nhật ký', 'lib/res/drawables/setting/diary.png'),
    _NavItemData('Chăm sóc', 'lib/res/drawables/setting/take_care.png'),
    _NavItemData('Cá nhân', 'lib/res/drawables/setting/user.png'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () {
              if (i != _selectedIndex) {
                _navigateToScreen(context, i);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF8E97FD).withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      _items[i].iconPath,
                      width: 24,
                      height: 24,
                      color: selected
                          ? const Color(0xFF8E97FD)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _items[i].label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? const Color(0xFF8E97FD)
                        : const Color(0xFFBDBDBD),
                  ),
                ),
                if (selected)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E97FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    // Navigate to the corresponding screen
    Widget screen;
    switch (index) {
      case 0:
        screen = HomeScreen();
        break;
      case 1:
        screen = const DiaryScreen();
        break;
      case 2:
        screen = const CareScreen();
        break;
      case 3:
        screen = const profile_screen.ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final String iconPath;
  _NavItemData(this.label, this.iconPath);
}

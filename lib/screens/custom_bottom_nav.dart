// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 0;

  final List<_NavItemData> _items = [
    _NavItemData('Trang chủ', 'lib/res/drawables/setting/home.png'),
    _NavItemData('Nhật ký', 'lib/res/drawables/setting/diary.png'),
    _NavItemData('Chăm sóc', 'lib/res/drawables/setting/take_care.png'),
    _NavItemData('Cá nhân', 'lib/res/drawables/setting/user.png'),
  ];

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
              setState(() {
                _selectedIndex = i;
              });
              // TODO: navigate if needed
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
}

class _NavItemData {
  final String label;
  final String iconPath;
  _NavItemData(this.label, this.iconPath);
}

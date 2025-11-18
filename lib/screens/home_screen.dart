// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart'; // Correct import for widgets directory
import './ai_chat_screen.dart';
import './contact_screen.dart';
import './community_screen.dart';
import './news_screen.dart';
import './training_screen.dart';
import './training_video_screen.dart';
import './events_screen.dart';
import './dating_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Ocean Pet',
                        style: GoogleFonts.aclonica(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Image.asset(
                        'lib/res/drawables/setting/LOGO.png',
                        width: 48,
                        height: 48,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Xin chào,',
                  style: GoogleFonts.afacad(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'chúc bạn và pet yêu một ngày hạnh phúc.',
                  style: GoogleFonts.afacad(
                    fontSize: 18,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),

                // Top cards (notes + calendar)
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ...existing code for left card...
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // ...existing code for right card...
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Menu icons row (collapsible)
                const MenuIconRow(),

                const SizedBox(height: 18),

                // News header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bảng tin',
                      style: GoogleFonts.afacad(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewsScreen(),
                          ),
                        );
                      },
                      child: Text('Xem tất cả ...',
                          style: GoogleFonts.afacad(
                              color: const Color(0xFF8E97FD))),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 240, // Further increased height to prevent overflow
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _bigNewsCard(
                        title: 'Sức khỏe',
                        imagePath: 'lib/res/drawables/setting/tag-SK.png',
                        subtitle: '5 BÀI VIẾT · 3-10 PHÚT',
                        color: const Color(0xFFEDE9FE),
                      ),
                      _bigNewsCard(
                        title: 'Giải trí',
                        imagePath: 'lib/res/drawables/setting/tag-VN.png',
                        subtitle: '3 BÀI VIẾT · 3-10 PHÚT',
                        color: const Color(0xFFFFF7ED),
                      ),
                      _bigNewsCard(
                        title: 'Huấn luyện',
                        imagePath: 'lib/res/drawables/setting/tag-HL.jpg',
                        subtitle: '3 BÀI',
                        color: const Color(0xFFE0F2FE),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 120), // space above bottom nav and fixed button
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',
        backgroundColor: const Color(0xFF8E97FD),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.smart_toy, color: Color(0xFF8E97FD)),
                    title: const Text('Hỗ trợ nhanh với AI'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIChatScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Color(0xFF8E97FD)),
                    title: const Text('Liên lạc'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.phone, color: Colors.white),
        // Không set shape hoặc decoration để giữ hình tròn mặc định
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _bigNewsCard({
    required String title,
    required String imagePath,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        // Removed boxShadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 220,
            height: 150,
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.afacad(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Changed to black
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.afacad(
                    color: Colors.black,
                    fontSize: 16, // Increased font size
                    fontWeight: FontWeight.normal, // Not bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuIconRow extends StatefulWidget {
  const MenuIconRow({super.key});

  @override
  State<MenuIconRow> createState() => _MenuIconRowState();
}

class _MenuIconRowState extends State<MenuIconRow> {
  bool collapsed = false;
  int selectedIndex = 0;

  final List<Map<String, dynamic>> menuItems = [
    {
      'label': 'Tất cả',
      'icon': 'lib/res/drawables/setting/all.png',
    },
    {
      'label': 'Cộng đồng',
      'icon': 'lib/res/drawables/setting/social.png',
    },
    {
      'label': 'Hẹn hò',
      'icon': 'lib/res/drawables/setting/dating.png',
    },
    {
      'label': 'Huấn luyện',
      'icon': 'lib/res/drawables/setting/train.png',
    },
    {
      'label': 'Sự kiện',
      'icon': 'lib/res/drawables/setting/event.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    if (collapsed) {
      icons.add(_menuIcon(0));
    } else {
      for (int i = 0; i < menuItems.length; i++) {
        icons.add(_menuIcon(i));
      }
    }
    return SizedBox(
      height: 90,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: icons,
        ),
      ),
    );
  }

  Widget _menuIcon(int index) {
    final item = menuItems[index];
    final bool selected = selectedIndex == index;
    final bool isAll = index == 0;
    final Color selectedColor = const Color(0xFF8E97FD);
    final Color unselectedColor = Color.fromARGB(255, 177, 181, 201);
    
    return GestureDetector(
      onTap: () {
        if (isAll) {
          setState(() {
            if (collapsed) {
              collapsed = false;
            } else {
              collapsed = true;
              selectedIndex = 0;
            }
          });
        } else {
          setState(() {
            selectedIndex = index;
          });
          
          // Navigate to corresponding screen
          _navigateToScreen(index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
            right: 16.0, left: 8.0), // Added left padding for balance
        child: Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color:
                    selected ? selectedColor : unselectedColor.withOpacity(1),
                shape: BoxShape.circle,
                //border: Border.all(
                //color: const Color(0xFF8B5CF6), width: selected ? 2 : 1),
              ),
              child: Center(
                child: Image.asset(
                  item['icon'],
                  width: 28,
                  height: 28,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item['label'],
              style: GoogleFonts.afacad(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? selectedColor : Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToScreen(int index) {
    final context = this.context;
    late Widget screen;
    
    switch (index) {
      case 1:
        screen = const CommunityScreen();
        break;
      case 2:
        screen = const DatingScreen();
        break;
      case 3:
        screen = const TrainingVideoScreen();
        break;
      case 4:
        screen = const EventsScreen();
        break;
      default:
        return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart';
import './ai_chat_screen.dart';
import './contact_screen.dart';
import './community_screen.dart';
import './news_screen.dart';
import './training_screen.dart';
import './training_video_screen.dart';
import './events_screen.dart';
import './dating_screen.dart';
import '../services/news_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> newsItems = [];
  bool isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _loadTopNews();
  }

  Future<void> _loadTopNews() async {
    try {
      final news = await NewsService.getPetNews();
      setState(() {
        newsItems = news.take(3).toList();
        isLoadingNews = false;
      });
    } catch (e) {
      setState(() {
        isLoadingNews = false;
      });
      print('Error loading news: $e');
    }
  }

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

                isLoadingNews
                    ? SizedBox(
                        height: 240,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      )
                    : newsItems.isEmpty
                        ? SizedBox(
                            height: 240,
                            child: Center(
                              child: Text(
                                'Không có bài viết',
                                style: GoogleFonts.afacad(color: Colors.grey),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 240,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: newsItems
                                  .map((news) => _newsCardFromApi(context, news))
                                  .toList(),
                            ),
                          ),

                const SizedBox(
                    height: 120),
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

  Widget _newsCardFromApi(BuildContext context, Map<String, dynamic> news) {
    return GestureDetector(
      onTap: () {
        _showNewsDetail(context, news);
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 220,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: (news['image'] ?? '').toString().startsWith('http')
                  ? Image.network(
                      news['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['title'] ?? 'Không có tiêu đề',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${news['author'] ?? 'NewsData'} • ${news['date'] ?? 'Gần đây'}',
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news['readTime'] ?? '1 phút',
                    style: GoogleFonts.afacad(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewsDetail(BuildContext context, Map<String, dynamic> news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  news['title'] ?? 'Không có tiêu đề',
                  style: GoogleFonts.afacad(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${news['author'] ?? 'NewsData'} • ${news['date'] ?? 'Gần đây'}',
                  style: GoogleFonts.afacad(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                if ((news['image'] ?? '').isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: (news['image'] ?? '').toString().startsWith('http')
                        ? Image.network(
                            news['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                const SizedBox(height: 16),
                if ((news['description'] ?? '').isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      news['description'] ?? '',
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  news['content'] ?? 'Không có nội dung',
                  style: GoogleFonts.afacad(
                    fontSize: 15,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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

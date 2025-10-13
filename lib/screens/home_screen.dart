// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart'; // Correct import for widgets directory

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
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
                                Text(
                                  'Thứ Tư, 01/10/2025',
                                  style: GoogleFonts.afacad(
                                    color: const Color(0xFF8E97FD),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    Text('• '),
                                    Text('Mèo Mochi đã ăn nhẹ '),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Text('• '),
                                    Text('Mua thuốc dị ứng mới'),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Text('• '),
                                    Text('Đồ chơi mới sắp về'),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Text('• '),
                                    Text('Thay cát cho Mochi'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8E97FD),
                                      minimumSize: const Size(80, 36),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Xem thêm',
                                        style: GoogleFonts.afacad(
                                            color: Colors.white)),
                                  ),
                                ),
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
                                Text(
                                  'THÁNG 10',
                                  style: GoogleFonts.afacad(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // simple calendar grid (static)
                                Table(
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children: [
                                    const TableRow(children: [
                                      Text('T2'),
                                      Text('T3'),
                                      Text('T4'),
                                      Text('T5'),
                                      Text('T6'),
                                      Text('T7'),
                                      Text('CN')
                                    ]),
                                    TableRow(children: [
                                      Text('29',
                                          style: TextStyle(color: Colors.grey)),
                                      Text('30',
                                          style: TextStyle(color: Colors.grey)),
                                      const Text('1'),
                                      const Text('2'),
                                      const Text('3'),
                                      const Text('4'),
                                      const Text('5')
                                    ]),
                                    const TableRow(children: [
                                      Text('6'),
                                      Text('7'),
                                      Text('8'),
                                      Text('9'),
                                      Text('10'),
                                      Text('11'),
                                      Text('12')
                                    ]),
                                    const TableRow(children: [
                                      Text('13'),
                                      Text('14'),
                                      Text('15'),
                                      Text('16'),
                                      Text('17'),
                                      Text('18'),
                                      Text('19')
                                    ]),
                                    const TableRow(children: [
                                      Text('20'),
                                      Text('21'),
                                      Text('22'),
                                      Text('23'),
                                      Text('24'),
                                      Text('25'),
                                      Text('26')
                                    ]),
                                    TableRow(children: [
                                      const Text('27'),
                                      const Text('28'),
                                      const Text('29'),
                                      const Text('30'),
                                      const Text('31'),
                                      Text('',
                                          style: TextStyle(
                                              color: Colors.transparent)),
                                      Text('',
                                          style: TextStyle(
                                              color: Colors.transparent))
                                    ]),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB45309),
                                    minimumSize: const Size(90, 36),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Đặt lịch',
                                      style: GoogleFonts.afacad(
                                          color: Colors.white)),
                                ),
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
                          onPressed: () {},
                          child: Text('Xem tất cả ...',
                              style: GoogleFonts.afacad(
                                  color: const Color(0xFF8E97FD))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _newsCard(
                              'Sức khỏe',
                              'lib/res/drawables/setting/tag-SK.png',
                              '5 bài viết • 3-10 phút'),
                          _newsCard(
                              'Giải trí',
                              'lib/res/drawables/setting/tag-VN.png',
                              '3 bài viết • 3-10 phút'),
                          _newsCard('Huấn luyện',
                              'lib/res/drawables/setting/tag-HL.jpg', '3 bài'),
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
          Positioned(
            bottom: 85,
            right: 20,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E97FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _newsCard(String title, String imagePath, String subtitle) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(imagePath,
                width: 140, height: 72, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: GoogleFonts.afacad(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8E97FD),
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.afacad(
                          color: const Color(0xFF6B7280), fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ],
              ),
            ),
          )
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
      'label': 'Tin tức',
      'icon': 'lib/res/drawables/setting/news.png',
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
}

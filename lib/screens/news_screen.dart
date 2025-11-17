import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  int selectedCategory = 0;

  final List<String> categories = [
    'Tất cả',
    'Sức khỏe',
    'Giải trí',
    'Khám phá',
  ];

  final List<Map<String, dynamic>> allNews = [
    {
      'title': '5 Dấu hiệu cho biết chó của bạn khỏe mạnh',
      'category': 'Sức khỏe',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'author': 'Dr. Nguyễn Văn An',
      'date': '15 Nov 2024',
      'readTime': '5 phút',
      'content': 'Một chú chó khỏe mạnh cần có những dấu hiệu nhất định...'
    },
    {
      'title': 'Cách tạo khu vui chơi an toàn cho thú cưng',
      'category': 'Giải trí',
      'image': 'lib/res/drawables/setting/tag-VN.png',
      'author': 'Pet Expert Team',
      'date': '14 Nov 2024',
      'readTime': '7 phút',
      'content': 'Thú cưng cần một không gian để chơi đùa và vận động...'
    },
    {
      'title': 'Những loài vật hoang dã kỳ lạ trên thế giới',
      'category': 'Khám phá',
      'image': 'lib/res/drawables/setting/tag-HL.jpg',
      'author': 'Wildlife Magazine',
      'date': '13 Nov 2024',
      'readTime': '8 phút',
      'content': 'Khám phá những loài động vật hiếm gặp và độc đáo...'
    },
    {
      'title': 'Cách huấn luyện chó con từ những tháng đầu',
      'category': 'Sức khỏe',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'author': 'Training Expert',
      'date': '12 Nov 2024',
      'readTime': '6 phút',
      'content': 'Huấn luyện chó con cần sự kiên nhẫn và phương pháp đúng...'
    },
    {
      'title': 'Những trò chơi vui nhộn cho mèo nhà',
      'category': 'Giải trí',
      'image': 'lib/res/drawables/setting/tag-VN.png',
      'author': 'Cat Lover',
      'date': '11 Nov 2024',
      'readTime': '4 phút',
      'content': 'Mèo là loài vật thích chơi, đặc biệt là vào ban đêm...'
    },
  ];

  List<Map<String, dynamic>> get filteredNews {
    if (selectedCategory == 0) {
      return allNews;
    }
    return allNews
        .where((news) => news['category'] == categories[selectedCategory])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tin tức',
          style: GoogleFonts.afacad(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Category filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedCategory == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = index;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF8B5CF6)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                categories[index],
                                style: GoogleFonts.afacad(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // News list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ...filteredNews
                        .map((news) => _newsCard(context, news))
                        .toList(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsCard(BuildContext context, Map<String, dynamic> news) {
    return GestureDetector(
      onTap: () {
        _showNewsDetail(context, news);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: AssetImage(news['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B5CF6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      news['category'],
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Title
                  Text(
                    news['title'],
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Meta info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFF8B5CF6),
                            child: Text(
                              news['author'][0],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news['author'],
                                style: GoogleFonts.afacad(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                news['date'],
                                style: GoogleFonts.afacad(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        news['readTime'],
                        style: GoogleFonts.afacad(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title'],
                  style: GoogleFonts.afacad(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${news['author']} • ${news['date']}',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(news['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  news['content'],
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris...',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> communityPosts = [
    {
      'author': 'Nguyễn Văn A',
      'avatar': '👨‍🦱',
      'title': 'Chó con cần bao nhiêu thức ăn mỗi ngày?',
      'content':
          'Mình có một chú chó 2 tháng tuổi, mình không biết nên cho ăn bao nhiêu lần và bao nhiêu gam mỗi lần...',
      'likes': 45,
      'comments': 12,
      'time': '2 giờ trước'
    },
    {
      'author': 'Trần Thị B',
      'avatar': '👩‍🦰',
      'title': 'Mèo bị rụng lông nhiều - có nguy hiểm không?',
      'content':
          'Mình nhận thấy mèo nhà rụng lông khá nhiều những ngày này. Đây có phải dấu hiệu của bệnh gì không?',
      'likes': 67,
      'comments': 23,
      'time': '4 giờ trước'
    },
    {
      'author': 'Lê Văn C',
      'avatar': '👨‍💼',
      'title': 'Kinh nghiệm chọn thức ăn cho cún yêu',
      'content':
          'Sau nhiều lần thử nghiệm, mình muốn chia sẻ kinh nghiệm chọn thức ăn tốt cho chó. Theo mình, chất lượng nguyên liệu là quan trọng nhất...',
      'likes': 123,
      'comments': 45,
      'time': '8 giờ trước'
    },
  ];

  final List<Map<String, dynamic>> trendingTopics = [
    {'topic': '#ChămSócThúCưng', 'posts': 1250},
    {'topic': '#MèoLầnĐầu', 'posts': 890},
    {'topic': '#ChóHuấnLuyện', 'posts': 756},
    {'topic': '#ThúCưngKhỏeMạnh', 'posts': 634},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Cộng đồng',
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
            child: Icon(Icons.notifications_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Tab selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _tabButton('Bài viết', 0),
                    SizedBox(width: 16),
                    _tabButton('Xu hướng', 1),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Content based on selected tab
              if (selectedTab == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Create post button
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFF8B5CF6),
                              child: Text('ME', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bạn đang nghĩ gì?',
                                style: GoogleFonts.afacad(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(Icons.edit, color: Color(0xFF8B5CF6)),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Posts list
                      ...communityPosts.map((post) => _postCard(post)).toList(),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: trendingTopics
                        .map((topic) => _trendingCard(topic))
                        .toList(),
                  ),
                ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 8),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(post['avatar'], style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: GoogleFonts.afacad(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        post['time'],
                        style: GoogleFonts.afacad(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          SizedBox(height: 12),

          // Content
          Text(
            post['title'],
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            post['content'],
            style: GoogleFonts.afacad(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),

          // Footer - Interactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${post['likes']}',
                    style: GoogleFonts.afacad(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${post['comments']}',
                    style: GoogleFonts.afacad(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.share, size: 18, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Chia sẻ',
                    style: GoogleFonts.afacad(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trendingCard(Map<String, dynamic> topic) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic['topic'],
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${topic['posts']} bài viết',
                style: GoogleFonts.afacad(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Xem',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

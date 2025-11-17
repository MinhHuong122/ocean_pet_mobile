import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/CommunityService.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedTab = 0;
  final String defaultCommunityId = 'general'; // Default community
  final ImagePicker _imagePicker = ImagePicker();

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
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Avatar',
                              style: TextStyle(fontSize: 32),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showCreatePostDialog,
                                child: Text(
                                  'Bạn đang nghĩ gì?',
                                  style: GoogleFonts.afacad(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Posts list - Real-time
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: CommunityService.getCommunityPosts(defaultCommunityId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final posts = snapshot.data ?? [];

                          if (posts.isEmpty) {
                            return Center(
                              child: Text(
                                'Chưa có bài viết nào',
                                style: GoogleFonts.afacad(color: Colors.grey),
                              ),
                            );
                          }

                          return Column(
                            children: posts
                                .map((post) => _postCard(context, post))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: CommunityService.getTrendingTopics(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final topics = snapshot.data ?? [];

                      if (topics.isEmpty) {
                        return Center(
                          child: Text(
                            'Chưa có xu hướng nào',
                            style: GoogleFonts.afacad(color: Colors.grey),
                          ),
                        );
                      }

                      return Column(
                        children:
                            topics.map((topic) => _trendingCard(topic)).toList(),
                      );
                    },
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

  Widget _postCard(BuildContext context, Map<String, dynamic> post) {
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
                  Text('👤', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ${post['user_id']?.substring(0, 5) ?? 'Unknown'}',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vừa xong',
                        style: GoogleFonts.afacad(
                          fontSize: 11,
                          color: Colors.grey,
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
            post['title'] ?? '',
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            post['content'] ?? '',
            style: GoogleFonts.afacad(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (post['image_url'] != null) ...[
            SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(post['image_url']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          SizedBox(height: 12),

          // Footer - Interactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    await CommunityService.likePost(defaultCommunityId, post['id']);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '${post['likes_count'] ?? 0}',
                      style: GoogleFonts.afacad(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${post['comments_count'] ?? 0}',
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
                topic['topic'] ?? '#Trending',
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${topic['post_count'] ?? 0} bài viết',
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

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String? imageUrl;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Tạo bài viết',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Tiêu đề bài viết',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: GoogleFonts.afacad(),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: 'Nội dung bài viết',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 4,
                  style: GoogleFonts.afacad(),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setState(() {
                        // TODO: Upload to Cloudinary and get URL
                        imageUrl = 'https://via.placeholder.com/400x300';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hình ảnh sẽ được tải lên Cloudinary'),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.image),
                  label: Text('Thêm hình ảnh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await CommunityService.createPost(
                    communityId: defaultCommunityId,
                    title: titleController.text,
                    content: contentController.text,
                    imageUrl: imageUrl,
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bài viết đã được đăng!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B5CF6),
              ),
              child: Text('Đăng', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

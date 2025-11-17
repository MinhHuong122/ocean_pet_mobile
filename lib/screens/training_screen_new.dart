import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/TrainingService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class TrainingScreenNew extends StatefulWidget {
  const TrainingScreenNew({super.key});

  @override
  State<TrainingScreenNew> createState() => _TrainingScreenNewState();
}

class _TrainingScreenNewState extends State<TrainingScreenNew> {
  String selectedCategory = 'all';
  String selectedLevel = 'all';
  int selectedTab = 0; // 0: Tất cả, 1: Được xếp hạng, 2: Được xem nhiều

  final List<String> categories = [
    'all',
    'Chó',
    'Mèo',
    'Chim',
    'Thú nhỏ',
  ];

  final List<String> levels = [
    'all',
    'beginner',
    'intermediate',
    'advanced',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Video hướng dẫn',
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
            child: GestureDetector(
              onTap: () => _showUploadVideoDialog(),
              child: Icon(Icons.add_circle, color: Color(0xFF8B5CF6), size: 28),
            ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _tabButton('Tất cả', 0),
                    _tabButton('Được xếp hạng', 1),
                    _tabButton('Được xem', 2),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thể loại',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories
                            .map((cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => selectedCategory = cat);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selectedCategory == cat
                                            ? Color(0xFF8B5CF6)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        cat == 'all' ? 'Tất cả' : cat,
                                        style: GoogleFonts.afacad(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: selectedCategory == cat
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mức độ',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: levels
                            .map((level) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => selectedLevel = level);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selectedLevel == level
                                            ? Color(0xFF8B5CF6)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _getLevelLabel(level),
                                        style: GoogleFonts.afacad(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: selectedLevel == level
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Videos list - Real-time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _getVideosStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final videos = snapshot.data ?? [];

                        if (videos.isEmpty) {
                          return Center(
                            child: Text(
                              'Chưa có video nào',
                              style: GoogleFonts.afacad(color: Colors.grey),
                            ),
                          );
                        }

                        return Column(
                          children: videos
                              .map((video) => _videoCard(context, video))
                              .toList(),
                        );
                      },
                    ),
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

  Stream<List<Map<String, dynamic>>> _getVideosStream() {
    Stream<List<Map<String, dynamic>>> baseStream;

    if (selectedTab == 1) {
      baseStream = TrainingService.getTrendingVideos();
    } else if (selectedTab == 2) {
      baseStream = TrainingService.getMostViewedVideos();
    } else {
      baseStream = TrainingService.searchVideos('');
    }

    return baseStream.map((videos) {
      var filtered = videos;

      if (selectedCategory != 'all') {
        filtered = filtered
            .where((v) => v['category'] == selectedCategory)
            .toList();
      }

      if (selectedLevel != 'all') {
        filtered =
            filtered.where((v) => v['level'] == selectedLevel).toList();
      }

      return filtered;
    });
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
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 8),
              height: 3,
              width: 25,
              decoration: BoxDecoration(
                color: Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _videoCard(BuildContext context, Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () => _showVideoDetail(context, video),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  if (video['thumbnail_url'] != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(video['thumbnail_url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Center(
                    child: Icon(
                      Icons.play_circle,
                      size: 50,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getLevelLabel(video['level'] ?? 'beginner'),
                        style: GoogleFonts.afacad(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] ?? 'Untitled Video',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22223B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < (video['rating']?.toInt() ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Color(0xFFFFA500),
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${(video['rating'] ?? 0).toStringAsFixed(1)}',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.visibility, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '${video['view_count'] ?? 0}',
                            style: GoogleFonts.afacad(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          video['category'] ?? 'N/A',
                          style: GoogleFonts.afacad(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF22223B),
                          ),
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

  void _showVideoDetail(BuildContext context, Map<String, dynamic> video) {
    double? userRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] ?? 'Untitled Video',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22223B),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Rating display
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xếp hạng',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < (video['rating']?.toInt() ?? 0)
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 18,
                                  color: Color(0xFFFFA500),
                                ),
                              ),
                            ),
                            Text(
                              '${(video['rating'] ?? 0).toStringAsFixed(1)} / 5.0',
                              style: GoogleFonts.afacad(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lượt xem',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Icon(Icons.visibility, color: Color(0xFF8B5CF6)),
                            Text(
                              '${video['view_count'] ?? 0}',
                              style: GoogleFonts.afacad(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Mô tả',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22223B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    video['description'] ?? 'No description',
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Video info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mức độ:',
                              style: GoogleFonts.afacad(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getLevelLabel(video['level'] ?? 'beginner'),
                              style: GoogleFonts.afacad(),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thể loại:',
                              style: GoogleFonts.afacad(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              video['category'] ?? 'N/A',
                              style: GoogleFonts.afacad(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Rating input
                  Text(
                    'Đánh giá video này',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22223B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            userRating = (index + 1).toDouble();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            index < (userRating?.toInt() ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            size: 32,
                            color: Color(0xFFFFA500),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: userRating == null
                          ? null
                          : () async {
                              try {
                                await TrainingService.rateVideo(
                                  video['id'],
                                  userRating!.toInt(),
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Cảm ơn bạn đã đánh giá video!'),
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
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        'Gửi đánh giá',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUploadVideoDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedLevel = 'beginner';
    String selectedCategory = 'Chó';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Tải video lên',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Tên video',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.afacad(),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Mô tả video',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  style: GoogleFonts.afacad(),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Mức độ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['beginner', 'intermediate', 'advanced']
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(_getLevelLabel(level)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedLevel = value);
                    }
                  },
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Thể loại',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Chó', 'Mèo', 'Chim', 'Thú nhỏ']
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Lưu ý: Cloudinary integration cần được cấu hình với CLOUDINARY_CLOUD_NAME',
                  style: GoogleFonts.afacad(fontSize: 11, color: Colors.orange),
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
                  await TrainingService.createTrainingVideo(
                    title: titleController.text,
                    description: descriptionController.text,
                    videoUrl: 'https://example.com/video.mp4',
                    thumbnailUrl: 'https://example.com/thumbnail.jpg',
                    level: selectedLevel,
                    category: selectedCategory,
                    tags: [selectedCategory, selectedLevel],
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Video đã được tải lên!'),
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
              child: Text('Tải lên', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelLabel(String level) {
    switch (level) {
      case 'beginner':
        return 'Cơ bản';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      case 'all':
        return 'Tất cả';
      default:
        return level;
    }
  }
}

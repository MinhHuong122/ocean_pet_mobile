// lib/screens/training_video_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './youtube_player_screen.dart';

class TrainingVideoScreen extends StatefulWidget {
  const TrainingVideoScreen({super.key});

  @override
  State<TrainingVideoScreen> createState() => _TrainingVideoScreenState();
}

class _TrainingVideoScreenState extends State<TrainingVideoScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allVideos = [];
  List<Map<String, dynamic>> filteredVideos = [];
  Set<String> favoriteVideoIds = {};
  bool isLoading = true;
  
  // Filter states
  String selectedAnimalType = 'Tất cả';
  String selectedLevel = 'Tất cả';
  String sortBy = 'Mới nhất'; // Mới nhất, Phổ biến nhất, Đánh giá cao
  
  final List<String> animalTypes = ['Tất cả', 'Chó', 'Mèo', 'Thỏ', 'Chim', 'Khác'];
  final List<String> levels = ['Tất cả', 'Cơ bản', 'Trung cấp', 'Nâng cao'];
  final List<String> sortOptions = ['Mới nhất', 'Phổ biến nhất', 'Đánh giá cao'];
  
  final List<Map<String, dynamic>> trainingVideos = [
    {
      'id': 'video1',
      'title': 'Huấn luyện cơ bản cho chó',
      'url': 'https://www.youtube.com/watch?v=vwGr1GAQ7Xg',
      'thumbnail': Icons.play_circle,
      'duration': '15:30',
      'description': 'Hướng dẫn các lệnh cơ bản: ngồi, nằm, đứng yên',
      'level': 'Cơ bản',
      'animalType': 'Chó',
      'views': 1250,
      'rating': 4.8,
      'uploadDate': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 'video2',
      'title': 'Huấn luyện chó nghe lời',
      'url': 'https://www.youtube.com/watch?v=4dbzPoB7AKk',
      'thumbnail': Icons.play_circle,
      'duration': '20:15',
      'description': 'Dạy chó nghe lời chủ và tuân theo mệnh lệnh',
      'level': 'Trung cấp',
      'animalType': 'Chó',
      'views': 2340,
      'rating': 4.9,
      'uploadDate': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': 'video3',
      'title': 'Huấn luyện mèo',
      'url': 'https://www.youtube.com/watch?v=T0xzdu-wTM0',
      'thumbnail': Icons.play_circle,
      'duration': '12:45',
      'description': 'Cách huấn luyện mèo cưng thông minh',
      'level': 'Cơ bản',
      'animalType': 'Mèo',
      'views': 980,
      'rating': 4.5,
      'uploadDate': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 'video4',
      'title': 'Huấn luyện chó đi vệ sinh đúng chỗ',
      'url': 'https://www.youtube.com/watch?v=qKnMxZjn6fI',
      'thumbnail': Icons.play_circle,
      'duration': '18:20',
      'description': 'Dạy chó đi vệ sinh đúng nơi quy định',
      'level': 'Cơ bản',
      'animalType': 'Chó',
      'views': 3200,
      'rating': 4.7,
      'uploadDate': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 'video5',
      'title': 'Kỹ năng xã hội cho thú cưng',
      'url': 'https://www.youtube.com/watch?v=example1',
      'thumbnail': Icons.play_circle,
      'duration': '22:10',
      'description': 'Giúp thú cưng giao tiếp tốt với người và động vật khác',
      'level': 'Nâng cao',
      'animalType': 'Chó',
      'views': 1560,
      'rating': 4.6,
      'uploadDate': DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      'id': 'video6',
      'title': 'Huấn luyện chó nhặt đồ',
      'url': 'https://www.youtube.com/watch?v=example2',
      'thumbnail': Icons.play_circle,
      'duration': '16:40',
      'description': 'Dạy chó nhặt đồ vật và đưa cho chủ',
      'level': 'Trung cấp',
      'animalType': 'Chó',
      'views': 890,
      'rating': 4.4,
      'uploadDate': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 'video7',
      'title': 'Huấn luyện mèo dùng nhà vệ sinh',
      'url': 'https://www.youtube.com/watch?v=example3',
      'thumbnail': Icons.play_circle,
      'duration': '14:30',
      'description': 'Hướng dẫn mèo sử dụng khay cát đúng cách',
      'level': 'Cơ bản',
      'animalType': 'Mèo',
      'views': 1850,
      'rating': 4.8,
      'uploadDate': DateTime.now().subtract(const Duration(days: 8)),
    },
    {
      'id': 'video8',
      'title': 'Huấn luyện thỏ cơ bản',
      'url': 'https://www.youtube.com/watch?v=example4',
      'thumbnail': Icons.play_circle,
      'duration': '11:20',
      'description': 'Các kỹ thuật huấn luyện thỏ cảnh',
      'level': 'Cơ bản',
      'animalType': 'Thỏ',
      'views': 620,
      'rating': 4.3,
      'uploadDate': DateTime.now().subtract(const Duration(days: 12)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadVideos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_videos') ?? [];
    setState(() {
      favoriteVideoIds = favorites.toSet();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_videos', favoriteVideoIds.toList());
  }

  Future<void> _loadVideos() async {
    setState(() => isLoading = true);
    
    try {
      // Try to load from Firebase first
      final snapshot = await FirebaseFirestore.instance
          .collection('training_videos')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        allVideos = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'url': data['url'] ?? '',
            'thumbnail': Icons.play_circle,
            'duration': data['duration'] ?? '0:00',
            'description': data['description'] ?? '',
            'level': data['level'] ?? 'Cơ bản',
            'animalType': data['animalType'] ?? 'Khác',
            'views': data['views'] ?? 0,
            'rating': (data['rating'] ?? 0.0).toDouble(),
            'uploadDate': (data['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          };
        }).toList();
      } else {
        // Fallback to local data
        allVideos = List.from(trainingVideos);
      }
    } catch (e) {
      // If Firebase fails, use local data
      allVideos = List.from(trainingVideos);
      debugPrint('Error loading videos from Firebase: $e');
    }
    
    _applyFilters();
    setState(() => isLoading = false);
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(allVideos);
    
    // Filter by animal type
    if (selectedAnimalType != 'Tất cả') {
      result = result.where((v) => v['animalType'] == selectedAnimalType).toList();
    }
    
    // Filter by level
    if (selectedLevel != 'Tất cả') {
      result = result.where((v) => v['level'] == selectedLevel).toList();
    }
    
    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((v) {
        return v['title'].toLowerCase().contains(query) ||
               v['description'].toLowerCase().contains(query);
      }).toList();
    }
    
    // Sort
    if (sortBy == 'Mới nhất') {
      result.sort((a, b) => (b['uploadDate'] as DateTime).compareTo(a['uploadDate'] as DateTime));
    } else if (sortBy == 'Phổ biến nhất') {
      result.sort((a, b) => (b['views'] as int).compareTo(a['views'] as int));
    } else if (sortBy == 'Đánh giá cao') {
      result.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }
    
    setState(() {
      filteredVideos = result;
    });
  }

  void _toggleFavorite(String videoId) async {
    setState(() {
      if (favoriteVideoIds.contains(videoId)) {
        favoriteVideoIds.remove(videoId);
      } else {
        favoriteVideoIds.add(videoId);
      }
    });
    await _saveFavorites();
  }

  Future<void> _incrementViews(String videoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('training_videos')
          .doc(videoId)
          .update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Huấn luyện',
          style: GoogleFonts.afacad(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${favoriteVideoIds.length}'),
              isLabelVisible: favoriteVideoIds.isNotEmpty,
              child: const Icon(Icons.favorite, color: Color(0xFFEF5350)),
            ),
            onPressed: _showFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Color(0xFF8E97FD)),
            onPressed: _showDonateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm video...',
                hintStyle: GoogleFonts.afacad(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8E97FD)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8E97FD), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.afacad(),
            ),
          ),
          
          // Filter chips
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFilterChip(
                    icon: Icons.pets,
                    label: selectedAnimalType,
                    onTap: _showAnimalTypeFilter,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    icon: Icons.bar_chart,
                    label: selectedLevel,
                    onTap: _showLevelFilter,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    icon: Icons.sort,
                    label: sortBy,
                    onTap: _showSortOptions,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Videos count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Tìm thấy ${filteredVideos.length} video',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (selectedAnimalType != 'Tất cả' || selectedLevel != 'Tất cả' || _searchController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedAnimalType = 'Tất cả';
                        selectedLevel = 'Tất cả';
                        _searchController.clear();
                      });
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: Text('Xóa bộ lọc', style: GoogleFonts.afacad(fontSize: 12)),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Videos list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E97FD)))
                : filteredVideos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy video nào',
                              style: GoogleFonts.afacad(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadVideos,
                        color: const Color(0xFF8E97FD),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredVideos.length,
                          itemBuilder: (context, index) {
                            final video = filteredVideos[index];
                            return _buildVideoCard(video);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final isFavorite = favoriteVideoIds.contains(video['id']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _incrementViews(video['id']);
          _openYoutubePlayer(video['url'], video['title']);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          video['thumbnail'],
                          color: Colors.white,
                          size: 48,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video['duration'],
                              style: GoogleFonts.afacad(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                video['title'],
                                style: GoogleFonts.afacad(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _toggleFavorite(video['id']),
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? const Color(0xFFEF5350) : Colors.grey,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video['description'],
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getLevelColor(video['level']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                video['level'],
                                style: GoogleFonts.afacad(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(video['level']),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E97FD).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.pets, size: 12, color: Color(0xFF8E97FD)),
                                  const SizedBox(width: 4),
                                  Text(
                                    video['animalType'],
                                    style: GoogleFonts.afacad(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF8E97FD),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${video['views']} lượt xem',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFB74D)),
                  const SizedBox(width: 4),
                  Text(
                    '${video['rating']}',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatUploadDate(video['uploadDate']),
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF8E97FD).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8E97FD).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF8E97FD)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.afacad(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8E97FD),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF8E97FD)),
          ],
        ),
      ),
    );
  }

  String _formatUploadDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Hôm nay';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} tuần trước';
    return '${(diff.inDays / 30).floor()} tháng trước';
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Cơ bản':
        return const Color(0xFF66BB6A);
      case 'Trung cấp':
        return const Color(0xFFFFB74D);
      case 'Nâng cao':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF8E97FD);
    }
  }

  void _showAnimalTypeFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn loài vật',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 16),
            ...animalTypes.map((type) => ListTile(
              leading: Icon(
                Icons.pets,
                color: selectedAnimalType == type 
                    ? const Color(0xFF8E97FD) 
                    : Colors.grey,
              ),
              title: Text(
                type,
                style: GoogleFonts.afacad(
                  fontWeight: selectedAnimalType == type 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              trailing: selectedAnimalType == type
                  ? const Icon(Icons.check, color: Color(0xFF8E97FD))
                  : null,
              onTap: () {
                setState(() => selectedAnimalType = type);
                _applyFilters();
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showLevelFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn cấp độ',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 16),
            ...levels.map((level) => ListTile(
              leading: Icon(
                Icons.bar_chart,
                color: selectedLevel == level 
                    ? _getLevelColor(level) 
                    : Colors.grey,
              ),
              title: Text(
                level,
                style: GoogleFonts.afacad(
                  fontWeight: selectedLevel == level 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              trailing: selectedLevel == level
                  ? Icon(Icons.check, color: _getLevelColor(level))
                  : null,
              onTap: () {
                setState(() => selectedLevel = level);
                _applyFilters();
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sắp xếp theo',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 16),
            ...sortOptions.map((option) => ListTile(
              leading: Icon(
                Icons.sort,
                color: sortBy == option 
                    ? const Color(0xFF8E97FD) 
                    : Colors.grey,
              ),
              title: Text(
                option,
                style: GoogleFonts.afacad(
                  fontWeight: sortBy == option 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              trailing: sortBy == option
                  ? const Icon(Icons.check, color: Color(0xFF8E97FD))
                  : null,
              onTap: () {
                setState(() => sortBy = option);
                _applyFilters();
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showFavorites() {
    final favoriteVideos = allVideos
        .where((v) => favoriteVideoIds.contains(v['id']))
        .toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFEF5350)),
                  const SizedBox(width: 12),
                  Text(
                    'Video yêu thích (${favoriteVideos.length})',
                    style: GoogleFonts.afacad(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: favoriteVideos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có video yêu thích',
                              style: GoogleFonts.afacad(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: favoriteVideos.length,
                        itemBuilder: (context, index) {
                          return _buildVideoCard(favoriteVideos[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openYoutubePlayer(String videoUrl, String videoTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YoutubePlayerScreen(
          videoUrl: videoUrl,
          videoTitle: videoTitle,
        ),
      ),
    );
  }

  void _showDonateDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ủng hộ chúng tôi',
                  style: GoogleFonts.afacad(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cảm ơn bạn đã ủng hộ để chúng tôi có thể tạo ra nhiều video huấn luyện hữu ích hơn!',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // QR Code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8E97FD).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: 'https://qr.momo.vn/1234567890',
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Quét mã QR để chuyển khoản',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          color: const Color(0xFF22223B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Bank Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Ngân hàng', 'MoMo'),
                      const Divider(),
                      _buildInfoRow('Số tài khoản', '0123456789'),
                      const Divider(),
                      _buildInfoRow('Tên', 'OCEAN PET CARE'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E97FD),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Đóng',
                      style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.afacad(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
      ],
    );
  }

}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/FirebaseService.dart';
import '../services/CommunityService.dart';
import '../services/UserProfileService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedTab = 0; // 0: Posts, 1: Favorites, 2: My Posts, 3: Search
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? currentUserId;

  // Notifications for like events
  final List<Map<String, dynamic>> notifications = [];
  int unreadNotifications = 0;

  List<Map<String, dynamic>> communityPosts = [];
  List<Map<String, dynamic>> filteredPosts = [];
  List<String> favoritedPostIds = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCommunityPosts();
  }

  Future<void> _loadCommunityPosts() async {
    try {
      print('📥 [CommunityScreen] Loading posts from Firebase...');
      
      // Subscribe to real-time updates from Firebase
      CommunityService.getCommunityPosts().listen(
        (postsFromFirebase) async {
          print('✅ [CommunityScreen] Received ${postsFromFirebase.length} posts from Firebase');
          
          final processedPosts = <Map<String, dynamic>>[];
          
          for (var post in postsFromFirebase) {
            try {
              // Check privacy: show if public OR if current user is the owner
              final isPrivate = post['is_private'] ?? false;
              final createdBy = post['created_by'] ?? '';
              final shouldShow = !isPrivate || createdBy == currentUserId;
              
              if (!shouldShow) {
                print('🔒 [CommunityScreen] Skipping private post from $createdBy');
                continue; // Skip private posts from other users
              }
              
              // Get author info from users collection
              final authorDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(createdBy)
                  .get();
              
              final authorData = authorDoc.data() ?? {};
              final authorName = authorData['name'] ?? 'Ẩn danh';
              final authorAvatar = authorData['avatar_url'] ?? '👤';
              
              // Format time
              DateTime createdAt = DateTime.now();
              if (post['created_at'] is Timestamp) {
                createdAt = (post['created_at'] as Timestamp).toDate();
              }
              final timeAgo = _getTimeAgo(createdAt);
              
              // Build processed post
              final processedPost = {
                'id': post['id'] ?? '',
                'author': authorName,
                'avatar': authorAvatar,
                'userId': createdBy,
                'title': post['title'] ?? '',
                'content': post['content'] ?? '',
                'image': post['image_url'], // From Cloudinary
                'likes': post['likes_count'] ?? 0,
                'liked': false, // Will be updated if user liked
                'comments': post['comments_count'] ?? 0,
                'shares': post['shares_count'] ?? 0,
                'time': timeAgo,
                'isPrivate': isPrivate,
                'isBlocked': false,
                'isHidden': false,
                'commentsList': [],
              };
              
              processedPosts.add(processedPost);
              print('✅ [CommunityScreen] Processed post: ${post['title']}, Private: $isPrivate');
            } catch (e) {
              print('⚠️ [CommunityScreen] Error processing post: $e');
              continue;
            }
          }
          
          setState(() {
            communityPosts = processedPosts;
            filteredPosts = List.from(communityPosts);
            print('📊 [CommunityScreen] Updated UI with ${communityPosts.length} visible posts');
          });
        },
        onError: (error) {
          print('❌ [CommunityScreen] Error loading posts: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải bài viết: $error')),
          );
        },
      );
    } catch (e) {
      print('❌ [CommunityScreen] Error in _loadCommunityPosts: $e');
    }
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${(difference.inDays / 7).floor()} tuần trước';
    }
  }

  Future<void> _loadCurrentUser() async {
    final userId = FirebaseService.currentUserId;
    setState(() {
      currentUserId = userId;
    });
  }

  void _searchPosts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPosts = List.from(communityPosts);
      } else {
        filteredPosts = communityPosts
            .where((post) =>
                post['title'].toLowerCase().contains(query.toLowerCase()) ||
                post['content'].toLowerCase().contains(query.toLowerCase()) ||
                post['author'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleLike(String postId) {
    setState(() {
      final post = communityPosts.firstWhere((p) => p['id'] == postId);
      post['liked'] = !post['liked'];
      post['likes'] += post['liked'] ? 1 : -1;

      if (post['liked']) {
        if (!favoritedPostIds.contains(postId)) {
          favoritedPostIds.add(postId);
        }
        _addNotification('Có người vừa thích bài viết: "${post['title'].isEmpty ? 'Không tiêu đề' : post['title']}"');
      } else {
        favoritedPostIds.remove(postId);
      }
    });
  }

  void _addNotification(String message) {
    notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': message,
      'time': DateTime.now(),
      'read': false,
    });
    unreadNotifications++;
  }

  void _showNotifications() {
    final mq = MediaQuery.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          title: Text('Thông báo',
              style: GoogleFonts.afacad(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: mq.size.width * 0.9,
            height: mq.size.height * 0.6,
            child: notifications.isEmpty
                ? Center(
                    child: Text('Chưa có thông báo nào',
                        style: GoogleFonts.afacad(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: n['read'] ? Colors.grey[100] : const Color(0xFF8B5CF6).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Color(0xFFEF5350), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(n['message'],
                                  style: GoogleFonts.afacad(fontSize: 13)),
                            ),
                            Text(_formatTime(n['time']),
                                style: GoogleFonts.afacad(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            if (notifications.isNotEmpty)
              TextButton(
                onPressed: () {
                  setDlgState(() {
                    for (var n in notifications) n['read'] = true;
                    unreadNotifications = 0;
                  });
                },
                child: Text('Đánh dấu đã đọc',
                    style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng', style: GoogleFonts.afacad()),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    return '${diff.inDays} ngày';
  }

  void _showCommentsSheet(String postId) {
    final post = communityPosts.firstWhere((p) => p['id'] == postId);
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Bình luận',
                  style: GoogleFonts.afacad(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Comments list
              if (post['commentsList'].isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Chưa có bình luận nào',
                    style: GoogleFonts.afacad(color: Colors.grey),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: post['commentsList'].length,
                    itemBuilder: (context, index) {
                      final comment = post['commentsList'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(comment['avatar'],
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['author'],
                                        style: GoogleFonts.afacad(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        comment['time'],
                                        style: GoogleFonts.afacad(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comment['content'],
                              style: GoogleFonts.afacad(fontSize: 13),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(height: 16),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Comment input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Viết bình luận...',
                            hintStyle: GoogleFonts.afacad(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          style: GoogleFonts.afacad(),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (commentController.text.isNotEmpty && mounted) {
                            setModalState(() {
                              post['commentsList'].add({
                                'author': 'Bạn',
                                'avatar': '👤',
                                'content': commentController.text,
                                'time': 'Vừa xong',
                              });
                              post['comments']++;
                              commentController.clear();
                            });
                            setState(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5CF6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _sharePost(String postId) {
    final originalPost = communityPosts.firstWhere((p) => p['id'] == postId);
    
    setState(() {
      // Create shared post
      final sharedPost = {
        'id': 'shared_${DateTime.now().millisecondsSinceEpoch}',
        'author': 'Bạn',
        'avatar': '👤',
        'userId': currentUserId ?? 'current_user',
        'title': '',
        'content': '',
        'image': null,
        'likes': 0,
        'liked': false,
        'comments': 0,
        'shares': 0,
        'time': 'Vừa xong',
        'isPrivate': false,
        'isBlocked': false,
        'isHidden': false,
        'commentsList': [],
        'isShared': true,
        'sharedPost': originalPost,
      };
      
      communityPosts.insert(0, sharedPost);
      filteredPosts = List.from(communityPosts);
      selectedTab = 2; // Switch to My Posts tab
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chia sẻ bài viết',
            style: GoogleFonts.afacad()),
        backgroundColor: const Color(0xFF8B5CF6),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPostMenu(String postId) {
    final post = communityPosts.firstWhere((p) => p['id'] == postId);
    final isMyPost = post['userId'] == currentUserId || post['author'] == 'Bạn';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (isMyPost) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF8B5CF6)),
                title: Text('Chỉnh sửa',
                    style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chỉnh sửa bài viết',
                          style: GoogleFonts.afacad()),
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFEF5350)),
                title: Text('Xóa',
                    style: GoogleFonts.afacad(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF5350))),
                onTap: () {
                  Navigator.pop(context);
                  communityPosts.removeWhere((p) => p['id'] == postId);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa bài viết',
                          style: GoogleFonts.afacad()),
                      backgroundColor: const Color(0xFFEF5350),
                    ),
                  );
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.block, color: Color(0xFF9CA3AF)),
              title: Text('Chặn',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  post['isBlocked'] = !post['isBlocked'];
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        post['isBlocked']
                            ? 'Đã chặn người dùng này'
                            : 'Đã bỏ chặn',
                        style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Color(0xFF9CA3AF)),
              title: Text('Ẩn bài viết',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  post['isHidden'] = !post['isHidden'];
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        post['isHidden']
                            ? 'Đã ẩn bài viết này'
                            : 'Đã hiển thị bài viết',
                        style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Color(0xFFEF5350)),
              title: Text('Báo cáo',
                  style: GoogleFonts.afacad(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF5350))),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã báo cáo bài viết',
                        style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFFEF5350),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    XFile? selectedImage;
    bool isPrivate = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final mq = MediaQuery.of(context);
          return SizedBox(
            height: mq.size.height * 0.67,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: mq.viewInsets.bottom + 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
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
                  const SizedBox(height: 12),
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF8B5CF6),
                        child: currentUserId != null
                            ? Text(
                                currentUserId?.substring(0, 1).toUpperCase() ?? 'U',
                                style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            : const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bạn', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () => setSheetState(() => isPrivate = !isPrivate),
                              child: Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(isPrivate ? Icons.lock : Icons.public, size: 14, color: Colors.black87),
                                    const SizedBox(width: 4),
                                    Text(isPrivate ? 'Chỉ mình tôi' : 'Công khai',
                                        style: GoogleFonts.afacad(fontSize: 12, fontWeight: FontWeight.w500)),
                                    const Icon(Icons.keyboard_arrow_down, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title & content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: titleController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Tiêu đề bài viết...',
                              hintStyle: GoogleFonts.afacad(color: Colors.grey[600], fontSize: 16),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: contentController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: 'Bạn đang nghĩ gì?',
                              hintStyle: GoogleFonts.afacad(color: Colors.grey[600], fontSize: 14),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.afacad(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          // Image selector
                          GestureDetector(
                            onTap: () async {
                              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                              if (image != null && mounted) {
                                setSheetState(() => selectedImage = image);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B5CF6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image_outlined, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedImage == null ? 'Thêm ảnh vào bài viết' : 'Đã chọn ảnh',
                                      style: GoogleFonts.afacad(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                    ),
                                  ),
                                  if (selectedImage != null)
                                    const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 20),
                                ],
                              ),
                            ),
                          ),
                          if (selectedImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(selectedImage!.path),
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => setSheetState(() => selectedImage = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Full width submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty && contentController.text.isNotEmpty && mounted) {
                          try {
                            // Save to Firebase
                            print('📤 [CommunityScreen] Creating post: ${titleController.text}');
                            print('   Privacy: ${isPrivate ? 'Riêng tư' : 'Công khai'}');
                            
                            final postId = await CommunityService.createPost(
                              title: titleController.text,
                              content: contentController.text,
                              imageUrl: null, // TODO: Upload to Cloudinary if image selected
                            );
                            
                            // Add privacy field to post in Firebase
                            await FirebaseFirestore.instance
                                .collection('communities')
                                .doc('general')
                                .collection('posts')
                                .doc(postId)
                                .update({'is_private': isPrivate});
                            
                            print('✅ [CommunityScreen] Post created with ID: $postId');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isPrivate ? 'Đã đăng bài riêng tư' : 'Đã đăng bài công khai',
                                  style: GoogleFonts.afacad(),
                                ),
                                backgroundColor: const Color(0xFF66BB6A),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            print('❌ [CommunityScreen] Error creating post: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi đăng bài: $e', style: GoogleFonts.afacad()),
                                backgroundColor: const Color(0xFFEF5350),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Đăng bài',
                          style: GoogleFonts.afacad(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Text('Cộng đồng',
            style: GoogleFonts.afacad(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showNotifications,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                  if (unreadNotifications > 0)
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$unreadNotifications',
                            style: GoogleFonts.afacad(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab selection
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tabButton('Bài viết', 0),
                    const SizedBox(width: 16),
                    _tabButton('Yêu thích', 1),
                    const SizedBox(width: 16),
                    _tabButton('Bài của tôi', 2),
                    const SizedBox(width: 16),
                    _tabButton('Tìm kiếm', 3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: selectedTab == 3
                  ? _buildSearchTab()
                  : SingleChildScrollView(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            if (selectedTab == 0)
                              _buildPostsTab()
                            else if (selectedTab == 1)
                              _buildFavoritesTab()
                            else if (selectedTab == 2)
                              _buildMyPostsTab(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return Column(
      children: [
        // Create post button
        GestureDetector(
          onTap: _showCreatePostDialog,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF8B5CF6),
                  child: currentUserId != null
                      ? Text(
                          currentUserId?.substring(0, 1).toUpperCase() ?? 'U',
                          style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bạn',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Bạn đang nghĩ gì?',
                        style: GoogleFonts.afacad(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...communityPosts
            .where((post) => !post['isHidden'])
            .map((post) => _postCard(post))
            .toList(),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    final favoritedPosts = communityPosts
        .where((post) =>
            favoritedPostIds.contains(post['id']) && !post['isHidden'])
        .toList();

    if (favoritedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline,
                size: 64,
                color: const Color(0xFF8B5CF6).withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài viết yêu thích',
              style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: favoritedPosts.map((post) => _postCard(post)).toList(),
    );
  }

  Widget _buildMyPostsTab() {
    final myPosts = communityPosts
        .where((post) =>
            (post['userId'] == currentUserId || post['author'] == 'Bạn') &&
            !post['isHidden'])
        .toList();

    if (myPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined,
                size: 64,
                color: const Color(0xFF8B5CF6).withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài viết nào',
              style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showCreatePostDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tạo bài viết mới',
                    style: GoogleFonts.afacad(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Create post button at top
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            onPressed: _showCreatePostDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tạo bài viết mới',
                  style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...myPosts.map((post) => _postCard(post)).toList(),
      ],
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _searchPosts,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bài viết...',
              hintStyle: GoogleFonts.afacad(color: Colors.grey),
              prefixIcon:
                  const Icon(Icons.search, color: Color(0xFF8B5CF6)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: GoogleFonts.afacad(),
          ),
        ),
        if (filteredPosts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'Không tìm thấy bài viết nào',
                style: GoogleFonts.afacad(
                    fontSize: 14, color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) =>
                  _postCard(filteredPosts[index]),
            ),
          ),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
          _searchController.clear();
          filteredPosts = List.from(communityPosts);
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post) {
    final bool isShared = post['isShared'] == true;
    final Map<String, dynamic>? sharedPost = post['sharedPost'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(post['avatar'], style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  post['author'],
                                  style: GoogleFonts.afacad(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (post['isPrivate'])
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF5350).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Riêng tư',
                                    style: GoogleFonts.afacad(
                                      fontSize: 10,
                                      color: const Color(0xFFEF5350),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
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
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showPostMenu(post['id']),
                child: const Icon(Icons.more_horiz, color: Colors.grey),
              ),
            ],
          ),

          // If this is a shared post, show the original post in a container
          if (isShared && sharedPost != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original post header
                  Row(
                    children: [
                      Text(sharedPost['avatar'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sharedPost['author'],
                              style: GoogleFonts.afacad(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              sharedPost['time'],
                              style: GoogleFonts.afacad(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Original post content
                  if (sharedPost['title'].isNotEmpty)
                    Text(
                      sharedPost['title'],
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (sharedPost['title'].isNotEmpty) const SizedBox(height: 4),
                  Text(
                    sharedPost['content'],
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Original post image
                  if (sharedPost['image'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(sharedPost['image']),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            // Regular post content
            const SizedBox(height: 12),
            if (post['title'].isNotEmpty)
              Text(
                post['title'],
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (post['title'].isNotEmpty) const SizedBox(height: 8),
            Text(
              post['content'],
              style: GoogleFonts.afacad(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // Image if exists
            if (post['image'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(post['image']),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],

          const SizedBox(height: 12),

          // Footer - Interactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _toggleLike(post['id']),
                child: Row(
                  children: [
                    Icon(
                      post['liked'] ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: post['liked']
                          ? const Color(0xFFEF5350)
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post['liked'] ? 'Thích' : 'Thích',
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: post['liked']
                            ? const Color(0xFFEF5350)
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showCommentsSheet(post['id']),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Bình luận',
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _sharePost(post['id']),
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Chia sẻ',
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

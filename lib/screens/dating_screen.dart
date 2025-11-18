// lib/screens/dating_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/DatingService.dart';
import './dating_messages_screen.dart';

class DatingScreen extends StatefulWidget {
  const DatingScreen({super.key});

  @override
  State<DatingScreen> createState() => _DatingScreenState();
}

class _DatingScreenState extends State<DatingScreen>
    with SingleTickerProviderStateMixin {
  int currentCardIndex = 0;
  Offset cardPosition = Offset.zero;
  bool isCardSwiping = false;
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  // Sample pet profiles for dating
  final List<Map<String, dynamic>> petProfiles = [
    {
      'id': '1',
      'name': 'Mimi',
      'breed': 'Golden Retriever',
      'age': '2 năm',
      'gender': 'Cái',
      'location': 'Quận 1, TP.HCM',
      'image': 'lib/res/drawables/001-cat.png',
      'description': 'Mimi là chú chó vui vẻ, thích chơi và kết bạn',
      'interests': ['Chơi bóng', 'Chạy bộ', 'Bơi lội'],
      'matches': 12,
      'viewed': 45,
    },
    {
      'id': '2',
      'name': 'Max',
      'breed': 'Pug',
      'age': '3 năm',
      'gender': 'Đực',
      'location': 'Quận 3, TP.HCM',
      'image': 'lib/res/drawables/007-dog.png',
      'description': 'Max là chú chó thích yên tĩnh nhưng vui vẻ',
      'interests': ['Ngủ trưa', 'Ăn bánh', 'Thú vị'],
      'matches': 8,
      'viewed': 32,
    },
    {
      'id': '3',
      'name': 'Luna',
      'breed': 'Husky',
      'age': '1 năm',
      'gender': 'Cái',
      'location': 'Quận 7, TP.HCM',
      'image': 'lib/res/drawables/006-rabbit.png',
      'description': 'Luna là chú chó năng động, thích phiêu lưu',
      'interests': ['Chạy trong tuyết', 'Kéo xe', 'Đi bộ'],
      'matches': 15,
      'viewed': 58,
    },
    {
      'id': '4',
      'name': 'Buddy',
      'breed': 'Labrador',
      'age': '4 năm',
      'gender': 'Đực',
      'location': 'Quận 5, TP.HCM',
      'image': 'lib/res/drawables/008-parrot.png',
      'description': 'Buddy là chú chó thân thiện, tốt bụng',
      'interests': ['Gia đình', 'Trẻ em', 'Công viên'],
      'matches': 20,
      'viewed': 72,
    },
  ];

  // Sample chats for messaging
  final List<Map<String, dynamic>> chatConversations = [
    {
      'id': '1',
      'petName': 'Mimi',
      'ownerName': 'Hoa',
      'lastMessage': 'Chúc mừng! Mimi và Buddy rất hợp nhau',
      'timestamp': '2 phút trước',
      'unread': 2,
      'image': 'lib/res/drawables/setting/pet1.png',
    },
    {
      'id': '2',
      'petName': 'Max',
      'ownerName': 'Tuấn',
      'lastMessage': 'Bạn có muốn gặp gỡ vào cuối tuần không?',
      'timestamp': '1 giờ trước',
      'unread': 0,
      'image': 'lib/res/drawables/setting/pet2.png',
    },
  ];

  // Sample favorites
  final List<Map<String, dynamic>> favorites = [
    {
      'id': '1',
      'name': 'Mimi',
      'breed': 'Golden Retriever',
      'location': 'Quận 1, TP.HCM',
      'image': 'lib/res/drawables/001-cat.png',
    },
    {
      'id': '4',
      'name': 'Buddy',
      'breed': 'Labrador',
      'location': 'Quận 5, TP.HCM',
      'image': 'lib/res/drawables/008-parrot.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Text(
          'Hẹn hò',
          style: GoogleFonts.afacad(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8B5CF6),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF8B5CF6),
          tabs: [
            Tab(
              child: Text(
                'Khám phá',
                style: GoogleFonts.afacad(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Tin nhắn',
                style: GoogleFonts.afacad(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: _showPostPetDialog,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildMessagesTab(),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    if (currentCardIndex >= petProfiles.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 64,
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Không còn thú cưng nào',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quay lại sau để xem thêm thú cưng mới!',
              style: GoogleFonts.afacad(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentCardIndex = 0;
                  cardPosition = Offset.zero;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Khám phá lại',
                style: GoogleFonts.afacad(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final profile = petProfiles[currentCardIndex];

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
        ),
        // Main card with swipe gesture
        GestureDetector(
          onTap: () => _showDetailModal(profile),
          onPanUpdate: (details) {
            setState(() {
              cardPosition = Offset(
                cardPosition.dx + details.delta.dx,
                cardPosition.dy + details.delta.dy * 0.5,
              );
              isCardSwiping = true;
            });
          },
          onPanEnd: (details) {
            _handleSwipe(details.velocity.pixelsPerSecond.dx);
          },
          child: Center(
            child: Transform.translate(
              offset: cardPosition,
              child: Transform.rotate(
                angle: cardPosition.dx / 500,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Profile image
                          Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(profile['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // Swipe indicators
                          if (cardPosition.dx < -50)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.close,
                                        size: 60,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Không thích',
                                        style: GoogleFonts.afacad(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (cardPosition.dx > 50)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        size: 60,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yêu thích',
                                        style: GoogleFonts.afacad(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // Profile info at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.9),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${profile['name']}, ${profile['age']}',
                                    style: GoogleFonts.afacad(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${profile['breed']} · ${profile['location']}',
                                        style: GoogleFonts.afacad(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    profile['description'],
                                    style: GoogleFonts.afacad(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: (profile['interests']
                                            as List<String>)
                                        .map((interest) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                interest,
                                                style: GoogleFonts.afacad(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Tap to see details indicator
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSwipe(double velocity) {
    if (velocity > 500) {
      // Swipe right - Like
      _animateSwipe(1500);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❤️ Bạn thích ${petProfiles[currentCardIndex]['name']}!',
            style: GoogleFonts.afacad(),
          ),
          backgroundColor: const Color(0xFF8B5CF6),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    } else if (velocity < -500) {
      // Swipe left - Pass
      _animateSwipe(-1500);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '👋 Đã bỏ qua ${petProfiles[currentCardIndex]['name']}',
            style: GoogleFonts.afacad(),
          ),
          backgroundColor: const Color(0xFF9CA3AF),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    } else {
      // Return to center
      setState(() {
        cardPosition = Offset.zero;
      });
    }
  }

  void _animateSwipe(double targetX) {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        cardPosition = Offset(targetX, 0);
      });
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        currentCardIndex++;
        cardPosition = Offset.zero;
      });
    });
  }

  Widget _buildMessagesTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatingService.getUserConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = snapshot.data ?? [];

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 64,
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có cuộc trò chuyện',
                  style: GoogleFonts.afacad(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thích ai đó để bắt đầu nhắn tin!',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            return _buildConversationTile(conv);
          },
        );
      },
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    // Get other pet info (mocked for now - in real app would fetch from Firebase)
    final otherPetName = conversation['other_pet_id'] ?? 'Unknown';
    final lastMessage = conversation['last_message'] ?? 'Không có tin nhắn';
    final petIdStr = (conversation['other_pet_id'] ?? '').toString();
    final petIndex = int.tryParse(petIdStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final image = 'lib/res/drawables/setting/pet${((petIndex % 4) == 0 ? 4 : (petIndex % 4))}.png';

    return Material(
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(image),
        ),
        title: Text(
          otherPetName,
          style: GoogleFonts.afacad(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: const Color(0xFF22223B),
          ),
        ),
        subtitle: Text(
          lastMessage,
          style: GoogleFonts.afacad(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DatingMessagesScreen(
                conversationId: conversation['conversation_id'] ?? '',
                otherUserName: conversation['other_user_id'] ?? 'Unknown',
                otherPetName: otherPetName,
                otherPetImage: image,
                otherUserId: conversation['other_user_id'],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailModal(Map<String, dynamic> profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                const SizedBox(height: 20),
                Text(
                  '${profile['name']}, ${profile['age']}',
                  style: GoogleFonts.afacad(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profile['gender'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on,
                        size: 14, color: const Color(0xFF8B5CF6)),
                    const SizedBox(width: 4),
                    Text(
                      profile['location'],
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Về ${profile['name']}',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile['description'],
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sở thích',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['interests'] as List<String>)
                      .map((interest) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              interest,
                              style: GoogleFonts.afacad(
                                fontSize: 13,
                                color: const Color(0xFF8B5CF6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${profile['matches']}',
                          style: GoogleFonts.afacad(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ghép cặp',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${profile['viewed']}',
                          style: GoogleFonts.afacad(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lượt xem',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _animateSwipe(-1500);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.close),
                        label: Text(
                          'Không thích',
                          style: GoogleFonts.afacad(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Open chat with this pet
                          Navigator.pop(context);
                          _openChatWithPet(profile);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat_outlined),
                        label: Text(
                          'Nhắn tin',
                          style: GoogleFonts.afacad(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _animateSwipe(1500);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.favorite),
                        label: Text(
                          'Yêu thích',
                          style: GoogleFonts.afacad(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChatWithPet(Map<String, dynamic> profile) {
    // Create/open conversation with this pet
    final conversationId = 'conv_${profile['id']}';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatingMessagesScreen(
          conversationId: conversationId,
          otherUserName: 'Pet Owner',
          otherPetName: profile['name'],
          otherPetImage: profile['image'],
          otherUserId: profile['user_id'], // Extract user_id if available
        ),
      ),
    );
  }

  void _showPostPetDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController breedController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    String selectedGender = 'Đực';
    String? imagePath;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.67,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
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
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'Đăng thẻ thú cưng',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chia sẻ thông tin và ảnh thú cưng để tìm bạn!',
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Image picker
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          imagePath = pickedFile.path;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF8B5CF6).withOpacity(0.05),
                      ),
                      child: imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Color(0xFF8B5CF6),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Chọn ảnh thú cưng',
                                  style: GoogleFonts.afacad(
                                    color: const Color(0xFF8B5CF6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nhấn để tải ảnh từ thiết bị',
                                  style: GoogleFonts.afacad(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pet name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Tên thú cưng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.pets, color: Color(0xFF8B5CF6)),
                    ),
                    style: GoogleFonts.afacad(),
                  ),
                  const SizedBox(height: 12),
                  // Breed
                  TextField(
                    controller: breedController,
                    decoration: InputDecoration(
                      hintText: 'Giống loại (Golden Retriever, Pug, Husky...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.category, color: Color(0xFF8B5CF6)),
                    ),
                    style: GoogleFonts.afacad(),
                  ),
                  const SizedBox(height: 12),
                  // Age
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      hintText: 'Tuổi (vd: 2 năm, 6 tháng)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                    ),
                    style: GoogleFonts.afacad(),
                  ),
                  const SizedBox(height: 12),
                  // Gender
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.wc, color: Color(0xFF8B5CF6)),
                    ),
                    items: ['Đực', 'Cái']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender, style: GoogleFonts.afacad()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedGender = value ?? 'Đực');
                    },
                  ),
                  const SizedBox(height: 12),
                  // Location
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Địa chỉ (Quận 1, TP.HCM)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF8B5CF6)),
                    ),
                    style: GoogleFonts.afacad(),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Mô tả về thú cưng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.description, color: Color(0xFF8B5CF6)),
                    ),
                    maxLines: 3,
                    style: GoogleFonts.afacad(),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            nameController.dispose();
                            breedController.dispose();
                            descriptionController.dispose();
                            ageController.dispose();
                            locationController.dispose();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Huỷ',
                            style: GoogleFonts.afacad(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final breed = breedController.text.trim();
                            final age = ageController.text.trim();

                            if (name.isEmpty || breed.isEmpty || age.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Vui lòng điền đầy đủ thông tin',
                                    style: GoogleFonts.afacad(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (imagePath == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Vui lòng chọn ảnh thú cưng',
                                    style: GoogleFonts.afacad(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Thẻ của $name đã được đăng thành công!',
                                  style: GoogleFonts.afacad(),
                                ),
                                backgroundColor: const Color(0xFF8B5CF6),
                              ),
                            );
                            
                            nameController.dispose();
                            breedController.dispose();
                            descriptionController.dispose();
                            ageController.dispose();
                            locationController.dispose();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Đăng',
                            style: GoogleFonts.afacad(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

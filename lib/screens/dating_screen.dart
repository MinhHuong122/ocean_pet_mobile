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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatingService.getAllPetProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final petProfiles = snapshot.data ?? [];

        if (petProfiles.isEmpty || currentCardIndex >= petProfiles.length) {
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
                              // Profile image from Cloudinary
                              Container(
                                height: MediaQuery.of(context).size.height * 0.7,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(profile['image_url'] ?? ''),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // Fallback to asset if URL fails
                                    },
                                  ),
                                ),
                                child: (profile['image_url'] ?? '').isEmpty
                                    ? Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.pets, size: 64),
                                      )
                                    : null,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.close,
                                            size: 64,
                                            color: Colors.red.withOpacity(0.7),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Không thích',
                                            style: GoogleFonts.afacad(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Colors.red.withOpacity(0.7),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            size: 64,
                                            color: Colors.green.withOpacity(0.7),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Yêu thích',
                                            style: GoogleFonts.afacad(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green
                                                  .withOpacity(0.7),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${profile['pet_name']}, ${profile['age']}',
                                        style: GoogleFonts.afacad(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              profile['gender'] ?? 'N/A',
                                              style: GoogleFonts.afacad(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.white
                                                .withOpacity(0.7),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              profile['location'] ?? 'N/A',
                                              style: GoogleFonts.afacad(
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        profile['description'] ?? '',
                                        style: GoogleFonts.afacad(
                                          fontSize: 13,
                                          color: Colors.white
                                              .withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  void _handleSwipe(double velocity) {
    if (velocity > 500) {
      // Swipe right - Like
      _animateSwipe(1500);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❤️ Bạn thích thú cưng này!',
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
            '👋 Đã bỏ qua',
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
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.withOpacity(0.05),
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
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Chọn ảnh thú cưng',
                                  style: GoogleFonts.afacad(
                                    color: Colors.black,
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
                      hintStyle: GoogleFonts.afacad(color: const Color(0xFF9CA3AF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.pets, color: Colors.black),
                    ),
                    style: GoogleFonts.afacad(color: const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  // Breed
                  TextField(
                    controller: breedController,
                    decoration: InputDecoration(
                      hintText: 'Giống loại (Golden Retriever, Pug, Husky...)',
                      hintStyle: GoogleFonts.afacad(color: const Color(0xFF9CA3AF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.category, color: Colors.black),
                    ),
                    style: GoogleFonts.afacad(color: const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  // Age
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      hintText: 'Tuổi (vd: 2 năm, 6 tháng)',
                      hintStyle: GoogleFonts.afacad(color: const Color(0xFF9CA3AF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                    ),
                    style: GoogleFonts.afacad(color: const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  // Gender
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.wc, color: Colors.black),
                    ),
                    items: ['Đực', 'Cái']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender, style: GoogleFonts.afacad(color: const Color(0xFF6B7280))),
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
                      hintStyle: GoogleFonts.afacad(color: const Color(0xFF9CA3AF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.location_on, color: Colors.black),
                    ),
                    style: GoogleFonts.afacad(color: const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Mô tả về thú cưng',
                      hintStyle: GoogleFonts.afacad(color: const Color(0xFF9CA3AF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.description, color: Colors.black),
                    ),
                    maxLines: 3,
                    style: GoogleFonts.afacad(color: const Color(0xFF6B7280)),
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
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final breed = breedController.text.trim();
                            final age = ageController.text.trim();
                            final location = locationController.text.trim();
                            final description = descriptionController.text.trim();

                            if (name.isEmpty || breed.isEmpty || age.isEmpty || location.isEmpty) {
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

                            // Show loading dialog
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  content: Row(
                                    children: [
                                      const CircularProgressIndicator(
                                        color: Color(0xFF8B5CF6),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Đang tải lên...',
                                        style: GoogleFonts.afacad(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            try {
                              // Upload image to Cloudinary
                              final imageUrl = await DatingService.uploadImageToCloudinary(
                                filePath: imagePath!,
                                folder: 'ocean_pet/dating/profiles',
                              );

                              if (imageUrl == null) {
                                if (context.mounted) {
                                  Navigator.pop(context); // Close loading dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ Lỗi tải ảnh lên - kiểm tra Cloudinary setup',
                                        style: GoogleFonts.afacad(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              // Create pet profile in Firebase
                              await DatingService.createPetProfile(
                                petName: name,
                                breed: breed,
                                age: age,
                                gender: selectedGender,
                                location: location,
                                imageUrl: imageUrl,
                                description: description,
                                interests: [], // Can add interests picker later
                              );

                              if (context.mounted) {
                                Navigator.pop(context); // Close loading dialog
                                Navigator.pop(context); // Close post dialog
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Thẻ của $name đã được đăng thành công!',
                                      style: GoogleFonts.afacad(),
                                    ),
                                    backgroundColor: const Color(0xFF8B5CF6),
                                  ),
                                );
                              }

                              nameController.dispose();
                              breedController.dispose();
                              descriptionController.dispose();
                              ageController.dispose();
                              locationController.dispose();
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context); // Close loading dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Lỗi: $e',
                                      style: GoogleFonts.afacad(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
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

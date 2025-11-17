// lib/screens/dating_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/DatingService.dart';

class DatingMessagesScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherPetName;
  final String otherPetImage;
  final String? otherUserId; // Optional - for creating new conversations

  const DatingMessagesScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.otherPetName,
    required this.otherPetImage,
    this.otherUserId,
  });

  @override
  State<DatingMessagesScreen> createState() => _DatingMessagesScreenState();
}

class _DatingMessagesScreenState extends State<DatingMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    DatingService.sendTypingIndicator(
      conversationId: widget.conversationId,
      isTyping: false,
    );
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTyping() {
    if (!_isTyping) {
      setState(() => _isTyping = true);
      DatingService.sendTypingIndicator(
        conversationId: widget.conversationId,
        isTyping: true,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (_messageController.text.isEmpty && _isTyping) {
        setState(() => _isTyping = false);
        DatingService.sendTypingIndicator(
          conversationId: widget.conversationId,
          isTyping: false,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await DatingService.sendMessage(
        conversationId: widget.conversationId,
        message: text,
        messageType: 'text',
        otherUserId: widget.otherUserId,
      );
      _messageController.clear();
      setState(() => _isTyping = false);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi tin nhắn: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // TODO: Upload to Cloudinary and get URL
        // For now, show a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tính năng tải ảnh sắp có - sử dụng Cloudinary'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
  }

  void _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        // TODO: Upload to Cloudinary and get URL
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tính năng tải video sắp có - sử dụng Cloudinary'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn video: $e')),
      );
    }
  }

  void _shareLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quyền truy cập vị trí đã bị từ chối'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang lấy vị trí...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String locationName = 'Vị trí của tôi';
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        // Format address from placemark
        locationName = '${place.name ?? ''}, ${place.thoroughfare ?? ''}, ${place.subAdministrativeArea ?? ''}';
        locationName = locationName.replaceAll('null, ', '').replaceAll(', null', '').trim();
        if (locationName.isEmpty) {
          locationName = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      }

      // Send location message
      await DatingService.sendMessage(
        conversationId: widget.conversationId,
        message: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
        messageType: 'location',
        otherUserId: widget.otherUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Đã chia sẻ vị trí'),
            backgroundColor: Color(0xFF8B5CF6),
            duration: Duration(seconds: 1),
          ),
        );
      }
      
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chia sẻ vị trí: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(widget.otherPetImage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherPetName,
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  Text(
                    'của ${widget.otherUserName}',
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Thông tin'),
                  ],
                ),
                onTap: () {
                  // Show pet info
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.block, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Chặn', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () {
                  // Block user
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.report, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Báo cáo', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () {
                  // Report user
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: DatingService.getConversationMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hãy bắt đầu cuộc trò chuyện',
                          style: GoogleFonts.afacad(
                            fontSize: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isCurrentUser = msg['sender_id'] == DatingService.currentUserId;
                    final messageType = msg['message_type'] ?? 'text';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment:
                            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isCurrentUser) ...[
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: AssetImage(widget.otherPetImage),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: GestureDetector(
                              onLongPress: () {
                                _showMessageOptions(context, msg);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display different message types
                                    if (messageType == 'image' && msg['image_url'] != null)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(msg['image_url']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    if (messageType == 'video' && msg['video_thumbnail_url'] != null)
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            width: 200,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: NetworkImage(msg['video_thumbnail_url']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.4),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (messageType == 'location')
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                msg['location_name'] ?? 'Vị trí',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (messageType == 'audio')
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.play_circle_outline, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Tin nhắn thoại',
                                              style: GoogleFonts.afacad(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Text message
                                    if (msg['message'] != null && msg['message'].isNotEmpty)
                                      Text(
                                        msg['message'],
                                        style: GoogleFonts.afacad(
                                          fontSize: 13,
                                          color: isCurrentUser
                                              ? Colors.white
                                              : const Color(0xFF22223B),
                                        ),
                                      ),
                                    // Edited indicator
                                    if (msg['edited'] == true)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '(đã chỉnh sửa)',
                                          style: GoogleFonts.afacad(
                                            fontSize: 10,
                                            color: isCurrentUser
                                                ? Colors.white.withOpacity(0.7)
                                                : const Color(0xFF9CA3AF),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF8B5CF6),
                              child: Icon(
                                msg['read'] == true ? Icons.done_all : Icons.done,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Typing indicators
          StreamBuilder<List<String>>(
            stream: DatingService.getTypingIndicators(widget.conversationId),
            builder: (context, snapshot) {
              final typingUsers = snapshot.data ?? [];
              if (typingUsers.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'đang soạn tin nhắn...',
                  style: GoogleFonts.afacad(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            },
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Image button
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF8B5CF6),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Video button
                  GestureDetector(
                    onTap: _pickVideo,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: Color(0xFF8B5CF6),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Location button
                  GestureDetector(
                    onTap: _shareLocation,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF8B5CF6),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (_) => _onTyping(),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: GoogleFonts.afacad(
                          fontSize: 13,
                          color: const Color(0xFF9CA3AF),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      minLines: 1,
                      style: GoogleFonts.afacad(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, Map<String, dynamic> message) {
    final isCurrentUser = message['sender_id'] == DatingService.currentUserId;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentUser) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text('Chỉnh sửa', style: GoogleFonts.afacad()),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Xóa', style: GoogleFonts.afacad(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement delete
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.emoji_emotions_outlined),
              title: Text('Reaction', style: GoogleFonts.afacad()),
              onTap: () {
                Navigator.pop(context);
                _showEmojiPicker(context, message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text('Sao chép', style: GoogleFonts.afacad()),
              onTap: () {
                Navigator.pop(context);
                // Copy to clipboard
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context, Map<String, dynamic> message) {
    final emojis = ['❤️', '😂', '😮', '😢', '🔥', '👍', '👎'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn reaction', style: GoogleFonts.afacad()),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  DatingService.addReactionToMessage(
                    conversationId: widget.conversationId,
                    messageId: message['id'],
                    emoji: emojis[index],
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  emojis[index],
                  style: const TextStyle(fontSize: 32),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

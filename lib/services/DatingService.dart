import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service để quản lý tính năng hẹn hò thú cưng
/// Tối ưu hóa cho dating features: Profiles, Likes, Matches, Messaging
class DatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // ==================== PET DATING PROFILES ====================

  /// Tạo hồ sơ thú cưng cho dating
  /// Lưu trữ: /users/{uid}/dating_profiles/{petId}
  static Future<String> createPetProfile({
    required String petName,
    required String breed,
    required String age,
    required String gender,
    required String location,
    required String imageUrl,
    required String description,
    required List<String> interests,
    String? bio,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final profileId = _firestore.collection('users').doc(userId).collection('dating_profiles').doc().id;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('dating_profiles')
          .doc(profileId)
          .set({
        'id': profileId,
        'pet_name': petName,
        'breed': breed,
        'age': age,
        'gender': gender,
        'location': location,
        'image_url': imageUrl, // Cloudinary URL
        'description': description,
        'interests': interests,
        'bio': bio,
        'latitude': latitude,
        'longitude': longitude,
        'active': true,
        'view_count': 0,
        'like_count': 0,
        'match_count': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return profileId;
    } catch (e) {
      print('Error creating pet profile: $e');
      rethrow;
    }
  }

  /// Lấy hồ sơ thú cưng của user
  static Future<Map<String, dynamic>?> getPetProfile(
    String userId,
    String petId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dating_profiles')
          .doc(petId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting pet profile: $e');
      return null;
    }
  }

  /// Lấy danh sách profile dating của user (có thể có nhiều thú cưng)
  static Stream<List<Map<String, dynamic>>> getUserPetProfiles() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('dating_profiles')
        .where('active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy TẤT CẢ pet profiles từ tất cả users (cho dating discovery)
  static Stream<List<Map<String, dynamic>>> getAllPetProfiles() {
    return _firestore
        .collectionGroup('dating_profiles')
        .where('active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id': doc.id,
              'user_id': doc.reference.parent.parent?.id,
            };
          })
          .toList();
    });
  }

  /// Cập nhật profile dating
  static Future<void> updatePetProfile(
    String petId,
    Map<String, dynamic> data,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('dating_profiles')
          .doc(petId)
          .update(data);
    } catch (e) {
      print('Error updating pet profile: $e');
      rethrow;
    }
  }

  // ==================== LIKES & MATCHES ====================

  /// Thích một thú cưng (tạo match nếu cả 2 đều thích)
  /// Lưu trữ: /users/{uid}/likes/{targetPetId}
  static Future<void> likePetProfile({
    required String targetUserId,
    required String targetPetId,
    required String likerPetId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // Lưu like từ user này
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('likes')
          .doc(targetPetId)
          .set({
        'target_user_id': targetUserId,
        'target_pet_id': targetPetId,
        'liker_pet_id': likerPetId,
        'liked_at': FieldValue.serverTimestamp(),
      });

      // Cập nhật like count trên profile
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('dating_profiles')
          .doc(targetPetId)
          .update({
        'like_count': FieldValue.increment(1),
      });

      // Kiểm tra xem có match không (mutual like)
      final reverseCheck = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('likes')
          .doc(likerPetId)
          .get();

      if (reverseCheck.exists) {
        // Có match! Tạo conversation
        await _createMatch(
          userId: userId,
          userPetId: likerPetId,
          targetUserId: targetUserId,
          targetPetId: targetPetId,
        );
      }
    } catch (e) {
      print('Error liking pet profile: $e');
      rethrow;
    }
  }

  /// Bỏ thích một thú cưng
  static Future<void> unlikePetProfile({
    required String targetUserId,
    required String targetPetId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('likes')
          .doc(targetPetId)
          .delete();

      // Cập nhật like count
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('dating_profiles')
          .doc(targetPetId)
          .update({
        'like_count': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unliking pet profile: $e');
      rethrow;
    }
  }

  /// Kiểm tra đã thích profile này chưa
  static Future<bool> hasLikedProfile(String targetPetId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('likes')
          .doc(targetPetId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  /// Lấy danh sách likes của user
  static Stream<List<Map<String, dynamic>>> getUserLikes() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('likes')
        .orderBy('liked_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  // ==================== PRIVATE MATCH CREATION ====================

  /// Tạo match khi cả 2 đều thích nhau
  static Future<String> _createMatch({
    required String userId,
    required String userPetId,
    required String targetUserId,
    required String targetPetId,
  }) async {
    try {
      // Tạo match ID (sort để giống nhau ở cả 2 user)
      final ids = [userPetId, targetPetId];
      ids.sort();
      final matchId = '${ids[0]}_${ids[1]}';

      // Lưu match untuk cả 2 user
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('matches')
          .doc(matchId)
          .set({
        'match_id': matchId,
        'other_user_id': targetUserId,
        'other_pet_id': targetPetId,
        'user_pet_id': userPetId,
        'matched_at': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('matches')
          .doc(matchId)
          .set({
        'match_id': matchId,
        'other_user_id': userId,
        'other_pet_id': userPetId,
        'user_pet_id': targetPetId,
        'matched_at': FieldValue.serverTimestamp(),
      });

      // Tạo conversation stream
      await _createConversation(
        matchId: matchId,
        userId: userId,
        targetUserId: targetUserId,
      );

      return matchId;
    } catch (e) {
      print('Error creating match: $e');
      rethrow;
    }
  }

  /// Lấy danh sách matches của user
  static Stream<List<Map<String, dynamic>>> getUserMatches() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('matches')
        .orderBy('matched_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  // ==================== CONVERSATIONS & MESSAGING ====================

  /// Tạo conversation giữa 2 user sau khi match
  static Future<String> _createConversation({
    required String matchId,
    required String userId,
    required String targetUserId,
  }) async {
    try {
      final conversationId = matchId; // Dùng matchId làm conversationId

      // Lưu conversation collection (dùng cho real-time message streaming)
      await _firestore.collection('conversations').doc(conversationId).set({
        'conversation_id': conversationId,
        'participant_1': userId,
        'participant_2': targetUserId,
        'created_at': FieldValue.serverTimestamp(),
        'last_message': '',
        'last_message_timestamp': FieldValue.serverTimestamp(),
      });

      return conversationId;
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  /// Gửi message trong conversation (text, image, video, location, audio)
  /// Lưu trữ: /conversations/{conversationId}/messages/{messageId}
  /// Tự động tạo conversation nếu chưa tồn tại
  static Future<String> sendMessage({
    required String conversationId,
    required String message,
    String? imageUrl, // Cloudinary image URL (optional)
    String? videoUrl, // Cloudinary video URL (optional)
    String? videoThumbnailUrl, // Video thumbnail (optional)
    double? latitude, // Location latitude (optional)
    double? longitude, // Location longitude (optional)
    String? locationName, // Location name (optional)
    String messageType = 'text', // text, image, video, location, audio
    double? videoDuration, // Video duration in seconds
    String? otherUserId, // Required if creating new conversation
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // Kiểm tra xem conversation có tồn tại không
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      // Nếu conversation chưa tồn tại, tạo mới
      if (!conversationDoc.exists) {
        if (otherUserId == null) {
          throw Exception('otherUserId required to create new conversation');
        }
        
        await _firestore.collection('conversations').doc(conversationId).set({
          'conversation_id': conversationId,
          'participant_1': userId,
          'participant_2': otherUserId,
          'created_at': FieldValue.serverTimestamp(),
          'last_message': '',
          'last_message_timestamp': FieldValue.serverTimestamp(),
        });
      }

      final messageId =
          _firestore.collection('conversations').doc(conversationId).collection('messages').doc().id;

      // Lưu message
      final messageData = {
        'id': messageId,
        'sender_id': userId,
        'message': message,
        'message_type': messageType,
        'image_url': imageUrl,
        'video_url': videoUrl,
        'video_thumbnail_url': videoThumbnailUrl,
        'video_duration': videoDuration,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'edited': false,
      };

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set(messageData);

      // Update last message in conversation
      String displayMessage = message;
      if (messageType == 'image') displayMessage = '📷 Ảnh';
      if (messageType == 'video') displayMessage = '🎥 Video';
      if (messageType == 'location') displayMessage = '📍 Vị trí: $locationName';
      if (messageType == 'audio') displayMessage = '🎤 Tin nhắn thoại';

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'last_message': displayMessage,
        'last_message_timestamp': FieldValue.serverTimestamp(),
      });

      return messageId;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Lấy messages của conversation (real-time)
  static Stream<List<Map<String, dynamic>>> getConversationMessages(
    String conversationId,
  ) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy danh sách conversations của user (chats) - real-time sync
  /// Trả về conversations nơi user là participant_1 hoặc participant_2
  static Stream<List<Map<String, dynamic>>> getUserConversations() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    // Use a single collection-wide query instead of filtering in code
    // This is more efficient and real-time
    return _firestore
        .collection('conversations')
        .snapshots()
        .map((snapshot) {
      // Filter locally: conversations where user is participant_1 or participant_2
      final conversations = snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['participant_1'] == userId || data['participant_2'] == userId;
          })
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      // Sort by last_message_timestamp (newest first)
      conversations.sort((a, b) {
        final tsA = (a['last_message_timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final tsB = (b['last_message_timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return tsB.compareTo(tsA); // Descending
      });

      return conversations;
    });
  }

  /// Đánh dấu message đã đọc
  static Future<void> markMessageAsRead(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'read': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  /// Xóa conversation (soft delete)
  static Future<void> deleteConversation(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'deleted': true});
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }

  // ==================== PROFILE VIEWS ====================

  /// Record view của một profile
  static Future<void> recordProfileView({
    required String targetUserId,
    required String targetPetId,
    required String viewerPetId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      // Increment view count trên profile
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('dating_profiles')
          .doc(targetPetId)
          .update({
        'view_count': FieldValue.increment(1),
      });

      // Lưu view record (cho analytics)
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile_views')
          .add({
        'target_user_id': targetUserId,
        'target_pet_id': targetPetId,
        'viewer_pet_id': viewerPetId,
        'viewed_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording profile view: $e');
    }
  }

  // ==================== SEARCH & DISCOVERY ====================

  /// Tìm kiếm pet profiles (optimize with geo-queries)
  /// Lọc theo: location, breed, age, gender
  static Future<List<Map<String, dynamic>>> searchPetProfiles({
    String? breed,
    String? gender,
    String? ageRange,
    String? location,
    int limit = 20,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      Query query =
          _firestore.collectionGroup('dating_profiles').where('active', isEqualTo: true);

      // Exclude own profiles
      query = query.where('user_id', isNotEqualTo: userId);

      if (breed != null) {
        query = query.where('breed', isEqualTo: breed);
      }

      if (gender != null) {
        query = query.where('gender', isEqualTo: gender);
      }

      if (location != null) {
        query = query.where('location', isEqualTo: location);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          })
          .toList();
    } catch (e) {
      print('Error searching pet profiles: $e');
      return [];
    }
  }

  /// Lấy suggested profiles (random, chưa like hoặc viewed)
  static Future<List<Map<String, dynamic>>> getSuggestedProfiles({
    int limit = 10,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      // Get all active profiles (collectionGroup để query toàn bộ)
      final snapshot = await _firestore
          .collectionGroup('dating_profiles')
          .where('active', isEqualTo: true)
          .limit(limit * 3) // Get more để filter
          .get();

      final profiles = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();

      // Filter: remove own profiles và liked profiles
      final userLikes = await getUserLikes().first;
      final likedPetIds = userLikes.map((l) => l['target_pet_id']).toSet();

      final suggested = profiles
          .where((p) => p['user_id'] != userId && !likedPetIds.contains(p['id']))
          .take(limit)
          .toList();

      return suggested;
    } catch (e) {
      print('Error getting suggested profiles: $e');
      return [];
    }
  }

  // ==================== ADVANCED MESSAGING ====================

  /// Chỉnh sửa tin nhắn
  static Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newMessage,
  }) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
        'message': newMessage,
        'edited': true,
        'edited_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error editing message: $e');
      rethrow;
    }
  }

  /// Xóa tin nhắn (soft delete)
  static Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deleted': true,
        'message': '(Tin nhắn đã bị xóa)',
        'deleted_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  /// Gửi reaction/emoji cho tin nhắn
  static Future<void> addReactionToMessage({
    required String conversationId,
    required String messageId,
    required String emoji,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .doc(userId)
          .set({
        'emoji': emoji,
        'added_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding reaction: $e');
      rethrow;
    }
  }

  /// Lấy reactions cho tin nhắn (real-time)
  static Stream<List<Map<String, dynamic>>> getMessageReactions(
    String conversationId,
    String messageId,
  ) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .collection('reactions')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Tìm kiếm tin nhắn
  static Future<List<Map<String, dynamic>>> searchMessages({
    required String conversationId,
    required String searchTerm,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('message', isGreaterThanOrEqualTo: searchTerm)
          .where('message', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .orderBy('message')
          .get();

      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  /// Gửi typing indicator
  static Future<void> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      if (isTyping) {
        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('typing_indicators')
            .doc(userId)
            .set({
          'user_id': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('typing_indicators')
            .doc(userId)
            .delete();
      }
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  /// Lấy typing indicators (real-time)
  static Stream<List<String>> getTypingIndicators(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('typing_indicators')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['user_id'] as String).toList());
  }

  /// Block user
  static Future<void> blockUser({
    required String blockedUserId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .set({
        'blocked_user_id': blockedUserId,
        'blocked_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }

  /// Unblock user
  static Future<void> unblockUser({
    required String blockedUserId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .delete();
    } catch (e) {
      print('Error unblocking user: $e');
      rethrow;
    }
  }

  /// Lấy danh sách users đã block
  static Stream<List<String>> getBlockedUsers() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('blocked_users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['blocked_user_id'] as String).toList());
  }

  /// Report user/conversation
  static Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      await _firestore
          .collection('reports')
          .add({
        'reporter_id': userId,
        'reported_user_id': reportedUserId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'reported_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error reporting user: $e');
      rethrow;
    }
  }

  // ==================== CLOUDINARY INTEGRATION ====================

  static const String _cloudName = 'dssazeaz6';
  static const String _uploadPreset = 'ocean_pet';

  /// Upload ảnh đến Cloudinary
  static Future<String?> uploadImageToCloudinary({
    required String filePath,
    String folder = 'ocean_pet/dating',
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return jsonData['secure_url'] as String;
      } else {
        print('Cloudinary upload error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Upload video đến Cloudinary
  static Future<Map<String, String>?> uploadVideoToCloudinary({
    required String filePath,
    String folder = 'ocean_pet/dating',
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/video/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        
        return {
          'video_url': jsonData['secure_url'] as String,
          'thumbnail_url': jsonData['eager']?[0]['secure_url'] as String? ?? '',
          'duration': (jsonData['duration'] as num?)?.toString() ?? '0',
        };
      } else {
        print('Cloudinary video upload error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading video to Cloudinary: $e');
      return null;
    }
  }
}

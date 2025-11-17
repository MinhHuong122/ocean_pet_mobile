import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service quản lý tính năng cộng đồng
/// Hỗ trợ: Bài viết, bình luận, like, trending topics
class CommunityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // ==================== COMMUNITY POSTS ====================

  /// Tạo bài viết cộng đồng
  static Future<String> createPost({
    required String communityId,
    required String title,
    required String content,
    String? imageUrl, // Cloudinary URL
    List<String>? tags,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final postId = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc()
          .id;

      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .set({
        'id': postId,
        'user_id': userId,
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'tags': tags ?? [],
        'likes_count': 0,
        'comments_count': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return postId;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  /// Lấy bài viết của cộng đồng (real-time)
  static Stream<List<Map<String, dynamic>>> getCommunityPosts(
    String communityId,
  ) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Like bài viết
  static Future<void> likePost(
    String communityId,
    String postId,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .set({'liked_at': FieldValue.serverTimestamp()});

      // Update likes count
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .update({
        'likes_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error liking post: $e');
      rethrow;
    }
  }

  /// Unlike bài viết
  static Future<void> unlikePost(
    String communityId,
    String postId,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .delete();

      // Update likes count
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .update({
        'likes_count': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unliking post: $e');
      rethrow;
    }
  }

  /// Kiểm tra user đã like post này chưa
  static Future<bool> hasUserLikedPost(
    String communityId,
    String postId,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final doc = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking like: $e');
      return false;
    }
  }

  /// Thêm bình luận vào bài viết
  static Future<String> addComment(
    String communityId,
    String postId,
    String content,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final commentId = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc()
          .id;

      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
        'id': commentId,
        'user_id': userId,
        'content': content,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update comments count
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .update({
        'comments_count': FieldValue.increment(1),
      });

      return commentId;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  /// Lấy bình luận của bài viết (real-time)
  static Stream<List<Map<String, dynamic>>> getPostComments(
    String communityId,
    String postId,
  ) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Xóa bài viết
  static Future<void> deletePost(
    String communityId,
    String postId,
  ) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .delete();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  /// Lấy trending topics (real-time)
  static Stream<List<Map<String, dynamic>>> getTrendingTopics() {
    return _firestore
        .collection('trending_topics')
        .orderBy('post_count', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Cập nhật trending topic count
  static Future<void> updateTrendingTopic(String topic) async {
    try {
      final docId = topic.replaceAll('#', '').replaceAll(' ', '_');

      final doc = await _firestore.collection('trending_topics').doc(docId).get();

      if (doc.exists) {
        await _firestore.collection('trending_topics').doc(docId).update({
          'post_count': FieldValue.increment(1),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('trending_topics').doc(docId).set({
          'id': docId,
          'topic': topic,
          'post_count': 1,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating trending topic: $e');
    }
  }

  /// Tìm kiếm bài viết theo keyword
  static Future<List<Map<String, dynamic>>> searchPosts(
    String communityId,
    String keyword,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: keyword)
          .where('title', isLessThan: keyword + 'z')
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }

  /// Lấy tất cả communities
  static Future<List<Map<String, dynamic>>> getAllCommunities() async {
    try {
      final snapshot = await _firestore.collection('communities').get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error fetching communities: $e');
      return [];
    }
  }
}

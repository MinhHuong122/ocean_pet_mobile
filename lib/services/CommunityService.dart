import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  static const String _defaultCommunityId = 'general';

  // ==================== POST MANAGEMENT ====================

  /// Create a new community post with image support
  static Future<String> createPost({
    required String title,
    required String content,
    String? imageUrl,
    String communityId = _defaultCommunityId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final docRef = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .add({
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'created_by': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'likes_count': 0,
        'comments_count': 0,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  /// Get stream of community posts ordered by creation date
  static Stream<List<Map<String, dynamic>>> getCommunityPosts({
    String communityId = _defaultCommunityId,
  }) {
    try {
      return FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error getting posts: $e');
      return Stream.value([]);
    }
  }

  /// Delete a post (only by creator)
  static Future<void> deletePost(
    String postId, {
    String communityId = _defaultCommunityId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final doc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .get();

      if (doc.data()?['created_by'] != user.uid) {
        throw Exception('You can only delete your own posts');
      }

      await doc.reference.delete();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  // ==================== LIKE MANAGEMENT ====================

  /// Like a post with real-time counter update
  static Future<void> likePost(
    String postId, {
    String communityId = _defaultCommunityId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final db = FirebaseFirestore.instance;
      final postsRef = db
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId);

      await db.runTransaction((transaction) async {
        // Add like
        transaction.set(
          db
              .collection('communities')
              .doc(communityId)
              .collection('likes')
              .doc('${postId}_${user.uid}'),
          {
            'post_id': postId,
            'user_id': user.uid,
            'created_at': FieldValue.serverTimestamp(),
          },
        );

        // Increment counter
        transaction.update(postsRef, {
          'likes_count': FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('Error liking post: $e');
      rethrow;
    }
  }

  /// Unlike a post with real-time counter update
  static Future<void> unlikePost(
    String postId, {
    String communityId = _defaultCommunityId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final db = FirebaseFirestore.instance;
      final postsRef = db
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId);

      await db.runTransaction((transaction) async {
        // Remove like
        transaction.delete(
          db
              .collection('communities')
              .doc(communityId)
              .collection('likes')
              .doc('${postId}_${user.uid}'),
        );

        // Decrement counter
        transaction.update(postsRef, {
          'likes_count': FieldValue.increment(-1),
        });
      });
    } catch (e) {
      print('Error unliking post: $e');
      rethrow;
    }
  }

  // ==================== COMMENT MANAGEMENT ====================

  /// Add comment to a post
  static Future<String> addComment({
    required String postId,
    required String content,
    String communityId = _defaultCommunityId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final db = FirebaseFirestore.instance;
      final postRef = db
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId);

      final commentRef = await db.runTransaction((transaction) async {
        // Get and increment comment count
        final postData = await transaction.get(postRef);
        final currentCount = postData.data()?['comments_count'] ?? 0;

        transaction.update(postRef, {
          'comments_count': currentCount + 1,
        });

        // Add comment
        final newComment = db
            .collection('communities')
            .doc(communityId)
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc();

        transaction.set(newComment, {
          'content': content,
          'created_by': user.uid,
          'created_at': FieldValue.serverTimestamp(),
        });

        return newComment.id;
      });

      return commentRef;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  /// Get stream of comments for a post
  static Stream<List<Map<String, dynamic>>> getPostComments(
    String postId, {
    String communityId = _defaultCommunityId,
  }) {
    try {
      return FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('created_at', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error getting comments: $e');
      return Stream.value([]);
    }
  }

  // ==================== TRENDING & SEARCH ====================

  /// Get stream of trending topics
  static Stream<List<Map<String, dynamic>>> getTrendingTopics({
    String communityId = _defaultCommunityId,
  }) {
    try {
      return FirebaseFirestore.instance
          .collection('trending_topics')
          .where('community_id', isEqualTo: communityId)
          .orderBy('post_count', descending: true)
          .limit(10)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error getting trending topics: $e');
      return Stream.value([]);
    }
  }

  /// Search posts by keyword
  static Stream<List<Map<String, dynamic>>> searchPosts(
    String keyword, {
    String communityId = _defaultCommunityId,
  }) {
    try {
      if (keyword.isEmpty) {
        return getCommunityPosts(communityId: communityId);
      }

      return FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: keyword)
          .where('title', isLessThan: keyword + 'z')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error searching posts: $e');
      return Stream.value([]);
    }
  }
}

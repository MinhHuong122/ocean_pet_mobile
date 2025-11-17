import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service quản lý video huấn luyện
/// Hỗ trợ: Upload videos lên Cloudinary, ratings, trending videos
class TrainingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloudinary config
  static const String CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUDINARY_NAME'; // TODO: Replace
  static const String CLOUDINARY_API_KEY = 'YOUR_API_KEY'; // TODO: Replace
  static const String CLOUDINARY_UPLOAD_PRESET = 'pet_training'; // Set in Cloudinary

  static String? get currentUserId => _auth.currentUser?.uid;

  // ==================== TRAINING VIDEOS ====================

  /// Tạo video huấn luyện mới
  static Future<String> createTrainingVideo({
    required String title,
    required String description,
    required String videoUrl, // Cloudinary URL after upload
    required String thumbnailUrl, // Cloudinary thumbnail
    required String level, // Cơ bản, Trung cấp, Nâng cao
    required String category, // Huấn luyện chó, Huấn luyện mèo, etc.
    String? videoId, // YouTube video ID or Cloudinary ID
    double? duration, // Video duration in seconds
    List<String>? tags,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docId = _firestore.collection('training_videos').doc().id;

      await _firestore.collection('training_videos').doc(docId).set({
        'id': docId,
        'uploader_id': userId,
        'title': title,
        'description': description,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'video_id': videoId,
        'level': level,
        'category': category,
        'duration': duration,
        'tags': tags ?? [],
        'views_count': 0,
        'rating_count': 0,
        'total_rating': 0,
        'average_rating': 0.0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docId;
    } catch (e) {
      print('Error creating training video: $e');
      rethrow;
    }
  }

  /// Lấy tất cả training videos (real-time)
  static Stream<List<Map<String, dynamic>>> getAllTrainingVideos() {
    return _firestore
        .collection('training_videos')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy training videos theo level
  static Stream<List<Map<String, dynamic>>> getVideosByLevel(String level) {
    return _firestore
        .collection('training_videos')
        .where('level', isEqualTo: level)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy training videos theo category
  static Stream<List<Map<String, dynamic>>> getVideosByCategory(
    String category,
  ) {
    return _firestore
        .collection('training_videos')
        .where('category', isEqualTo: category)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy chi tiết video
  static Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    try {
      final doc = await _firestore.collection('training_videos').doc(videoId).get();

      if (doc.exists) {
        return {...doc.data(), 'id': doc.id};
      }
      return null;
    } catch (e) {
      print('Error fetching video details: $e');
      return null;
    }
  }

  /// Rating video
  static Future<void> rateVideo(
    String videoId,
    double rating, // 1-5 stars
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // Lưu rating của user
      await _firestore
          .collection('training_videos')
          .doc(videoId)
          .collection('ratings')
          .doc(userId)
          .set({
        'user_id': userId,
        'rating': rating,
        'rated_at': FieldValue.serverTimestamp(),
      });

      // Cập nhật thống kê video
      final videoDoc =
          await _firestore.collection('training_videos').doc(videoId).get();
      final currentData = videoDoc.data() as Map<String, dynamic>;
      final ratingCount = (currentData['rating_count'] ?? 0) as int;
      final totalRating = (currentData['total_rating'] ?? 0.0) as double;

      final newRatingCount = ratingCount + 1;
      final newTotalRating = totalRating + rating;
      final newAverageRating = newTotalRating / newRatingCount;

      await _firestore.collection('training_videos').doc(videoId).update({
        'rating_count': newRatingCount,
        'total_rating': newTotalRating,
        'average_rating': newAverageRating,
      });
    } catch (e) {
      print('Error rating video: $e');
      rethrow;
    }
  }

  /// Cập nhật rating của user cho video
  static Future<void> updateVideoRating(
    String videoId,
    double oldRating,
    double newRating,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // Cập nhật rating
      await _firestore
          .collection('training_videos')
          .doc(videoId)
          .collection('ratings')
          .doc(userId)
          .update({
        'rating': newRating,
        'rated_at': FieldValue.serverTimestamp(),
      });

      // Cập nhật thống kê
      final videoDoc =
          await _firestore.collection('training_videos').doc(videoId).get();
      final currentData = videoDoc.data() as Map<String, dynamic>;
      final ratingCount = (currentData['rating_count'] ?? 0) as int;
      final totalRating = (currentData['total_rating'] ?? 0.0) as double;

      final newTotalRating = totalRating - oldRating + newRating;
      final newAverageRating = newTotalRating / ratingCount;

      await _firestore.collection('training_videos').doc(videoId).update({
        'total_rating': newTotalRating,
        'average_rating': newAverageRating,
      });
    } catch (e) {
      print('Error updating rating: $e');
      rethrow;
    }
  }

  /// Lấy rating của user cho video (nếu có)
  static Future<double?> getUserVideoRating(String videoId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore
          .collection('training_videos')
          .doc(videoId)
          .collection('ratings')
          .doc(userId)
          .get();

      if (doc.exists) {
        return (doc.data()['rating'] as num?)?.toDouble();
      }
      return null;
    } catch (e) {
      print('Error fetching user rating: $e');
      return null;
    }
  }

  /// Tăng view count
  static Future<void> incrementViewCount(String videoId) async {
    try {
      await _firestore.collection('training_videos').doc(videoId).update({
        'views_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  /// Lấy videos trending (top rated)
  static Stream<List<Map<String, dynamic>>> getTrendingVideos({
    int limit = 10,
  }) {
    return _firestore
        .collection('training_videos')
        .orderBy('average_rating', descending: true)
        .orderBy('views_count', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy videos được xem nhiều nhất
  static Stream<List<Map<String, dynamic>>> getMostViewedVideos({
    int limit = 10,
  }) {
    return _firestore
        .collection('training_videos')
        .orderBy('views_count', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Tìm kiếm videos
  static Future<List<Map<String, dynamic>>> searchVideos(String keyword) async {
    try {
      final snapshot = await _firestore
          .collection('training_videos')
          .where('title', isGreaterThanOrEqualTo: keyword)
          .where('title', isLessThan: keyword + 'z')
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error searching videos: $e');
      return [];
    }
  }

  /// Xóa video
  static Future<void> deleteVideo(String videoId) async {
    try {
      await _firestore.collection('training_videos').doc(videoId).delete();
    } catch (e) {
      print('Error deleting video: $e');
      rethrow;
    }
  }

  /// Cập nhật video metadata
  static Future<void> updateVideo(
    String videoId, {
    String? title,
    String? description,
    String? level,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (level != null) updates['level'] = level;
      if (category != null) updates['category'] = category;
      if (tags != null) updates['tags'] = tags;
      updates['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('training_videos').doc(videoId).update(updates);
    } catch (e) {
      print('Error updating video: $e');
      rethrow;
    }
  }

  // ==================== CLOUDINARY HELPERS ====================

  /// Generate Cloudinary URL từ public ID
  /// Pattern: https://res.cloudinary.com/{cloud_name}/image/upload/{public_id}
  static String getCloudinaryUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    String url =
        'https://res.cloudinary.com/$CLOUDINARY_CLOUD_NAME/image/upload/';
    
    if (width != null || height != null) {
      url += 'c_scale';
      if (width != null) url += ',w_$width';
      if (height != null) url += ',h_$height';
      url += ',q_$quality/';
    }

    url += publicId;
    return url;
  }

  /// Generate Cloudinary thumbnail từ video ID
  static String getCloudinaryVideoThumbnail(String videoId) {
    return 'https://res.cloudinary.com/$CLOUDINARY_CLOUD_NAME/video/upload/w_300,h_200,c_fill/$videoId.jpg';
  }
}

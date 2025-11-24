import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainingService {
  // Cloudinary configuration - UPDATE WITH YOUR CREDENTIALS
  static const String CLOUDINARY_CLOUD_NAME = 'YOUR_CLOUD_NAME';
  static const String CLOUDINARY_API_KEY = 'YOUR_API_KEY';
  static const String CLOUDINARY_UPLOAD_PRESET = 'ocean_pet_unsigned';

  // ==================== VIDEO MANAGEMENT ====================

  /// Create a new training video
  static Future<String> createTrainingVideo({
    required String title,
    required String description,
    required String videoUrl,
    required String thumbnailUrl,
    required String level,
    required String category,
    List<String>? tags,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final docRef =
          await FirebaseFirestore.instance.collection('training_videos').add({
        'title': title,
        'description': description,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'level': level,
        'category': category,
        'tags': tags ?? [],
        'rating': 0.0,
        'rating_count': 0,
        'view_count': 0,
        'created_by': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating training video: $e');
      rethrow;
    }
  }

  // ==================== VIDEO RETRIEVAL & FILTERING ====================

  /// Get videos filtered by skill level
  static Stream<List<Map<String, dynamic>>> getVideosByLevel(String level) {
    try {
      return FirebaseFirestore.instance
          .collection('training_videos')
          .where('level', isEqualTo: level)
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
      print('Error getting videos by level: $e');
      return Stream.value([]);
    }
  }

  /// Get videos filtered by category (pet type)
  static Stream<List<Map<String, dynamic>>> getVideosByCategory(
    String category,
  ) {
    try {
      return FirebaseFirestore.instance
          .collection('training_videos')
          .where('category', isEqualTo: category)
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
      print('Error getting videos by category: $e');
      return Stream.value([]);
    }
  }

  /// Get trending videos (highest rated)
  static Stream<List<Map<String, dynamic>>> getTrendingVideos() {
    try {
      return FirebaseFirestore.instance
          .collection('training_videos')
          .orderBy('rating', descending: true)
          .orderBy('view_count', descending: true)
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
      print('Error getting trending videos: $e');
      return Stream.value([]);
    }
  }

  /// Get most viewed videos
  static Stream<List<Map<String, dynamic>>> getMostViewedVideos() {
    try {
      return FirebaseFirestore.instance
          .collection('training_videos')
          .orderBy('view_count', descending: true)
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
      print('Error getting most viewed videos: $e');
      return Stream.value([]);
    }
  }

  /// Search videos by keyword
  static Stream<List<Map<String, dynamic>>> searchVideos(String keyword) {
    try {
      if (keyword.isEmpty) {
        return FirebaseFirestore.instance
            .collection('training_videos')
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
      }

      return FirebaseFirestore.instance
          .collection('training_videos')
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
      print('Error searching videos: $e');
      return Stream.value([]);
    }
  }

  // ==================== RATING SYSTEM ====================

  /// Rate a video (1-5 stars) - Persisted in Firebase
  static Future<void> rateVideo(String videoId, int rating) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final db = FirebaseFirestore.instance;
      final videoRef = db.collection('training_videos').doc(videoId);

      await db.runTransaction((transaction) async {
        // Check if user already rated this video
        final existingRatingSnapshot = await db
            .collection('training_videos')
            .doc(videoId)
            .collection('ratings')
            .where('user_id', isEqualTo: user.uid)
            .get();

        if (existingRatingSnapshot.docs.isNotEmpty) {
          // Update existing rating
          final oldRating = existingRatingSnapshot.docs.first.data()['rating'];
          transaction.update(existingRatingSnapshot.docs.first.reference, {
            'rating': rating,
            'updated_at': FieldValue.serverTimestamp(),
          });

          await _updateVideoRating(transaction, videoRef, oldRating, rating);
        } else {
          // Create new rating
          transaction.set(
            db
                .collection('training_videos')
                .doc(videoId)
                .collection('ratings')
                .doc(user.uid),
            {
              'user_id': user.uid,
              'rating': rating,
              'created_at': FieldValue.serverTimestamp(),
            },
          );

          // Get current video data
          final videoData = await transaction.get(videoRef);
          final data = videoData.data();
          final currentRating = (data?['rating'] ?? 0.0).toDouble();
          final ratingCount = (data?['rating_count'] ?? 0) as int;

          // Calculate new average
          final newAverage =
              (currentRating * ratingCount + rating) / (ratingCount + 1);

          transaction.update(videoRef, {
            'rating': newAverage,
            'rating_count': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      print('Error rating video: $e');
      rethrow;
    }
  }

  /// Helper function to update rating in transaction
  static Future<void> _updateVideoRating(
    Transaction transaction,
    DocumentReference videoRef,
    int oldRating,
    int newRating,
  ) async {
    try {
      final videoData = await transaction.get(videoRef);
      final data = videoData.data() as Map<String, dynamic>?;
      final currentRating = (data?['rating'] ?? 0.0).toDouble();
      final ratingCount = (data?['rating_count'] ?? 0) as int;

      // Recalculate average: remove old, add new
      final newAverage = (currentRating * ratingCount - oldRating + newRating) /
          ratingCount; // Same count as before

      transaction.update(videoRef, {
        'rating': newAverage,
      });
    } catch (e) {
      print('Error updating rating: $e');
      rethrow;
    }
  }

  // ==================== VIEW TRACKING ====================

  /// Increment view count for a video - Persisted in Firebase
  static Future<void> incrementViewCount(String videoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('training_videos')
          .doc(videoId)
          .update({
        'view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
      rethrow;
    }
  }

  // ==================== CLOUDINARY INTEGRATION ====================

  /// Generate Cloudinary URL for a video
  static String getCloudinaryUrl(String publicId, {String quality = 'auto'}) {
    return 'https://res.cloudinary.com/$CLOUDINARY_CLOUD_NAME/video/upload/q_$quality,w_1280,h_720/v1/$publicId.mp4';
  }

  /// Generate Cloudinary thumbnail URL
  static String getCloudinaryVideoThumbnail(
    String publicId, {
    String quality = 'auto',
    int width = 320,
    int height = 180,
  }) {
    return 'https://res.cloudinary.com/$CLOUDINARY_CLOUD_NAME/video/upload/q_$quality,w_$width,h_$height,c_fill/v1/$publicId.jpg';
  }

  /// Upload video to Cloudinary using HTTP API
  static Future<Map<String, dynamic>> uploadVideoToCloudinary(
    String videoPath,
  ) async {
    try {
      // This would use http package to upload to Cloudinary
      // For now, returning placeholder
      return {
        'public_id': 'sample_video',
        'secure_url':
            'https://res.cloudinary.com/$CLOUDINARY_CLOUD_NAME/video/upload/v1/sample_video.mp4',
        'thumbnail_url': getCloudinaryVideoThumbnail('sample_video'),
      };
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      rethrow;
    }
  }
}

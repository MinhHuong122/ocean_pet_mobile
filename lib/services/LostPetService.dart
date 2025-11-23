import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service quản lý thú cưng thất lạc
class LostPetService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _currentUserId => _auth.currentUser?.uid;

  /// Đăng bài thú cưng thất lạc
  static Future<String> createLostPetPost({
    required String petName,
    required String petType, // 'dog', 'cat', 'bird', 'other'
    required String breed,
    required String color,
    required String distinguishingFeatures,
    required String imageUrl,
    required DateTime lostDate,
    required String lostLocation,
    required double latitude,
    required double longitude,
    String? additionalNotes,
    String? phoneNumber,
    String? rewardAmount,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docRef = await _firestore.collection('lost_pets').add({
        'user_id': userId,
        'pet_name': petName,
        'pet_type': petType,
        'breed': breed,
        'color': color,
        'distinguishing_features': distinguishingFeatures,
        'image_url': imageUrl,
        'lost_date': Timestamp.fromDate(lostDate),
        'lost_location': lostLocation,
        'latitude': latitude,
        'longitude': longitude,
        'additional_notes': additionalNotes,
        'phone_number': phoneNumber,
        'reward_amount': rewardAmount,
        'status': 'active', // active, found, closed
        'views': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating lost pet post: $e');
      rethrow;
    }
  }

  /// Lấy danh sách thú cưng thất lạc
  static Future<List<Map<String, dynamic>>> getLostPets({
    String? status,
    String? petType,
    String? sortBy, // 'recent', 'distance'
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      Query query = _firestore.collection('lost_pets');

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (petType != null) {
        query = query.where('pet_type', isEqualTo: petType);
      }

      if (sortBy == 'recent') {
        query = query.orderBy('created_at', descending: true);
      }

      final snapshot = await query.get();

      List<Map<String, dynamic>> lostPets = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        lostPets.add({...data, 'id': doc.id});
      }

      // Sắp xếp theo khoảng cách nếu có tọa độ người dùng
      if (sortBy == 'distance' && userLatitude != null && userLongitude != null) {
        lostPets.sort((a, b) {
          final distA = _calculateDistance(
            userLatitude,
            userLongitude,
            a['latitude'],
            a['longitude'],
          );
          final distB = _calculateDistance(
            userLatitude,
            userLongitude,
            b['latitude'],
            b['longitude'],
          );
          return distA.compareTo(distB);
        });
      }

      return lostPets;
    } catch (e) {
      print('Error getting lost pets: $e');
      return [];
    }
  }

  /// Lấy các bài đăng thất lạc của người dùng hiện tại
  static Future<List<Map<String, dynamic>>> getMyLostPets() async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final snapshot = await _firestore
          .collection('lost_pets')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting my lost pets: $e');
      return [];
    }
  }

  /// Cập nhật bài đăng thất lạc
  static Future<void> updateLostPetPost(
    String postId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('lost_pets').doc(postId).update(data);
    } catch (e) {
      print('Error updating lost pet post: $e');
      rethrow;
    }
  }

  /// Đánh dấu thú cưng đã được tìm thấy
  static Future<void> markAsFound(String postId) async {
    try {
      await updateLostPetPost(postId, {'status': 'found'});
    } catch (e) {
      print('Error marking pet as found: $e');
      rethrow;
    }
  }

  /// Đóng bài đăng thất lạc
  static Future<void> closeLostPetPost(String postId) async {
    try {
      await updateLostPetPost(postId, {'status': 'closed'});
    } catch (e) {
      print('Error closing lost pet post: $e');
      rethrow;
    }
  }

  /// Xóa bài đăng thất lạc
  static Future<void> deleteLostPetPost(String postId) async {
    try {
      await _firestore.collection('lost_pets').doc(postId).delete();
    } catch (e) {
      print('Error deleting lost pet post: $e');
      rethrow;
    }
  }

  /// Tăng lượt xem
  static Future<void> incrementViews(String postId) async {
    try {
      await _firestore.collection('lost_pets').doc(postId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  /// Stream để theo dõi bài đăng thất lạc gần đây
  static Stream<List<Map<String, dynamic>>> watchNearbyLostPets({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) {
    try {
      return _firestore
          .collection('lost_pets')
          .where('status', isEqualTo: 'active')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        final lostPets = snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();

        // Lọc theo khoảng cách
        return lostPets
            .where((pet) {
              final distance = _calculateDistance(
                latitude,
                longitude,
                pet['latitude'],
                pet['longitude'],
              );
              return distance <= radiusKm;
            })
            .toList();
      });
    } catch (e) {
      print('Error watching nearby lost pets: $e');
      return Stream.value([]);
    }
  }

  /// Tính khoảng cách giữa hai điểm (Haversine formula)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);

    final c = 2 * Math.asin(Math.sqrt(a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Đăng bài thú cưng tìm thấy
  static Future<String> createFoundPetPost({
    required String description,
    required String imageUrl,
    required DateTime foundDate,
    required String foundLocation,
    required double latitude,
    required double longitude,
    String? additionalNotes,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docRef = await _firestore.collection('found_pets').add({
        'user_id': userId,
        'description': description,
        'image_url': imageUrl,
        'found_date': Timestamp.fromDate(foundDate),
        'found_location': foundLocation,
        'latitude': latitude,
        'longitude': longitude,
        'additional_notes': additionalNotes,
        'status': 'active', // active, claimed, closed
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating found pet post: $e');
      rethrow;
    }
  }

  /// Lấy danh sách thú cưng tìm thấy
  static Future<List<Map<String, dynamic>>> getFoundPets({
    String? status,
  }) async {
    try {
      Query query = _firestore.collection('found_pets');

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot =
          await query.orderBy('created_at', descending: true).get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting found pets: $e');
      return [];
    }
  }
}

// Lớp Math tối giản cho các phép toán
class Math {
  static double sin(double x) => _sin(x);
  static double cos(double x) => _cos(x);
  static double sqrt(double x) {
    if (x < 0) return 0;
    double g0 = x;
    double g1 = x / 2;
    while ((g0 - g1).abs() > 0.0001) {
      g0 = g1;
      g1 = (g1 + x / g1) / 2;
    }
    return g1;
  }

  static double asin(double x) {
    const pi = 3.14159265359;
    return pi / 2 - _acos(x);
  }

  static double _acos(double x) {
    const pi = 3.14159265359;
    if (x == 1) return 0;
    if (x == -1) return pi;
    double g0 = pi / 2;
    double g1 = 1;
    while ((g0 - g1).abs() > 0.0001) {
      g0 = g1;
      g1 = asin(_sin(g0) * x);
    }
    return g1;
  }

  static double _sin(double x) {
    const pi = 3.14159265359;
    x = x % (2 * pi);
    double sum = x;
    double term = x;
    for (int n = 1; n < 20; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      sum += term;
    }
    return sum;
  }

  static double _cos(double x) {
    const pi = 3.14159265359;
    x = x % (2 * pi);
    double sum = 1;
    double term = 1;
    for (int n = 1; n < 20; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      sum += term;
    }
    return sum;
  }
}

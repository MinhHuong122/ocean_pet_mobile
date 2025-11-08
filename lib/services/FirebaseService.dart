import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'CloudinaryService.dart';

/// Service để tương tác với Firebase Firestore
/// Image storage: Sử dụng Cloudinary thay vì Firebase Storage
class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USERS ====================

  /// Tạo hoặc cập nhật thông tin user trong Firestore
  static Future<void> createOrUpdateUser({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
    String provider = 'email',
    String? providerId,
    bool isVerified = false,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'provider': provider,
        'provider_id': providerId,
        'is_verified': isVerified,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user: $e');
      rethrow;
    }
  }

  /// Lấy thông tin user
  static Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Cập nhật thông tin user
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // ==================== PETS ====================

  /// Thêm thú cưng mới
  static Future<String> addPet({
    required String name,
    required String type,
    String? breed,
    int? age,
    double? weight,
    String gender = 'unknown',
    String? avatarUrl,
    String? notes,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docRef = await _firestore.collection('pets').add({
        'user_id': userId,
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'weight': weight,
        'gender': gender,
        'avatar_url': avatarUrl,
        'notes': notes,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding pet: $e');
      rethrow;
    }
  }

  /// Lấy danh sách thú cưng của user
  static Stream<List<Map<String, dynamic>>> getUserPets() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('pets')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Cập nhật thông tin thú cưng
  static Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('pets').doc(petId).update(data);
    } catch (e) {
      print('Error updating pet: $e');
      rethrow;
    }
  }

  /// Xóa thú cưng
  static Future<void> deletePet(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
    } catch (e) {
      print('Error deleting pet: $e');
      rethrow;
    }
  }

  // ==================== FOLDERS ====================

  /// Thêm thư mục (folder)
  static Future<String> addFolder({
    required String name,
    String? icon,
    String? color,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docRef = await _firestore.collection('folders').add({
        'user_id': userId,
        'name': name,
        'icon': icon,
        'color': color,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding folder: $e');
      rethrow;
    }
  }

  /// Lấy danh sách folders của user
  static Stream<List<Map<String, dynamic>>> getUserFolders() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('folders')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Xóa folder
  static Future<void> deleteFolder(String folderId) async {
    try {
      await _firestore.collection('folders').doc(folderId).delete();
    } catch (e) {
      print('Error deleting folder: $e');
      rethrow;
    }
  }

  // ==================== DIARY ENTRIES ====================

  /// Thêm nhật ký mới
  static Future<String> addDiaryEntry({
    required String title,
    String? description,
    required String category,
    required String entryDate,
    required String entryTime,
    String? folderId,
    String? bgColor,
    bool hasPassword = false,
    String? password,
    List<String>? images,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docRef = await _firestore.collection('diary_entries').add({
        'user_id': userId,
        'folder_id': folderId,
        'title': title,
        'description': description,
        'category': category,
        'entry_date': entryDate,
        'entry_time': entryTime,
        'bg_color': bgColor,
        'has_password': hasPassword,
        'password': password,
        'images': images ?? [],
        'is_deleted': false,
        'deleted_at': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding diary entry: $e');
      rethrow;
    }
  }

  /// Lấy danh sách nhật ký (không bao gồm đã xóa)
  static Stream<List<Map<String, dynamic>>> getUserDiaryEntries({
    String? folderId,
    String? category,
  }) {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    Query query = _firestore
        .collection('diary_entries')
        .where('user_id', isEqualTo: userId)
        .where('is_deleted', isEqualTo: false);

    if (folderId != null) {
      query = query.where('folder_id', isEqualTo: folderId);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.orderBy('entry_date', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      },
    );
  }

  /// Lấy nhật ký đã xóa (thùng rác)
  static Stream<List<Map<String, dynamic>>> getTrashedDiaryEntries() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('diary_entries')
        .where('user_id', isEqualTo: userId)
        .where('is_deleted', isEqualTo: true)
        .orderBy('deleted_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Cập nhật nhật ký
  static Future<void> updateDiaryEntry(
      String entryId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('diary_entries').doc(entryId).update(data);
    } catch (e) {
      print('Error updating diary entry: $e');
      rethrow;
    }
  }

  /// Chuyển nhật ký vào thùng rác (soft delete)
  static Future<void> moveDiaryEntryToTrash(String entryId) async {
    try {
      await _firestore.collection('diary_entries').doc(entryId).update({
        'is_deleted': true,
        'deleted_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error moving diary entry to trash: $e');
      rethrow;
    }
  }

  /// Khôi phục nhật ký từ thùng rác
  static Future<void> restoreDiaryEntry(String entryId) async {
    try {
      await _firestore.collection('diary_entries').doc(entryId).update({
        'is_deleted': false,
        'deleted_at': null,
      });
    } catch (e) {
      print('Error restoring diary entry: $e');
      rethrow;
    }
  }

  /// Xóa vĩnh viễn nhật ký
  static Future<void> deleteDiaryEntryPermanently(String entryId) async {
    try {
      await _firestore.collection('diary_entries').doc(entryId).delete();
    } catch (e) {
      print('Error deleting diary entry permanently: $e');
      rethrow;
    }
  }

  // ==================== APPOINTMENTS ====================

  /// Thêm lịch hẹn
  static Future<String> addAppointment({
    required String title,
    String? description,
    required String appointmentDate,
    required String appointmentTime,
    String? petId,
    String? location,
    required String serviceType,
    String status = 'pending',
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docRef = await _firestore.collection('appointments').add({
        'user_id': userId,
        'pet_id': petId,
        'title': title,
        'description': description,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'location': location,
        'service_type': serviceType,
        'status': status,
        'reminder_sent': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding appointment: $e');
      rethrow;
    }
  }

  /// Lấy danh sách lịch hẹn
  static Stream<List<Map<String, dynamic>>> getUserAppointments() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('appointments')
        .where('user_id', isEqualTo: userId)
        .orderBy('appointment_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Cập nhật lịch hẹn
  static Future<void> updateAppointment(
      String appointmentId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('appointments').doc(appointmentId).update(data);
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  /// Xóa lịch hẹn
  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  // ==================== CLOUDINARY IMAGE STORAGE ====================

  /// Upload ảnh lên Cloudinary (thay thế Firebase Storage)
  static Future<String> uploadImage(File imageFile, String folder) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // Upload to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(
        imageFile,
        '$folder/$userId',
      );

      return imageUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      rethrow;
    }
  }

  /// Xóa ảnh từ Cloudinary
  static Future<void> deleteImage(String imageUrl) async {
    try {
      await CloudinaryService.deleteImage(imageUrl);
    } catch (e) {
      print('Error deleting image from Cloudinary: $e');
      // Không throw error vì ảnh có thể đã bị xóa
    }
  }

  // ==================== HEALTH RECORDS ====================

  /// Thêm hồ sơ sức khỏe
  static Future<String> addHealthRecord({
    required String petId,
    required String recordType,
    required String title,
    String? description,
    String? veterinarian,
    String? clinic,
    required String recordDate,
    String? nextAppointmentDate,
    String? notes,
  }) async {
    try {
      final docRef = await _firestore.collection('health_records').add({
        'pet_id': petId,
        'record_type': recordType,
        'title': title,
        'description': description,
        'veterinarian': veterinarian,
        'clinic': clinic,
        'record_date': recordDate,
        'next_appointment_date': nextAppointmentDate,
        'notes': notes,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding health record: $e');
      rethrow;
    }
  }

  /// Lấy hồ sơ sức khỏe của thú cưng
  static Stream<List<Map<String, dynamic>>> getPetHealthRecords(String petId) {
    return _firestore
        .collection('health_records')
        .where('pet_id', isEqualTo: petId)
        .orderBy('record_date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ==================== FEEDING SCHEDULE ====================

  /// Thêm lịch cho ăn
  static Future<String> addFeedingSchedule({
    required String petId,
    required String mealTime,
    String? foodType,
    String? quantity,
    String? notes,
    bool isActive = true,
  }) async {
    try {
      final docRef = await _firestore.collection('feeding_schedule').add({
        'pet_id': petId,
        'meal_time': mealTime,
        'food_type': foodType,
        'quantity': quantity,
        'notes': notes,
        'is_active': isActive,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding feeding schedule: $e');
      rethrow;
    }
  }

  /// Lấy lịch cho ăn của thú cưng
  static Stream<List<Map<String, dynamic>>> getPetFeedingSchedule(
      String petId) {
    return _firestore
        .collection('feeding_schedule')
        .where('pet_id', isEqualTo: petId)
        .where('is_active', isEqualTo: true)
        .orderBy('meal_time', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ==================== NOTIFICATIONS ====================

  /// Thêm thông báo
  static Future<String> addNotification({
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final docRef = await _firestore.collection('notifications').add({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'related_id': relatedId,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding notification: $e');
      rethrow;
    }
  }

  /// Lấy thông báo của user
  static Stream<List<Map<String, dynamic>>> getUserNotifications() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Đánh dấu thông báo đã đọc
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }
}

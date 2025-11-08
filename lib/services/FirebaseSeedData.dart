import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Helper class để seed dữ liệu mẫu vào Firestore
/// Chỉ dùng cho development/testing
class FirebaseSeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Seed all sample data
  static Future<void> seedAll() async {
    try {
      print('🌱 Bắt đầu seed dữ liệu mẫu...');
      
      // 1. Seed users (từ current user)
      await seedCurrentUser();
      
      // 2. Seed folders
      await seedFolders();
      
      // 3. Seed pets
      await seedPets();
      
      // 4. Seed diary entries
      await seedDiaryEntries();
      
      // 5. Seed appointments
      await seedAppointments();
      
      print('✅ Seed dữ liệu thành công!');
    } catch (e) {
      print('❌ Lỗi seed dữ liệu: $e');
      rethrow;
    }
  }

  /// Seed current user profile
  static Future<void> seedCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ Chưa đăng nhập. Skip seed user.');
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? 'User Test',
      'email': user.email ?? 'test@example.com',
      'avatar_url': user.photoURL ?? '',
      'provider': 'email',
      'provider_id': '',
      'is_verified': user.emailVerified,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('✅ Seed user: ${user.email}');
  }

  /// Seed folders
  static Future<void> seedFolders() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final folders = [
      {
        'user_id': userId,
        'name': 'Thú cưng của tôi',
        'icon': '🐾',
        'color': '#FF6B6B',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'user_id': userId,
        'name': 'Hoạt động hàng ngày',
        'icon': '📅',
        'color': '#4ECDC4',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'user_id': userId,
        'name': 'Kỷ niệm đặc biệt',
        'icon': '⭐',
        'color': '#FFE66D',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (var folder in folders) {
      await _firestore.collection('folders').add(folder);
    }

    print('✅ Seed ${folders.length} folders');
  }

  /// Seed pets
  static Future<void> seedPets() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final pets = [
      {
        'user_id': userId,
        'name': 'Mochi',
        'type': 'Chó',
        'breed': 'Poodle',
        'age': 24, // 2 tuổi = 24 tháng
        'weight': 5.5,
        'gender': 'female',
        'avatar_url': '',
        'notes': 'Mochi rất ngoan và thích chơi đùa',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'user_id': userId,
        'name': 'Lucky',
        'type': 'Mèo',
        'breed': 'Mèo Anh lông ngắn',
        'age': 18, // 1.5 tuổi
        'weight': 4.2,
        'gender': 'male',
        'avatar_url': '',
        'notes': 'Lucky thích ngủ và ăn cá',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'user_id': userId,
        'name': 'Buddy',
        'type': 'Chó',
        'breed': 'Golden Retriever',
        'age': 36, // 3 tuổi
        'weight': 28.5,
        'gender': 'male',
        'avatar_url': '',
        'notes': 'Buddy rất năng động và thích đi dạo',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (var pet in pets) {
      await _firestore.collection('pets').add(pet);
    }

    print('✅ Seed ${pets.length} pets');
  }

  /// Seed diary entries
  static Future<void> seedDiaryEntries() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Get first folder
    final foldersSnapshot = await _firestore
        .collection('folders')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    String? folderId = foldersSnapshot.docs.isNotEmpty 
        ? foldersSnapshot.docs.first.id 
        : null;

    final now = DateTime.now();
    final entries = [
      {
        'user_id': userId,
        'folder_id': folderId,
        'title': 'Mochi ăn sáng',
        'description': 'Mochi ăn 100g thức ăn khô và uống nhiều nước',
        'category': 'Ăn uống',
        'entry_date': now.toIso8601String().split('T')[0],
        'entry_time': '08:00:00',
        'bg_color': '#FFE5E5',
        'has_password': false,
        'password': null,
        'images': [],
        'is_deleted': false,
        'deleted_at': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'user_id': userId,
        'folder_id': folderId,
        'title': 'Đi dạo công viên',
        'description': 'Dắt Buddy đi dạo 30 phút ở công viên. Buddy rất vui!',
        'category': 'Vui chơi',
        'entry_date': now.toIso8601String().split('T')[0],
        'entry_time': '17:30:00',
        'bg_color': '#E5F5FF',
        'has_password': false,
        'password': null,
        'images': [],
        'is_deleted': false,
        'deleted_at': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'user_id': userId,
        'folder_id': folderId,
        'title': 'Tắm rửa cho Lucky',
        'description': 'Lucky không thích tắm lắm nhưng sau khi tắm rất thơm',
        'category': 'Tắm rửa',
        'entry_date': now.subtract(Duration(days: 1)).toIso8601String().split('T')[0],
        'entry_time': '14:00:00',
        'bg_color': '#FFF5E5',
        'has_password': false,
        'password': null,
        'images': [],
        'is_deleted': false,
        'deleted_at': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (var entry in entries) {
      await _firestore.collection('diary_entries').add(entry);
    }

    print('✅ Seed ${entries.length} diary entries');
  }

  /// Seed appointments
  static Future<void> seedAppointments() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Get first pet
    final petsSnapshot = await _firestore
        .collection('pets')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    String? petId = petsSnapshot.docs.isNotEmpty 
        ? petsSnapshot.docs.first.id 
        : null;

    final tomorrow = DateTime.now().add(Duration(days: 1));
    final nextWeek = DateTime.now().add(Duration(days: 7));

    final appointments = [
      {
        'user_id': userId,
        'pet_id': petId,
        'title': 'Khám sức khỏe định kỳ',
        'description': 'Khám sức khỏe tổng quát cho Mochi',
        'appointment_date': tomorrow.toIso8601String().split('T')[0],
        'appointment_time': '10:00:00',
        'location': 'Phòng khám thú y PetCare - 123 Nguyễn Huệ, Q1',
        'service_type': 'Khám sức khỏe',
        'status': 'pending',
        'reminder_sent': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      {
        'user_id': userId,
        'pet_id': petId,
        'title': 'Tiêm phòng dại',
        'description': 'Tiêm phòng dại định kỳ cho Buddy',
        'appointment_date': nextWeek.toIso8601String().split('T')[0],
        'appointment_time': '15:30:00',
        'location': 'Bệnh viện thú y Sài Gòn - 456 Lê Lợi, Q1',
        'service_type': 'Tiêm phòng',
        'status': 'confirmed',
        'reminder_sent': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    ];

    for (var appointment in appointments) {
      await _firestore.collection('appointments').add(appointment);
    }

    print('✅ Seed ${appointments.length} appointments');
  }

  /// Clear all data (careful!)
  static Future<void> clearAllData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    print('🗑️ Xóa tất cả dữ liệu...');

    // Delete user's data only
    final collections = [
      'folders',
      'pets',
      'diary_entries',
      'appointments',
      'health_records',
      'feeding_schedule',
      'notifications',
    ];

    for (var collection in collections) {
      final snapshot = await _firestore
          .collection(collection)
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ Xóa ${snapshot.docs.length} documents từ $collection');
    }

    print('✅ Xóa dữ liệu hoàn tất!');
  }

  /// Seed specific collection
  static Future<void> seedCollection(String collectionName) async {
    switch (collectionName) {
      case 'users':
        await seedCurrentUser();
        break;
      case 'folders':
        await seedFolders();
        break;
      case 'pets':
        await seedPets();
        break;
      case 'diary_entries':
        await seedDiaryEntries();
        break;
      case 'appointments':
        await seedAppointments();
        break;
      default:
        print('⚠️ Collection $collectionName chưa có seed data');
    }
  }
}

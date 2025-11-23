import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service quản lý thông tin cá nhân người dùng
class UserProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _currentUserId => _auth.currentUser?.uid;

  /// Lấy thông tin cá nhân người dùng
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Cập nhật thông tin cá nhân
  static Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? bio,
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
    String? city,
    String? district,
    String? ward,
  }) async {
    try {
      final userId = _currentUserId;
      print('📍 [UserProfileService] userId: $userId');
      if (userId == null) throw Exception('User not logged in');

      final data = <String, dynamic>{};

      if (name != null && name.isNotEmpty) data['name'] = name;
      if (phoneNumber != null && phoneNumber.isNotEmpty) data['phone_number'] = phoneNumber;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (bio != null && bio.isNotEmpty) data['bio'] = bio;
      if (avatarUrl != null && avatarUrl.isNotEmpty) data['avatar_url'] = avatarUrl;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (dateOfBirth != null) data['date_of_birth'] = Timestamp.fromDate(dateOfBirth);
      if (city != null && city.isNotEmpty) data['city'] = city;
      if (district != null && district.isNotEmpty) data['district'] = district;
      if (ward != null && ward.isNotEmpty) data['ward'] = ward;

      data['updated_at'] = FieldValue.serverTimestamp();

      print('📤 [UserProfileService] Sending data: $data');
      print('📍 [UserProfileService] Firestore path: users/$userId');
      
      await _firestore.collection('users').doc(userId).update(data);
      
      print('✅ [UserProfileService] Update successful!');
    } catch (e) {
      print('❌ [UserProfileService] Error updating user profile: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Cập nhật email
  static Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await user.verifyBeforeUpdateEmail(newEmail);
      
      // Cập nhật email trong Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }

  /// Cập nhật mật khẩu
  static Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  /// Xóa tài khoản
  static Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Xóa dữ liệu người dùng từ Firestore trước
      await _firestore.collection('users').doc(user.uid).delete();

      // Sau đó xóa tài khoản
      await user.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  /// Stream để theo dõi thay đổi thông tin cá nhân
  static Stream<Map<String, dynamic>?> watchUserProfile() {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      return _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
        }
        return null;
      });
    } catch (e) {
      print('Error watching user profile: $e');
      return Stream.value(null);
    }
  }

  /// Lấy thông tin công khai của một người dùng (cho trang profile của người khác)
  static Future<Map<String, dynamic>?> getPublicProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Chỉ trả về thông tin công khai
        return {
          'id': doc.id,
          'name': data['name'],
          'avatar_url': data['avatar_url'],
          'bio': data['bio'],
          'city': data['city'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting public profile: $e');
      return null;
    }
  }

  /// Kiểm tra xem email đã tồn tại
  static Future<bool> isEmailExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  /// Tìm kiếm người dùng theo tên
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id
              })
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }
}

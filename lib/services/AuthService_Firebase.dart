import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FirebaseService.dart';

/// Service xử lý Authentication sử dụng Firebase Authentication
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ==================== STATE MANAGEMENT ====================

  /// Lưu trạng thái đăng nhập
  static Future<void> saveLoginState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setBool('is_logged_in', true);
  }

  /// Kiểm tra trạng thái đăng nhập
  static Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    if (user != null) {
      await saveLoginState(user.uid);
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Lấy user ID
  static Future<String?> getUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Lấy Firebase User hiện tại
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream theo dõi trạng thái authentication
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== USER INFO ====================

  /// Lấy thông tin user từ Firestore
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập',
        };
      }

      final userData = await FirebaseService.getUser(user.uid);
      if (userData != null) {
        return {
          'success': true,
          'user': userData,
        };
      } else {
        // Nếu chưa có trong Firestore, tạo mới từ Firebase Auth
        await _createUserProfile(user);
        final newUserData = await FirebaseService.getUser(user.uid);
        return {
          'success': true,
          'user': newUserData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi lấy thông tin: $e',
      };
    }
  }

  /// Cập nhật thông tin user
  static Future<Map<String, dynamic>> updateUserInfo(
      String name, String? avatarUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập',
        };
      }

      // Cập nhật Firebase Auth profile
      await user.updateDisplayName(name);
      if (avatarUrl != null) {
        await user.updatePhotoURL(avatarUrl);
      }

      // Cập nhật Firestore
      await FirebaseService.updateUser(user.uid, {
        'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });

      return {
        'success': true,
        'message': 'Cập nhật thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi cập nhật: $e',
      };
    }
  }

  /// Tạo profile user trong Firestore
  static Future<void> _createUserProfile(User user) async {
    await FirebaseService.createOrUpdateUser(
      uid: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
      provider: _getProvider(user),
      providerId: user.providerData.isNotEmpty
          ? user.providerData.first.uid
          : null,
      isVerified: user.emailVerified,
    );
  }

  /// Lấy provider từ Firebase User
  static String _getProvider(User user) {
    if (user.providerData.isEmpty) return 'email';
    final providerId = user.providerData.first.providerId;
    if (providerId.contains('google')) return 'google';
    if (providerId.contains('facebook')) return 'facebook';
    return 'email';
  }

  // ==================== EMAIL/PASSWORD AUTHENTICATION ====================

  /// Đăng ký bằng email/password
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      // Tạo user trong Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Cập nhật display name
        await user.updateDisplayName(name);

        // Gửi email xác thực
        await user.sendEmailVerification();

        // Tạo profile trong Firestore
        await FirebaseService.createOrUpdateUser(
          uid: user.uid,
          name: name,
          email: email,
          provider: 'email',
          isVerified: false,
        );

        // Lưu trạng thái đăng nhập
        await saveLoginState(user.uid);

        return {
          'success': true,
          'message':
              'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
          'userId': user.uid,
          'email': email,
          'requiresEmailVerification': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Đăng ký thất bại',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng ký thất bại';
      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
          break;
        case 'email-already-in-use':
          message = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'operation-not-allowed':
          message = 'Đăng ký bị vô hiệu hóa';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đăng ký: $e',
      };
    }
  }

  /// Đăng nhập bằng email/password
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Kiểm tra xem có profile trong Firestore chưa
        final userData = await FirebaseService.getUser(user.uid);
        if (userData == null) {
          await _createUserProfile(user);
        }

        // Lưu trạng thái đăng nhập
        await saveLoginState(user.uid);

        return {
          'success': true,
          'message': 'Đăng nhập thành công',
          'user': {
            'id': user.uid,
            'email': user.email,
            'name': user.displayName,
            'emailVerified': user.emailVerified,
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Đăng nhập thất bại',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều lần thử. Vui lòng thử lại sau';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đăng nhập: $e',
      };
    }
  }

  // ==================== EMAIL VERIFICATION ====================

  /// Gửi email xác thực
  static Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập',
        };
      }

      if (user.emailVerified) {
        return {
          'success': false,
          'message': 'Email đã được xác thực',
        };
      }

      await user.sendEmailVerification();
      return {
        'success': true,
        'message': 'Đã gửi email xác thực. Vui lòng kiểm tra hộp thư.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi gửi email: $e',
      };
    }
  }

  /// Kiểm tra email đã được xác thực chưa
  static Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ==================== PASSWORD RESET ====================

  /// Gửi email reset mật khẩu
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message':
            'Đã gửi email khôi phục mật khẩu. Vui lòng kiểm tra hộp thư.',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Gửi email thất bại';
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi gửi email: $e',
      };
    }
  }

  /// Đổi mật khẩu (yêu cầu đăng nhập)
  static Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập',
        };
      }

      // Xác thực lại với mật khẩu hiện tại
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Đổi mật khẩu
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Đổi mật khẩu thành công',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Đổi mật khẩu thất bại';
      switch (e.code) {
        case 'wrong-password':
          message = 'Mật khẩu hiện tại không đúng';
          break;
        case 'weak-password':
          message = 'Mật khẩu mới quá yếu (tối thiểu 6 ký tự)';
          break;
        case 'requires-recent-login':
          message = 'Vui lòng đăng nhập lại để đổi mật khẩu';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đổi mật khẩu: $e',
      };
    }
  }

  // ==================== GOOGLE SIGN-IN ====================

  /// Đăng nhập/Đăng ký với Google
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // Đăng xuất tài khoản cũ nếu có
      await _googleSignIn.signOut();

      // Đăng nhập với Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Đăng nhập Google bị hủy',
        };
      }

      // Lấy thông tin xác thực
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        // Kiểm tra xem có profile trong Firestore chưa
        final userData = await FirebaseService.getUser(user.uid);
        if (userData == null) {
          await _createUserProfile(user);
        }

        // Lưu trạng thái đăng nhập
        await saveLoginState(user.uid);

        return {
          'success': true,
          'message': 'Đăng nhập Google thành công',
          'user': {
            'id': user.uid,
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy thông tin người dùng',
        };
      }
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đăng nhập Google: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đăng nhập Google: $e',
      };
    }
  }

  /// Đăng ký với Google (sử dụng cùng logic với đăng nhập)
  static Future<Map<String, dynamic>> registerWithGoogle() async {
    return loginWithGoogle(); // Firebase tự động tạo tài khoản nếu chưa tồn tại
  }

  // ==================== FACEBOOK SIGN-IN ====================

  /// Đăng nhập/Đăng ký với Facebook
  static Future<Map<String, dynamic>> loginWithFacebook() async {
    try {
      // Đăng nhập với Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        return {
          'success': false,
          'message': 'Đăng nhập Facebook bị hủy hoặc thất bại',
        };
      }

      // Tạo credential cho Firebase
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      // Đăng nhập vào Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        // Kiểm tra xem có profile trong Firestore chưa
        final userData = await FirebaseService.getUser(user.uid);
        if (userData == null) {
          await _createUserProfile(user);
        }

        // Lưu trạng thái đăng nhập
        await saveLoginState(user.uid);

        return {
          'success': true,
          'message': 'Đăng nhập Facebook thành công',
          'user': {
            'id': user.uid,
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy thông tin người dùng',
        };
      }
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đăng nhập Facebook: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đăng nhập Facebook: $e',
      };
    }
  }

  /// Đăng ký với Facebook (sử dụng cùng logic với đăng nhập)
  static Future<Map<String, dynamic>> registerWithFacebook() async {
    return loginWithFacebook(); // Firebase tự động tạo tài khoản nếu chưa tồn tại
  }

  // ==================== LOGOUT ====================

  /// Đăng xuất
  static Future<void> logout() async {
    try {
      // Đăng xuất khỏi Firebase
      await _auth.signOut();

      // Đăng xuất khỏi Google Sign-In
      await _googleSignIn.signOut();

      // Đăng xuất khỏi Facebook
      await FacebookAuth.instance.logOut();

      // Xóa trạng thái đăng nhập
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.setBool('is_logged_in', false);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // ==================== DELETE ACCOUNT ====================

  /// Xóa tài khoản
  static Future<Map<String, dynamic>> deleteAccount(String? password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập',
        };
      }

      // Nếu đăng nhập bằng email/password, cần xác thực lại
      if (password != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final userId = user.uid;

      // Xóa dữ liệu trong Firestore
      // TODO: Implement proper data deletion (pets, diary entries, etc.)
      await _firestore.collection('users').doc(userId).delete();

      // Xóa tài khoản Firebase Auth
      await user.delete();

      // Xóa trạng thái đăng nhập
      await logout();

      return {
        'success': true,
        'message': 'Xóa tài khoản thành công',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Xóa tài khoản thất bại';
      switch (e.code) {
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'requires-recent-login':
          message = 'Vui lòng đăng nhập lại để xóa tài khoản';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi xóa tài khoản: $e',
      };
    }
  }
}

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

  /// Đăng ký bằng email/password - FIX TYPE CASTING ERROR
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      print('🔐 [Register] Starting registration for: $email');
      
      // Bước 1: Tạo tài khoản với proper error handling
      User? user;
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = userCredential.user;
        print('✅ [Register] User created successfully: ${user?.uid}');
      } on FirebaseAuthException catch (e) {
        // Handle Firebase Auth specific errors
        print('❌ [Register] FirebaseAuthException: ${e.code}');
        String message = 'Đăng ký thất bại';
        
        switch (e.code) {
          case 'email-already-in-use':
            message = 'Email này đã được đăng ký. Vui lòng sử dụng email khác.';
            break;
          case 'weak-password':
            message = 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
            break;
          case 'invalid-email':
            message = 'Email không hợp lệ.';
            break;
          case 'operation-not-allowed':
            message = 'Đăng ký email/password chưa được kích hoạt.';
            break;
        }
        
        return {
          'success': false,
          'message': message,
        };
      } catch (e) {
        // Handle other errors including type casting
        print('⚠️ [Register] Non-Firebase error: $e');
        
        // Check if user was actually created despite the error
        await Future.delayed(const Duration(milliseconds: 500));
        user = _auth.currentUser;
        
        if (user == null) {
          print('❌ [Register] User creation truly failed');
          return {
            'success': false,
            'message': 'Lỗi không xác định: $e',
          };
        }
        
        print('✅ [Register] User created despite error: ${user.uid}');
      }

      // Bước 2: Verify user và cập nhật profile
      if (user == null) {
        print('❌ [Register] User is null after all attempts');
        return {
          'success': false,
          'message': 'Đăng ký thất bại: Không thể tạo tài khoản',
        };
      }

      print('👤 [Register] Updating user profile for: ${user.uid}');
      
      // Cập nhật display name với error handling
      try {
        await user.updateDisplayName(name);
        print('✅ [Register] Display name updated');
      } catch (e) {
        print('⚠️ [Register] Failed to update display name: $e');
        // Continue anyway, not critical
      }

      // Gửi email xác thực với error handling
      try {
        await user.sendEmailVerification();
        print('✅ [Register] Verification email sent');
      } catch (e) {
        print('⚠️ [Register] Failed to send verification email: $e');
        // Continue anyway, user can resend later
      }

      // Tạo profile trong Firestore
      try {
        await FirebaseService.createOrUpdateUser(
          uid: user.uid,
          name: name,
          email: email,
          provider: 'email',
          isVerified: false,
        );
        print('✅ [Register] Firestore profile created');
      } catch (e) {
        print('⚠️ [Register] Failed to create Firestore profile: $e');
        // Continue anyway, can be created later
      }

      // Lưu trạng thái đăng nhập
      await saveLoginState(user.uid);

      print('✅ [Register] Registration complete for: $email');
      
      return {
        'success': true,
        'message': 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
        'userId': user.uid,
        'email': email,
        'requiresEmailVerification': true,
      };
    } catch (e) {
      // Final catch-all for any unexpected errors
      print('❌ [Register] Unexpected error: $e');
      return {
        'success': false,
        'message': 'Lỗi đăng ký: ${e.toString()}',
      };
    }
  }

  /// Đăng nhập bằng email/password - FIX TYPE CASTING ERROR
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      print('🔐 [Login] Starting login for: $email');
      
      User? user;
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = userCredential.user;
        print('✅ [Login] User authenticated: ${user?.uid}');
      } on FirebaseAuthException catch (e) {
        // Handle Firebase Auth specific errors
        print('❌ [Login] FirebaseAuthException: ${e.code}');
        String message = 'Đăng nhập thất bại';
        
        switch (e.code) {
          case 'user-not-found':
            message = 'Không tìm thấy tài khoản với email này';
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
          case 'invalid-credential':
            message = 'Email hoặc mật khẩu không đúng';
            break;
        }
        
        return {
          'success': false,
          'message': message,
        };
      } catch (e) {
        // Handle other errors including type casting
        print('⚠️ [Login] Non-Firebase error: $e');
        
        // Check if user was actually authenticated despite the error
        await Future.delayed(const Duration(milliseconds: 500));
        user = _auth.currentUser;
        
        if (user == null) {
          print('❌ [Login] Authentication truly failed');
          return {
            'success': false,
            'message': 'Lỗi không xác định: $e',
          };
        }
        
        print('✅ [Login] User authenticated despite error: ${user.uid}');
      }

      // Verify user exists
      if (user == null) {
        print('❌ [Login] User is null after all attempts');
        return {
          'success': false,
          'message': 'Đăng nhập thất bại',
        };
      }

      print('👤 [Login] Checking user profile: ${user.uid}');
      
      // Kiểm tra và tạo profile trong Firestore nếu chưa có
      try {
        final userData = await FirebaseService.getUser(user.uid);
        if (userData == null) {
          print('📝 [Login] Creating Firestore profile');
          await _createUserProfile(user);
        }
      } catch (e) {
        print('⚠️ [Login] Failed to check/create Firestore profile: $e');
        // Continue anyway, not critical for login
      }

      // Lưu trạng thái đăng nhập
      await saveLoginState(user.uid);

      print('✅ [Login] Login complete for: $email');

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
    } catch (e) {
      // Final catch-all for any unexpected errors
      print('❌ [Login] Unexpected error: $e');
      return {
        'success': false,
        'message': 'Lỗi đăng nhập: ${e.toString()}',
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
      print('🔵 [Google Sign-In] Bắt đầu đăng nhập...');
      
      // Đăng xuất tài khoản cũ nếu có
      await _googleSignIn.signOut();
      print('🔵 [Google Sign-In] Đã sign out tài khoản cũ');

      // Đăng nhập với Google
      print('🔵 [Google Sign-In] Đang mở dialog chọn tài khoản...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('🔵 [Google Sign-In] Kết quả: ${googleUser?.email ?? "null"}');

      if (googleUser == null) {
        print('❌ [Google Sign-In] User huỷ đăng nhập');
        return {
          'success': false,
          'message': 'Đăng nhập Google bị hủy',
        };
      }

      // Lấy thông tin xác thực
      print('🔵 [Google Sign-In] Đang lấy authentication...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('🔵 [Google Sign-In] Access token: ${googleAuth.accessToken != null}');
      print('🔵 [Google Sign-In] ID token: ${googleAuth.idToken != null}');

      // Tạo credential cho Firebase
      print('🔵 [Google Sign-In] Tạo Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('🔵 [Google Sign-In] Credential đã tạo');

      // Đăng nhập vào Firebase
      print('🔵 [Google Sign-In] Đăng nhập vào Firebase...');
      
      try {
        final userCredential = await _auth.signInWithCredential(credential);
        print('✅ [Google Sign-In] Firebase authentication thành công!');

        final user = userCredential.user;
        if (user != null) {
          print('🔵 [Google Sign-In] User UID: ${user.uid}');
          print('🔵 [Google Sign-In] User email: ${user.email}');
          
          // Kiểm tra xem có profile trong Firestore chưa
          print('� [Google Sign-In] Kiểm tra profile trong Firestore...');
          final userData = await FirebaseService.getUser(user.uid);
          if (userData == null) {
            print('🔵 [Google Sign-In] Tạo profile mới...');
            await _createUserProfile(user);
            print('✅ [Google Sign-In] Đã tạo profile');
          } else {
            print('✅ [Google Sign-In] Profile đã tồn tại');
          }

          // Lưu trạng thái đăng nhập
          print('🔵 [Google Sign-In] Lưu login state...');
          await saveLoginState(user.uid);
          print('✅ [Google Sign-In] Hoàn tất!');

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
          print('❌ [Google Sign-In] User null sau khi signIn');
          return {
            'success': false,
            'message': 'Không thể lấy thông tin người dùng',
          };
        }
      } catch (e) {
        // Nếu lỗi type casting, cố gắng lấy current user
        print('⚠️ [Google Sign-In] Firebase Auth error: $e');
        print('� [Google Sign-In] Thử lấy current user...');
        
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('✅ [Google Sign-In] Current user: ${currentUser.uid}');
          
          // Kiểm tra xem có profile trong Firestore chưa
          print('🔵 [Google Sign-In] Kiểm tra profile trong Firestore...');
          final userData = await FirebaseService.getUser(currentUser.uid);
          if (userData == null) {
            print('🔵 [Google Sign-In] Tạo profile mới...');
            await _createUserProfile(currentUser);
            print('✅ [Google Sign-In] Đã tạo profile');
          } else {
            print('✅ [Google Sign-In] Profile đã tồn tại');
          }

          // Lưu trạng thái đăng nhập
          print('🔵 [Google Sign-In] Lưu login state...');
          await saveLoginState(currentUser.uid);
          print('✅ [Google Sign-In] Hoàn tất!');

          return {
            'success': true,
            'message': 'Đăng nhập Google thành công',
            'user': {
              'id': currentUser.uid,
              'email': currentUser.email,
              'name': currentUser.displayName,
              'photoUrl': currentUser.photoURL,
            },
          };
        } else {
          print('❌ [Google Sign-In] currentUser cũng null');
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      print('❌ [Google Sign-In] FirebaseAuthException: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': 'Lỗi đăng nhập Google: ${e.message}',
      };
    } catch (e, stackTrace) {
      print('❌ [Google Sign-In] Exception: $e');
      print('❌ [Google Sign-In] StackTrace: $stackTrace');
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

  // ==================== OTP FOR FORGOT PASSWORD ====================

  /// Tạo và lưu OTP cho đặt lại mật khẩu
  static Future<Map<String, dynamic>> generateAndSendOTP(String email) async {
    try {
      // Kiểm tra email tồn tại
      final user = await _auth.fetchSignInMethodsForEmail(email);
      if (user.isEmpty) {
        return {
          'success': false,
          'message': 'Không tìm thấy tài khoản với email này',
        };
      }

      // Gửi password reset email (Firebase tự động gửi link)
      await _auth.sendPasswordResetEmail(email: email);

      // Lưu OTP vào Firestore (optional, cho tracking)
      final now = DateTime.now();
      await _firestore.collection('otp_requests').add({
        'email': email,
        'requested_at': Timestamp.fromDate(now),
        'expires_at': Timestamp.fromDate(now.add(const Duration(minutes: 10))),
        'status': 'pending',
      });

      print('✅ [OTP] Password reset email sent to: $email');

      return {
        'success': true,
        'message':
            'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư của bạn (bao gồm thư rác).',
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
        case 'too-many-requests':
          message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau 1 phút';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('❌ [OTP] Error: $e');
      return {
        'success': false,
        'message': 'Lỗi gửi email: $e',
      };
    }
  }

  /// Đặt lại mật khẩu bằng reset code từ email
  static Future<Map<String, dynamic>> resetPasswordWithCode(
    String oobCode,
    String newPassword,
  ) async {
    try {
      // Xác minh code từ email
      final email = await _auth.verifyPasswordResetCode(oobCode);
      print('✅ [Password Reset] Code valid for email: $email');

      // Đặt lại mật khẩu
      await _auth.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );

      print('✅ [Password Reset] Password reset successful');

      return {
        'success': true,
        'message': 'Đặt lại mật khẩu thành công. Vui lòng đăng nhập với mật khẩu mới.',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Đặt lại mật khẩu thất bại';
      switch (e.code) {
        case 'invalid-action-code':
          message = 'Đường dẫn đặt lại mật khẩu không hợp lệ hoặc đã hết hạn';
          break;
        case 'expired-action-code':
          message = 'Đường dẫn đặt lại mật khẩu đã hết hạn (10 phút)';
          break;
        case 'weak-password':
          message = 'Mật khẩu mới quá yếu (tối thiểu 6 ký tự)';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa';
          break;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('❌ [Password Reset] Error: $e');
      return {
        'success': false,
        'message': 'Lỗi đặt lại mật khẩu: $e',
      };
    }
  }

  /// Xác minh mã reset từ link email
  static Future<bool> verifyResetCode(String oobCode) async {
    try {
      final email = await _auth.verifyPasswordResetCode(oobCode);
      print('✅ [Password Reset] Code verified for: $email');
      return true;
    } catch (e) {
      print('❌ [Password Reset] Invalid code: $e');
      return false;
    }
  }
}

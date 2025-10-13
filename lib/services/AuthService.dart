import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static const String _defaultBaseUrl =
      'http://10.0.2.2:3000'; // Đổi sang 10.0.2.2 cho Android emulator
  static String _baseUrl = _defaultBaseUrl; // Có thể thay đổi qua setBaseUrl
  static const int _timeoutDuration = 10; // Timeout sau 10 giây

  // Đặt URL backend (dùng cho môi trường sản phẩm)
  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Lưu trạng thái đăng nhập
  static Future<void> saveLoginState(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setBool('is_logged_in', true);
  }

  // Kiểm tra trạng thái đăng nhập
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Lấy token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Lấy user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Lấy thông tin user từ backend
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: _timeoutDuration));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Không thể lấy thông tin',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Cập nhật thông tin user
  static Future<Map<String, dynamic>> updateUserInfo(
      String name, String? avatarUrl) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập',
        };
      }

      final response = await http
          .put(
            Uri.parse('$_baseUrl/user/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'avatarUrl': avatarUrl,
            }),
          )
          .timeout(Duration(seconds: _timeoutDuration));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật thành công',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Cập nhật thất bại',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);

    // Đăng xuất khỏi Firebase
    await FirebaseAuth.instance.signOut();

    // Đăng xuất khỏi Google Sign-In
    await GoogleSignIn().signOut();
  }

  // Hàm chung để gửi request với timeout và retry
  static Future<Map<String, dynamic>> _sendAuthRequest(
      String endpoint, Map<String, dynamic> body) async {
    const int maxRetries = 2;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/$endpoint'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(Duration(seconds: _timeoutDuration));

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 &&
            data['token'] != null &&
            data['user'] != null &&
            data['user']['id'] != null) {
          await saveLoginState(data['token'], data['user']['id'].toString());
          return {
            'success': true,
            'message': data['message'] ?? 'Thành công',
            'user': data['user'],
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Yêu cầu thất bại',
          };
        }
      } catch (e) {
        if (attempt == maxRetries) {
          return {
            'success': false,
            'message': 'Lỗi kết nối sau $maxRetries lần thử: $e',
          };
        }
        await Future.delayed(
            Duration(seconds: 1)); // Chờ 1 giây trước khi thử lại
      }
    }
    return {'success': false, 'message': 'Lỗi kết nối không xác định'};
  }

  // Hàm chung để xử lý đăng nhập/đăng ký với OAuth
  static Future<Map<String, dynamic>> _handleOAuth(
      Future<GoogleSignInAccount?> Function() signIn,
      String tokenEndpoint,
      String actionMessage) async {
    try {
      final GoogleSignInAccount? account = await signIn();
      if (account == null) {
        return {
          'success': false,
          'message': '$actionMessage bị hủy',
        };
      }

      final auth = await account.authentication;
      final accessToken = auth.accessToken;

      return await _sendAuthRequest(
          tokenEndpoint, {'accessToken': accessToken});
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối $actionMessage: $e',
      };
    }
  }

  // Hàm chung để xử lý đăng nhập/đăng ký với Facebook
  static Future<Map<String, dynamic>> _handleFacebookOAuth(
      String tokenEndpoint, String actionMessage) async {
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile']);
      if (result.status != LoginStatus.success) {
        return {
          'success': false,
          'message': '$actionMessage bị hủy hoặc thất bại',
        };
      }

      final accessToken = result.accessToken!.tokenString;
      return await _sendAuthRequest(
          tokenEndpoint, {'accessToken': accessToken});
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối $actionMessage: $e',
      };
    }
  }

  // Đăng nhập bằng email/password
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return _sendAuthRequest('login', {'email': email, 'password': password});
  }

  // Đăng ký bằng email/password
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    const int maxRetries = 2;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/register'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(
                  {'name': name, 'email': email, 'password': password}),
            )
            .timeout(Duration(seconds: _timeoutDuration));

        final data = jsonDecode(response.body);

        if (response.statusCode == 201) {
          return {
            'success': true,
            'message': data['message'] ?? 'Đăng ký thành công',
            'userId': data['userId'],
            'email': data['email'],
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Đăng ký thất bại',
          };
        }
      } catch (e) {
        if (attempt == maxRetries) {
          return {
            'success': false,
            'message': 'Lỗi kết nối sau $maxRetries lần thử: $e',
          };
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return {'success': false, 'message': 'Lỗi kết nối không xác định'};
  }

  // Xác thực OTP
  static Future<Map<String, dynamic>> verifyOTP(
      String email, String otp) async {
    const int maxRetries = 2;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/verify-otp'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'otp': otp}),
            )
            .timeout(Duration(seconds: _timeoutDuration));

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': data['message'] ?? 'Xác thực thành công',
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Xác thực thất bại',
          };
        }
      } catch (e) {
        if (attempt == maxRetries) {
          return {
            'success': false,
            'message': 'Lỗi kết nối sau $maxRetries lần thử: $e',
          };
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return {'success': false, 'message': 'Lỗi kết nối không xác định'};
  }

  // Gửi lại OTP
  static Future<Map<String, dynamic>> resendOTP(String email) async {
    const int maxRetries = 2;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/resend-otp'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email}),
            )
            .timeout(Duration(seconds: _timeoutDuration));

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': data['message'] ?? 'Gửi lại OTP thành công',
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Gửi lại OTP thất bại',
          };
        }
      } catch (e) {
        if (attempt == maxRetries) {
          return {
            'success': false,
            'message': 'Lỗi kết nối sau $maxRetries lần thử: $e',
          };
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return {'success': false, 'message': 'Lỗi kết nối không xác định'};
  }

  // Đăng nhập với Google (Firebase Authentication)
  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // Khởi tạo Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Đăng xuất tài khoản cũ nếu có
      await googleSignIn.signOut();

      // Đăng nhập với Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

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
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Lấy token từ Firebase
      final String? firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken != null && userCredential.user != null) {
        // Lưu trạng thái đăng nhập
        await saveLoginState(firebaseToken, userCredential.user!.uid);

        return {
          'success': true,
          'message': 'Đăng nhập Google thành công',
          'user': {
            'id': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'name': userCredential.user!.displayName,
            'photoUrl': userCredential.user!.photoURL,
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy thông tin người dùng',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi đăng nhập Google: $e',
      };
    }
  }

  // Đăng ký với Google (sử dụng cùng logic với đăng nhập)
  static Future<Map<String, dynamic>> registerWithGoogle() async {
    return loginWithGoogle(); // Firebase tự động tạo tài khoản nếu chưa tồn tại
  }

  // Đăng nhập với Facebook
  static Future<Map<String, dynamic>> loginWithFacebook() async {
    return _handleFacebookOAuth('auth/facebook/token', 'Đăng nhập Facebook');
  }

  // Đăng ký với Facebook
  static Future<Map<String, dynamic>> registerWithFacebook() async {
    return _handleFacebookOAuth('auth/facebook/register', 'Đăng ký Facebook');
  }
}

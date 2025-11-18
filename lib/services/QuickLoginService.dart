import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service xử lý Quick Login - Biometric (Face ID, Fingerprint) hoặc Password
class QuickLoginService {
  static const _storage = FlutterSecureStorage();
  static final _localAuth = LocalAuthentication();
  
  // Keys cho Secure Storage
  static const String _emailKey = 'quick_login_email';
  static const String _passwordKey = 'quick_login_password';
  static const String _isBiometricEnabledKey = 'quick_login_biometric_enabled';
  
  // Keys cho Shared Preferences
  static const String _hasLoggedInBeforeKey = 'has_logged_in_before';
  static const String _biometricAvailableKey = 'biometric_available';
  static const String _lastLoginTimeKey = 'last_login_time';
  static const int _sessionDurationMinutes = 15; // 15-minute session

  /// Kiểm tra xem thiết bị có hỗ trợ biometric không
  static Future<bool> isBiometricAvailable() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricAvailableKey, canCheckBiometrics && isDeviceSupported);
      
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print('❌ [BiometricCheck] Error: $e');
      return false;
    }
  }

  /// Lấy danh sách biometric methods có sẵn
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics;
    } catch (e) {
      print('❌ [BiometricCheck] Error getting available biometrics: $e');
      return [];
    }
  }

  /// Lưu thông tin đăng nhập cho quick login (sau khi đăng nhập lần đầu)
  static Future<void> saveCredentials({
    required String email,
    required String password,
    required bool enableBiometric,
  }) async {
    try {
      print('💾 [QuickLogin] Saving credentials...');
      print('💾 [QuickLogin] Email: $email');
      print('💾 [QuickLogin] Password length: ${password.length}');
      print('💾 [QuickLogin] Enable biometric: $enableBiometric');
      
      // Lưu email và password vào Secure Storage (email sẽ được giữ lại sau logout)
      await _storage.write(key: _emailKey, value: email);
      print('💾 [QuickLogin] Email written to secure storage');
      
      await _storage.write(key: _passwordKey, value: password);
      print('💾 [QuickLogin] Password written to secure storage');
      
      // Lưu trạng thái biometric
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, enableBiometric);
      await prefs.setBool(_hasLoggedInBeforeKey, true);
      
      print('✅ [QuickLogin] Credentials saved successfully (email: $email)');
      
      // Verify by reading back
      final verifyEmail = await _storage.read(key: _emailKey);
      final verifyPassword = await _storage.read(key: _passwordKey);
      print('🔍 [QuickLogin] Verification - Email: ${verifyEmail != null ? "✅" : "❌"}, Password: ${verifyPassword != null ? "✅" : "❌"}');
    } catch (e) {
      print('❌ [QuickLogin] Error saving credentials: $e');
      rethrow;
    }
  }

  /// Lấy email đã lưu
  static Future<String?> getSavedEmail() async {
    try {
      return await _storage.read(key: _emailKey);
    } catch (e) {
      print('❌ [QuickLogin] Error getting saved email: $e');
      return null;
    }
  }

  /// Kiểm tra xem đã đăng nhập lần đầu chưa
  static Future<bool> hasLoggedInBefore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasLoggedInBeforeKey) ?? false;
    } catch (e) {
      print('❌ [QuickLogin] Error checking login history: $e');
      return false;
    }
  }

  /// Kiểm tra xem biometric có được enable chưa
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isBiometricEnabledKey) ?? false;
    } catch (e) {
      print('❌ [QuickLogin] Error checking biometric setting: $e');
      return false;
    }
  }

  /// Xác thực biometric (Face ID hoặc Fingerprint)
  static Future<bool> authenticateWithBiometric() async {
    try {
      // Check if biometric is available first
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        print('⚠️ [Biometric] Device does not support biometric authentication');
        return false;
      }
      
      // Get available biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('⚠️ [Biometric] No biometric methods enrolled on device');
        return false;
      }
      
      print('🔐 [Biometric] Available methods: $availableBiometrics');
      
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Xác thực để đăng nhập vào Ocean Pet',
        options: const AuthenticationOptions(
          stickyAuth: true, // Tiếp tục xác thực nếu app bị tạm dừng
          biometricOnly: false, // Cho phép dùng PIN/Pattern nếu biometric fail
          useErrorDialogs: true, // Hiển thị dialog lỗi tự động
          sensitiveTransaction: false,
        ),
      );
      
      print('🔒 [Biometric] Authentication result: $isAuthenticated');
      return isAuthenticated;
    } catch (e) {
      print('❌ [Biometric] Authentication error: $e');
      return false;
    }
  }

  /// Lấy thông tin đăng nhập từ Secure Storage
  /// Cần được gọi sau khi xác thực biometric thành công
  static Future<Map<String, String>?> getCredentials() async {
    try {
      print('🔍 [QuickLogin] Reading from secure storage...');
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      
      print('🔍 [QuickLogin] Email read: ${email != null ? "✅ $email" : "❌ null"}');
      print('🔍 [QuickLogin] Password read: ${password != null ? "✅ ${password.length} chars" : "❌ null"}');
      
      if (email != null && password != null) {
        print('✅ [QuickLogin] Both credentials found');
        return {
          'email': email,
          'password': password,
        };
      }
      
      print('❌ [QuickLogin] Missing credentials - email: ${email != null}, password: ${password != null}');
      return null;
    } catch (e) {
      print('❌ [QuickLogin] Error retrieving credentials: $e');
      return null;
    }
  }

  /// Xóa thông tin đăng nhập (logout)
  /// GIỮ LẠI email và password cho quick login - CHỈ tắt biometric
  static Future<void> clearCredentials() async {
    try {
      // KHÔNG xoá password - giữ lại để biometric có thể dùng
      // CHỈ tắt biometric flag
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, false);
      // NOTE: Do NOT set hasLoggedInBefore to false here!
      // We want to preserve the "user has logged in before" flag
      // so they see QuickLoginScreen after logout, not LoginScreen
      
      print('✅ [QuickLogin] Biometric disabled (email and password preserved for quick login)');
    } catch (e) {
      print('❌ [QuickLogin] Error clearing credentials: $e');
      rethrow;
    }
  }

  /// Disable biometric quick login
  static Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, false);
      print('✅ [QuickLogin] Biometric disabled');
    } catch (e) {
      print('❌ [QuickLogin] Error disabling biometric: $e');
      rethrow;
    }
  }

  /// Enable biometric quick login
  static Future<void> enableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, true);
      print('✅ [QuickLogin] Biometric enabled');
    } catch (e) {
      print('❌ [QuickLogin] Error enabling biometric: $e');
      rethrow;
    }
  }

  /// Record login time for session timeout
  static Future<void> recordLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastLoginTimeKey, now);
      print('✅ [QuickLogin] Login time recorded: ${DateTime.fromMillisecondsSinceEpoch(now)}');
    } catch (e) {
      print('❌ [QuickLogin] Error recording login time: $e');
    }
  }

  /// Check if session is still valid (within 15 minutes)
  static Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginTime = prefs.getInt(_lastLoginTimeKey);
      
      if (lastLoginTime == null) {
        print('⚠️ [QuickLogin] No session time found - first time quick login');
        return true; // Allow first time
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedMs = now - lastLoginTime;
      final elapsedMinutes = (elapsedMs / (1000 * 60)).toStringAsFixed(2);
      final isValid = elapsedMs < (_sessionDurationMinutes * 60 * 1000);
      
      print('⏱️ [QuickLogin] Session check:');
      print('   Last login: ${DateTime.fromMillisecondsSinceEpoch(lastLoginTime)}');
      print('   Current time: ${DateTime.fromMillisecondsSinceEpoch(now)}');
      print('   Elapsed: $elapsedMinutes minutes');
      print('   Valid: $isValid (timeout after $_sessionDurationMinutes minutes)');
      
      return isValid;
    } catch (e) {
      print('❌ [QuickLogin] Error checking session: $e');
      return true; // Allow on error
    }
  }

  /// End session after timeout (clear login state permanently)
  static Future<void> endSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasLoggedInBeforeKey, false);
      await prefs.remove(_lastLoginTimeKey);
      await prefs.setBool(_isBiometricEnabledKey, false);
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _passwordKey);
      print('✅ [QuickLogin] Session ended - returning to login screen');
    } catch (e) {
      print('❌ [QuickLogin] Error ending session: $e');
    }
  }

  /// Save only email for display on quick login (preserves email even after logout)
  static Future<void> saveEmailForQuickLogin(String email) async {
    try {
      await _storage.write(key: _emailKey, value: email);
      print('✅ [QuickLogin] Email saved for quick login: $email');
    } catch (e) {
      print('❌ [QuickLogin] Error saving email: $e');
    }
  }
}

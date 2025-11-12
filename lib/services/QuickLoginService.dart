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
      // Lưu email và password vào Secure Storage
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _passwordKey, value: password);
      
      // Lưu trạng thái biometric
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, enableBiometric);
      await prefs.setBool(_hasLoggedInBeforeKey, true);
      
      print('✅ [QuickLogin] Credentials saved successfully');
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
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Vui lòng xác thực danh tính của bạn',
        options: const AuthenticationOptions(
          stickyAuth: true, // Tiếp tục xác thực nếu app bị tạm dừng
          biometricOnly: true, // Chỉ dùng biometric, không dùng PIN/Pattern
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
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      
      if (email != null && password != null) {
        return {
          'email': email,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      print('❌ [QuickLogin] Error retrieving credentials: $e');
      return null;
    }
  }

  /// Xóa thông tin đăng nhập (logout)
  static Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _passwordKey);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isBiometricEnabledKey, false);
      await prefs.setBool(_hasLoggedInBeforeKey, false);
      
      print('✅ [QuickLogin] Credentials cleared');
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
}

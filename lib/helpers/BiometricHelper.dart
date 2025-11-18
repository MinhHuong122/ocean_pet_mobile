import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Helper đơn giản để sử dụng sinh trắc học (vân tay, Face ID)
/// 
/// Giao diện sinh trắc học HOÀN TOÀN do hệ điều hành hiển thị:
/// - Android: BiometricPrompt (popup xanh chuẩn Material Design)
/// - iOS: Face ID / Touch ID (popup trắng chuẩn Apple)
/// 
/// Bạn KHÔNG cần tự code UI! Chỉ cần gọi authenticate() là popup tự hiện.
class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Kiểm tra máy có hỗ trợ sinh trắc học không
  static Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print('❌ [BiometricHelper] Error checking support: $e');
      return false;
    }
  }

  /// Lấy danh sách sinh trắc học khả dụng (vân tay, Face ID, v.v.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('❌ [BiometricHelper] Error getting available biometrics: $e');
      return [];
    }
  }

  /// Hiện popup sinh trắc học của hệ thống (vân tay / Face ID)
  /// 
  /// Popup sẽ TỰ ĐỘNG hiện với giao diện chuẩn của Android/iOS.
  /// Bạn không cần tự vẽ UI!
  static Future<bool> authenticate({
    String reason = 'Vui lòng xác thực để tiếp tục',
    bool biometricOnly = false,
  }) async {
    try {
      // Kiểm tra trước khi authenticate
      if (!await canAuthenticate()) {
        print('⚠️ [BiometricHelper] Device does not support biometric');
        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('⚠️ [BiometricHelper] No biometric enrolled on device');
        return false;
      }

      print('🔐 [BiometricHelper] Authenticating with: $availableBiometrics');

      // GỌI POPUP SINH TRẮC HỌC CỦA HỆ THỐNG
      // Popup sẽ tự động hiện với giao diện chuẩn (Android xanh / iOS trắng)
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason, // Bắt buộc phải có
        options: AuthenticationOptions(
          biometricOnly: biometricOnly, // true = chỉ sinh trắc, false = cho phép PIN/Pattern backup
          stickyAuth: true,              // Android: giữ auth khi app bị pause
          useErrorDialogs: true,         // Hiện dialog lỗi đẹp của hệ thống
        ),
      );

      print('✅ [BiometricHelper] Authentication result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('❌ [BiometricHelper] Platform error: $e');
      return false;
    } catch (e) {
      print('❌ [BiometricHelper] Error: $e');
      return false;
    }
  }

  /// Get tên loại sinh trắc học (để hiển thị UI)
  static Future<String> getBiometricName() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) return 'Sinh trắc học';
      
      if (biometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Vân tay';
      } else if (biometrics.contains(BiometricType.iris)) {
        return 'Mống mắt';
      }
      return 'Sinh trắc học';
    } catch (e) {
      return 'Sinh trắc học';
    }
  }

  /// Get icon phù hợp với loại sinh trắc học
  static Future<String> getBiometricIcon() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) return '🔒';
      
      if (biometrics.contains(BiometricType.face)) {
        return '😊'; // Face ID emoji
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return '👆'; // Fingerprint emoji
      } else if (biometrics.contains(BiometricType.iris)) {
        return '👁️'; // Iris emoji
      }
      return '🔒';
    } catch (e) {
      return '🔒';
    }
  }
}

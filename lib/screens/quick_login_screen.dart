import 'package:flutter/material.dart';
import 'package:ocean_pet/res/R.dart';
import 'package:ocean_pet/services/AuthService.dart';
import 'package:ocean_pet/services/QuickLoginService.dart';
import 'package:ocean_pet/screens/home_screen.dart';
import 'package:ocean_pet/screens/login_screen.dart';
import 'package:ocean_pet/screens/forgot_password_screen.dart';
import 'package:local_auth/local_auth.dart';

/// Màn hình đăng nhập nhanh với Sinh Trắc Học (Face ID / Vân tay)
/// 
/// QUAN TRỌNG: Giao diện sinh trắc học do HỆ ĐIỀU HÀNH tự hiển thị
/// - Android: BiometricPrompt (popup xanh chuẩn Material Design)
/// - iOS: Face ID/Touch ID (popup trắng chuẩn Apple)
/// 
/// KHÔNG cần tự code UI sinh trắc học! Chỉ gọi QuickLoginService.authenticateWithBiometric()
/// hoặc BiometricHelper.authenticate() là popup tự động hiện.
/// 
/// Xem hướng dẫn chi tiết: BIOMETRIC_GUIDE.md
/// Demo: lib/screens/biometric_demo_screen.dart
class QuickLoginScreen extends StatefulWidget {
  const QuickLoginScreen({super.key});

  @override
  State<QuickLoginScreen> createState() => _QuickLoginScreenState();
}

class _QuickLoginScreenState extends State<QuickLoginScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _savedEmail;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      // Check if session is still valid (15-minute timeout)
      final hasLoggedInBefore = await QuickLoginService.hasLoggedInBefore();
      if (hasLoggedInBefore) {
        final isSessionValid = await QuickLoginService.isSessionValid();
        if (!isSessionValid) {
          print('🔴 [QuickLogin] Session expired - ending session');
          await QuickLoginService.endSession();
          // Redirect to login after a short delay
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
          return;
        }
      }

      // Lấy email đã lưu
      var email = await QuickLoginService.getSavedEmail();
      print('📧 [QuickLogin] Saved email from QuickLoginService: $email');

      // Fallback 1: Check Firebase Auth user
      if (email == null || email.isEmpty) {
        final firebaseUser = AuthService.getCurrentUser();
        if (firebaseUser != null) {
          email = firebaseUser.email;
          print('📧 [QuickLogin] Email from Firebase Auth: $email');
        }
      }

      // Fallback 2: If still no email, try to get last used email from login screen
      if (email == null || email.isEmpty) {
        print('⚠️ [QuickLogin] Email still not found - this is first time login');
        email = 'unknown@email.com'; // Placeholder
      }

      final biometricEnabled =
          await QuickLoginService.isBiometricEnabled();
      final biometricAvailable =
          await QuickLoginService.isBiometricAvailable();
      final availableBiometrics =
          await QuickLoginService.getAvailableBiometrics();

      print('🔐 [QuickLogin] Biometric enabled: $biometricEnabled, available: $biometricAvailable');

      setState(() {
        _savedEmail = email;
        _isBiometricEnabled = biometricEnabled;
        _isBiometricAvailable = biometricAvailable;
        _availableBiometrics = availableBiometrics;
      });

      // Không tự động chạy biometric khi vào màn hình
      // User sẽ phải nhấn nút để kích hoạt
      print('[QuickLogin] Biometric ready but waiting for user action');
    } catch (e) {
      print('❌ [QuickLogin] Error initializing: $e');
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check if biometric is available on device
      if (!_isBiometricAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thiết bị chưa thiết lập sinh trắc học. Vui lòng vào Cài đặt > Bảo mật để kích hoạt vân tay/Face ID',
                      style: TextStyle(fontFamily: R.font.sfpro),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final isAuthenticated =
          await QuickLoginService.authenticateWithBiometric();

      if (isAuthenticated) {
        // Xác thực sinh trắc học thành công
        print('✅ [QuickLogin] Biometric authentication successful');
        
        // Lấy credentials để đăng nhập
        final credentials = await QuickLoginService.getCredentials();
        print('🔍 [QuickLogin] Retrieved credentials: ${credentials != null ? "Email: ${credentials['email']}, Has password: ${credentials['password'] != null && credentials['password']!.isNotEmpty}" : "null"}');
        
        if (credentials == null || credentials['password'] == null || credentials['password']!.isEmpty) {
          // Không có password (OAuth user) - không thể đăng nhập lại
          print('❌ [QuickLogin] OAuth user detected - cannot auto-login');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tài khoản Google/Facebook cần đăng nhập lại. Vui lòng quay lại màn hình đăng nhập.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        // Email/password user - đăng nhập bình thường
        print('🔐 [QuickLogin] Email/password user - logging in with credentials: ${credentials['email']}');
        _performLogin(credentials['email']!, credentials['password']!);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Biometric Auth] Error: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực sinh trắc học thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loginWithPassword() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mật khẩu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_savedEmail == null || _savedEmail!.isEmpty) {
      print('[QuickLogin] Email not found. Saved: $_savedEmail');
      // Go back to main login screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'),
            backgroundColor: Colors.red,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
      return;
    }

    // Proceed with password login
    setState(() {
      _isLoading = true;
    });

    print('[QuickLogin] Logging in with email: $_savedEmail');
    _performLogin(_savedEmail!, _passwordController.text);
  }

  Future<void> _performLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(email, password);

      if (result['success']) {
        // Save credentials for next quick login (only if password is provided)
        if (password.isNotEmpty) {
          try {
            await QuickLoginService.saveCredentials(
              email: email,
              password: password,
              enableBiometric: false, // Keep biometric setting as-is
            );
            print('✅ [QuickLogin] Credentials saved after successful login');
          } catch (e) {
            print('❌ [QuickLogin] Failed to save credentials: $e');
          }
        }
        
        // Record login time for 15-minute session
        await QuickLoginService.recordLoginTime();
        
        if (mounted) {
          // Chuyển sang HomeScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Đăng nhập thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra, vui lòng thử lại'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getBiometricLabel() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Vân tay';
    }
    return 'Sinh trắc học';
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    }
    return Icons.verified_user;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Welcome back message
                Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: R.font.sfpro,
                  ),
                ),

                const SizedBox(height: 12),

                if (_savedEmail != null)
                  Text(
                    _savedEmail!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: R.font.sfpro,
                    ),
                  ),

                const SizedBox(height: 40),

                // Biometric option - ALWAYS show button
                // Giao diện sinh trắc học sẽ do hệ điều hành hiển thị (Android BiometricPrompt / iOS LocalAuthentication)
                // Không cần tự code UI, chỉ cần gọi local_auth.authenticate()
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _authenticateWithBiometric,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBiometricAvailable 
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey,
                          disabledBackgroundColor:
                              const Color(0xFF8B5CF6).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getBiometricIcon(),
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isBiometricAvailable
                                        ? 'ĐĂNG NHẬP VỚI ${_getBiometricLabel().toUpperCase()}'
                                        : 'SINH TRẮC HỌC KHÔNG KHẢ DỤNG',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: R.font.sfpro,
                                    ),
                                  ),
                                  if (!_isBiometricAvailable)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Hãy thiết lập sinh trắc học trong cài đặt thiết bị',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: R.font.sfpro,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'HOẶC',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: R.font.sfpro,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),

                // Password input
                Text(
                  'Nhập mật khẩu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: R.font.sfpro,
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginWithPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      disabledBackgroundColor:
                          const Color(0xFF8B5CF6).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: R.font.sfpro,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Forgot password link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                        fontFamily: R.font.sfpro,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Use different account
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Clear credentials and go back to main login
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: R.font.sfpro,
                        ),
                        children: [
                  
                          TextSpan(
                            text: 'Đăng nhập bằng tài khoản khác',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 102, 102, 102),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

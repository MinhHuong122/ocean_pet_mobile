import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_pet/res/R.dart';
import 'package:ocean_pet/services/AuthService.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Xác thực và gửi email đặt lại mật khẩu
  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    // Kiểm tra email trống
    if (email.isEmpty) {
      _showError('Vui lòng nhập email của bạn');
      return;
    }

    // Kiểm tra định dạng email
    if (!_isValidEmail(email)) {
      _showError('Email không hợp lệ. Vui lòng nhập lại');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      final result = await AuthService.generateAndSendOTP(email);

      if (!mounted) return;

      if (result['success']) {
        // ✅ Email sent - show success message
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });

        _showSuccessSnackBar(
          result['message'] ?? 'Email đặt lại mật khẩu đã được gửi',
          duration: const Duration(seconds: 6),
        );
      } else {
        setState(() {
          _isLoading = false;
          _emailError = result['message'] ?? 'Gửi email thất bại';
        });

        _showErrorSnackBar(result['message'] ?? 'Gửi email thất bại');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _emailError = _getFirebaseErrorMessage(e.code);
      });

      if (mounted) {
        _showErrorSnackBar(_emailError ?? 'Có lỗi xảy ra');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _emailError = 'Lỗi kết nối: ${e.toString()}';
      });

      if (mounted) {
        _showErrorSnackBar('Có lỗi xảy ra, vui lòng thử lại');
      }
    }
  }

  /// Hiển thị thông báo lỗi dưới input
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Hiển thị SnackBar thành công
  void _showSuccessSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Hiển thị SnackBar lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Kiểm tra định dạng email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Lấy thông báo lỗi từ Firebase error code
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau vài phút';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
      default:
        return 'Có lỗi xảy ra. Vui lòng thử lại';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: R.font.sfpro,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                _emailSent
                    ? 'Chúng tôi đã gửi email hướng dẫn đặt lại mật khẩu cho bạn. Vui lòng kiểm tra hộp thư của bạn (bao gồm thư rác).'
                    : 'Nhập email tài khoản của bạn và chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: R.font.sfpro,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              if (!_emailSent) ...[
                // Email input field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  onChanged: (_) {
                    // Xoá lỗi khi user bắt đầu gõ
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Địa chỉ email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
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

                // Send button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      disabledBackgroundColor: const Color(0xFF8B5CF6)
                          .withOpacity(0.5),
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
                            'GỬI EMAIL ĐẶT LẠI MẬT KHẨU',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: R.font.sfpro,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Email sẽ được gửi trong vòng 5 phút. Nếu không nhận được, hãy kiểm tra thư mục spam.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                            fontFamily: R.font.sfpro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Email đã được gửi!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                          fontFamily: R.font.sfpro,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vui lòng kiểm tra email của bạn để theo dõi hướng dẫn đặt lại mật khẩu. Liên kết sẽ hết hạn trong 10 phút.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontFamily: R.font.sfpro,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Send again button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                        _emailController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: Color(0xFF8B5CF6),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'GỬI LẠI EMAIL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                        fontFamily: R.font.sfpro,
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Back to login link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: R.font.sfpro,
                      ),
                      children: [
                        
                        TextSpan(
                          text: 'Quay lại đăng nhập',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 140, 138, 138),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

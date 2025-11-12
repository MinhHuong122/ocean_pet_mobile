import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_pet/services/AuthService.dart';
import 'package:ocean_pet/screens/login_screen.dart';

/// Password Reset Screen - Change password after email verification
class PasswordResetScreen extends StatefulWidget {
  final String email;
  final String resetCode; // OOB code from email link

  const PasswordResetScreen({
    super.key,
    required this.email,
    required this.resetCode,
  });

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Verify reset code and change password
  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (!_validatePassword(newPassword, confirmPassword)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
      _confirmError = null;
    });

    try {
      final result = await AuthService.resetPasswordWithCode(
        widget.resetCode,
        newPassword,
      );

      if (!mounted) return;

      if (result['success']) {
        // ✅ Password reset successful
        _showSuccessDialog(
          'Đặt lại mật khẩu thành công!',
          'Mật khẩu của bạn đã được thay đổi. Vui lòng đăng nhập với mật khẩu mới.',
          () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        );
      } else {
        setState(() {
          _isLoading = false;
          _passwordError = result['message'] ?? 'Đặt lại mật khẩu thất bại';
        });
        _showErrorSnackBar(result['message'] ?? 'Đặt lại mật khẩu thất bại');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = _getFirebaseErrorMessage(e.code);
      });
      if (mounted) {
        _showErrorSnackBar(_passwordError ?? 'Có lỗi xảy ra');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = 'Lỗi kết nối: ${e.toString()}';
      });
      if (mounted) {
        _showErrorSnackBar('Có lỗi xảy ra, vui lòng thử lại');
      }
    }
  }

  /// Validate password and confirm password
  bool _validatePassword(String password, String confirm) {
    // Check if empty
    if (password.isEmpty) {
      setState(() => _passwordError = 'Vui lòng nhập mật khẩu mới');
      _showError('Vui lòng nhập mật khẩu mới');
      return false;
    }

    // Check min length
    if (password.length < 6) {
      setState(() => _passwordError = 'Mật khẩu phải có ít nhất 6 ký tự');
      _showError('Mật khẩu phải có ít nhất 6 ký tự');
      return false;
    }

    // Check confirm empty
    if (confirm.isEmpty) {
      setState(() => _confirmError = 'Vui lòng xác nhận mật khẩu');
      _showError('Vui lòng xác nhận mật khẩu');
      return false;
    }

    // Check match
    if (password != confirm) {
      setState(() {
        _passwordError = null;
        _confirmError = 'Mật khẩu không khớp';
      });
      _showError('Mật khẩu không khớp');
      return false;
    }

    return true;
  }

  /// Get Firebase error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-action-code':
        return 'Mã đặt lại không hợp lệ hoặc đã hết hạn. Vui lòng yêu cầu lại.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa';
      case 'weak-password':
        return 'Mật khẩu không đủ mạnh. Vui lòng sử dụng mật khẩu khác.';
      default:
        return 'Lỗi: $code';
    }
  }

  /// Show error dialog
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog(
    String title,
    String message,
    VoidCallback onOk,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: onOk,
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ Email Verified',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${widget.email}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng nhập mật khẩu mới của bạn bên dưới',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // New Password Field
              Text(
                'Mật khẩu mới',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPasswordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _passwordError,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Password Field
              Text(
                'Xác nhận mật khẩu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(
                          () => _showConfirmPassword = !_showConfirmPassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _confirmError,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Đặt lại mật khẩu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Colors.blue[600]!,
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),

              // Password Requirements
              const SizedBox(height: 32),
              Text(
                'Yêu cầu mật khẩu:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              _buildRequirement('Ít nhất 6 ký tự'),
              _buildRequirement('Không để trống'),
              _buildRequirement('Mật khẩu phải khớp'),
            ],
          ),
        ),
      ),
    );
  }

  /// Build password requirement text
  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

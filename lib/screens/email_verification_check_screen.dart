import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_pet/services/AuthService.dart';
import 'package:ocean_pet/screens/password_reset_screen.dart';

/// Email Verification Check Screen - Verify reset code from email
class EmailVerificationCheckScreen extends StatefulWidget {
  final String email;
  final String resetCode; // OOB code from email link or manual entry

  const EmailVerificationCheckScreen({
    super.key,
    required this.email,
    this.resetCode = '',
  });

  @override
  State<EmailVerificationCheckScreen> createState() =>
      _EmailVerificationCheckScreenState();
}

class _EmailVerificationCheckScreenState
    extends State<EmailVerificationCheckScreen> {
  final _resetCodeController = TextEditingController();
  bool _isVerifying = false;
  String? _codeError;
  String? _verificationMessage;

  @override
  void initState() {
    super.initState();
    // If reset code passed from deep link, auto-verify
    if (widget.resetCode.isNotEmpty) {
      _verifyCode(widget.resetCode);
    }
    _resetCodeController.text = widget.resetCode;
  }

  @override
  void dispose() {
    _resetCodeController.dispose();
    super.dispose();
  }

  /// Verify reset code
  Future<void> _verifyCode(String code) async {
    final resetCode = code.isEmpty ? _resetCodeController.text.trim() : code;

    if (resetCode.isEmpty) {
      setState(() => _codeError = 'Vui lòng nhập hoặc cung cấp mã xác thực');
      _showError('Vui lòng nhập mã xác thực');
      return;
    }

    setState(() {
      _isVerifying = true;
      _codeError = null;
      _verificationMessage = null;
    });

    try {
      final result = await AuthService.verifyResetCode(resetCode);

      if (!mounted) return;

      if (result is Map<String, dynamic>) {
        final resultMap = result as Map<String, dynamic>;
        final isSuccess = resultMap['success'] == true;
        if (isSuccess) {
          // ✅ Code valid - proceed to password reset
          setState(() => _isVerifying = false);

          _showSuccessMessage('Xác thực thành công!');

          // Navigate to password reset screen
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PasswordResetScreen(
                  email: widget.email,
                  resetCode: resetCode,
                ),
              ),
            );
          }
        } else {
          final message = resultMap['message'] ?? 'Xác thực thất bại';
          setState(() {
            _isVerifying = false;
            _verificationMessage = message;
            _codeError = message;
          });
          _showError(message);
        }
      } else {
        setState(() {
          _isVerifying = false;
          _verificationMessage = 'Xác thực thất bại';
          _codeError = 'Xác thực thất bại';
        });
        _showError('Xác thực thất bại');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isVerifying = false;
        _codeError = _getFirebaseErrorMessage(e.code);
        _verificationMessage = _codeError;
      });
      if (mounted) {
        _showError(_codeError ?? 'Có lỗi xảy ra');
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _codeError = 'Lỗi kết nối: ${e.toString()}';
        _verificationMessage = _codeError;
      });
      if (mounted) {
        _showError('Có lỗi xảy ra, vui lòng thử lại');
      }
    }
  }

  /// Get Firebase error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-action-code':
        return 'Mã không hợp lệ hoặc đã hết hạn. Vui lòng yêu cầu email lại.';
      case 'expired-action-code':
        return 'Mã đã hết hạn. Vui lòng yêu cầu email đặt lại mật khẩu mới.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa';
      default:
        return 'Lỗi xác thực: $code';
    }
  }

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isVerifying) return false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Xác thực Email'),
          elevation: 0,
          backgroundColor: Colors.blue[600],
          automaticallyImplyLeading: !_isVerifying,
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
                        '📧 Email Verification',
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
                        widget.resetCode.isEmpty
                            ? 'Nhập mã xác thực từ email để tiếp tục đặt lại mật khẩu'
                            : 'Đang xác thực mã...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Code input section (visible only if no auto-verify)
                if (widget.resetCode.isEmpty) ...[
                  Text(
                    'Mã xác thực',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _resetCodeController,
                    enabled: !_isVerifying,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Dán mã xác thực từ email tại đây\n\n(Mã bắt đầu bằng "oob")',
                      prefixIcon: const Icon(Icons.vpn_key),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _codeError,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  // Auto-verify in progress
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'Đang xác thực mã...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vui lòng chờ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],

                // Verify button (only if no auto-verify or manual entry)
                if (widget.resetCode.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifying
                          ? null
                          : () => _verifyCode(_resetCodeController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Xác thực',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Cancel/Back button
                if (widget.resetCode.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isVerifying ? null : () => Navigator.pop(context),
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

                // Message
                if (_verificationMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _verificationMessage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Help section
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '❓ Cần trợ giúp?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Kiểm tra email (bao gồm thư rác)\n'
                        '2. Tìm email từ "Ocean Pet"\n'
                        '3. Sao chép mã xác thực\n'
                        '4. Dán mã vào trường bên trên\n'
                        '5. Bấm nút "Xác thực"',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[600],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

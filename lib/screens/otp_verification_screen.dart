import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ocean_pet/res/R.dart';
import 'package:ocean_pet/services/AuthService.dart';
import 'package:ocean_pet/screens/login_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({super.key, required this.email});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  int _remainingSeconds = 600; // 10 phút
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 600;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _canResend = true;
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    // Firebase Email Verification - User cần check email và click link
    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra xem email đã được verify chưa
      final isVerified = await AuthService.isEmailVerified();

      if (isVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email đã được xác thực thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Chuyển sang màn hình đăng nhập sau 1 giây
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Email chưa được xác thực. Vui lòng kiểm tra email và click vào link xác thực.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase: Gửi lại email verification
      await AuthService.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi lại email xác thực. Vui lòng kiểm tra hộp thư của bạn.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _startTimer();
        // Xóa các ô nhập
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline,
                  size: 50,
                  color: Color(0xFF8B5CF6),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Xác thực Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: R.font.sfpro,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Chúng tôi đã gửi link xác thực đến',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: R.font.sfpro,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5CF6),
                  fontFamily: R.font.sfpro,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF8B5CF6),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vui lòng kiểm tra email và click vào link xác thực.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontFamily: R.font.sfpro,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sau khi xác thực, quay lại đây và nhấn nút "Kiểm tra xác thực".',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontFamily: R.font.sfpro,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Timer
              Text(
                'Mã hết hạn sau: $_timerText',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      _remainingSeconds <= 60 ? Colors.red : Colors.grey[600],
                  fontFamily: R.font.sfpro,
                ),
              ),

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                          'Kiểm tra xác thực',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: R.font.sfpro,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Không nhận được mã? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                  GestureDetector(
                    onTap: _canResend && !_isLoading ? _resendOTP : null,
                    child: Text(
                      'Gửi lại',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _canResend
                            ? const Color(0xFF8B5CF6)
                            : Colors.grey[400],
                        fontFamily: R.font.sfpro,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Help text
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('💡 Mẹo lấy mã OTP'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '1. Kiểm tra hộp thư Spam/Junk\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Email có thể bị phân loại vào thư rác.\n',
                            ),
                            const Text(
                              '2. Lấy mã từ Console Backend\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Xem terminal backend (nơi chạy npm start), mã OTP sẽ được log ra:\n',
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'OTP: 123456',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            const Text(
                              '3. Sử dụng nút "Gửi lại"\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Đợi hết thời gian và nhấn "Gửi lại" để nhận mã mới.',
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đã hiểu'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Làm sao để lấy mã OTP?',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8B5CF6),
                    decoration: TextDecoration.underline,
                    fontFamily: R.font.sfpro,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

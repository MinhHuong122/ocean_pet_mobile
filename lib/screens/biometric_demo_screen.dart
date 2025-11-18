import 'package:flutter/material.dart';
import 'package:ocean_pet/helpers/BiometricHelper.dart';
import 'package:local_auth/local_auth.dart';

/// Màn hình demo sinh trắc học đơn giản
/// 
/// Để test: Thêm vào welcome_screen hoặc gọi trực tiếp:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => BiometricDemoScreen()))
class BiometricDemoScreen extends StatefulWidget {
  const BiometricDemoScreen({super.key});

  @override
  State<BiometricDemoScreen> createState() => _BiometricDemoScreenState();
}

class _BiometricDemoScreenState extends State<BiometricDemoScreen> {
  String _status = 'Chưa test';
  bool _canAuthenticate = false;
  List<BiometricType> _availableBiometrics = [];
  String _biometricName = 'Sinh trắc học';
  String _biometricIcon = '🔒';

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final canAuth = await BiometricHelper.canAuthenticate();
    final available = await BiometricHelper.getAvailableBiometrics();
    final name = await BiometricHelper.getBiometricName();
    final icon = await BiometricHelper.getBiometricIcon();

    setState(() {
      _canAuthenticate = canAuth;
      _availableBiometrics = available;
      _biometricName = name;
      _biometricIcon = icon;
      _status = canAuth 
        ? '✅ Thiết bị hỗ trợ sinh trắc học\nLoại: $name'
        : '❌ Thiết bị không hỗ trợ sinh trắc học';
    });
  }

  Future<void> _testBiometric() async {
    setState(() {
      _status = '⏳ Đang xác thực...';
    });

    try {
      // GỌI POPUP SINH TRẮC HỌC - Giao diện TỰ ĐỘNG hiện
      final success = await BiometricHelper.authenticate(
        reason: 'Test sinh trắc học Ocean Pet',
        biometricOnly: false, // Cho phép PIN/Pattern backup
      );

      setState(() {
        if (success) {
          _status = '✅ XÁC THỰC THÀNH CÔNG!\n\n'
                   'Popup sinh trắc học đã hiện và bạn đã xác thực thành công.\n'
                   'Trong app thật, đây là lúc đăng nhập với password 123456.';
        } else {
          _status = '❌ Xác thực thất bại\n\n'
                   'User đã cancel hoặc không match.';
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Lỗi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Demo Sinh Trắc Học'),
        backgroundColor: const Color(0xFF8E97FD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _canAuthenticate 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _canAuthenticate ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _biometricIcon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Thông tin:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• Hỗ trợ: ${_canAuthenticate ? "Có" : "Không"}'),
                  Text('• Loại: $_biometricName'),
                  Text('• Số lượng: ${_availableBiometrics.length}'),
                  if (_availableBiometrics.isNotEmpty)
                    Text('• Methods: ${_availableBiometrics.map((e) => e.name).join(", ")}'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Test Button
            ElevatedButton.icon(
              onPressed: _canAuthenticate ? _testBiometric : null,
              icon: Text(_biometricIcon, style: const TextStyle(fontSize: 24)),
              label: Text(
                'Test $_biometricName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E97FD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 12),

            // Refresh Button
            OutlinedButton.icon(
              onPressed: _checkBiometric,
              icon: const Icon(Icons.refresh),
              label: const Text('Kiểm tra lại'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '💡 Hướng dẫn:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Đảm bảo thiết bị đã có vân tay/Face ID\n'
                    '2. Vào Settings > Security để thêm\n'
                    '3. Nhấn nút "Test" để xem popup\n'
                    '4. Popup sinh trắc học sẽ TỰ ĐỘNG hiện\n'
                    '5. Bạn KHÔNG cần code UI gì thêm!',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

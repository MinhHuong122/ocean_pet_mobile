import 'package:flutter/material.dart';
import 'package:ocean_pet/res/R.dart';
import 'package:ocean_pet/services/AuthService.dart';
import 'package:ocean_pet/screens/choose_pet_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userId = await AuthService.getUserId();
      // Mock user data based on userId
      setState(() {
        if (userId == '1') {
          _userName = 'Admin';
        } else if (userId == '2') {
          _userName = 'bạn';
        } else {
          _userName = 'Bạn';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userName = 'Bạn';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8E97FD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Ocean Pet (bigger, centered, no border)
                  Image.asset(
                    'lib/res/drawables/setting/LOGO.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.pets,
                        size: 60,
                        color: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Ocean Pet',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else ...[
                    Text(
                      'Chào mừng đến với Ocean Pet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: R.font.sfpro,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Khám phá ứng dụng, tìm hiểu cách chăm sóc thú cưng của bạn một cách tốt nhất.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: R.font.sfpro,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Pet illustration (centered, no border)
                  Image.asset(
                    'lib/res/drawables/setting/LOG_2.png',
                    width: 220,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Get started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ChoosePetScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'BẮT ĐẦU',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: R.font.sfpro,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

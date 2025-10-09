import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocean_pet/res/R.dart';
import 'package:ocean_pet/screens/login_screen.dart';
import 'package:ocean_pet/screens/register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Logo Ocean Pet
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ocean Pet',
                    style: GoogleFonts.aclonica(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Image.asset(
                    'lib/res/drawables/setting/LOGO.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 24,
                          color: Color.fromARGB(255, 236, 236, 236),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Illustration
              Center(
                child: Image.asset(
                  'lib/res/drawables/setting/LOG.jpg',
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 220,
                    height: 220,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title and description
              Text(
                'Mỗi hành động chăm sóc đều viết nên câu chuyện đẹp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: R.font.sfpro,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Hàng ngàn người đang sử dụng Ocean Pet để chăm sóc thú cưng của họ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: R.font.sfpro,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Sign up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    'ĐĂNG KÝ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Login link
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
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
                      const TextSpan(text: 'ĐÃ CÓ TÀI KHOẢN? '),
                      TextSpan(
                        text: 'ĐĂNG NHẬP',
                        style: TextStyle(
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

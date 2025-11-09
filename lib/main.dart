import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ocean_pet/res/R.dart';
import 'package:ocean_pet/screens/onboarding_screen.dart';
import 'package:ocean_pet/screens/login_screen.dart';
import 'package:ocean_pet/screens/home_screen.dart';
import 'package:ocean_pet/services/AuthService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

// Hàm kiểm tra backend đã chạy chưa (không còn cần thiết với Firebase)
Future<bool> checkBackendConnection() async {
  try {
    await http
        .get(Uri.parse(
            'http://10.0.2.2:3000')) // Sử dụng 10.0.2.2 cho Android emulator
        .timeout(Duration(seconds: 3));
    print('✅ Backend đã kết nối thành công!');
    return true;
  } catch (e) {
    print(
        '⚠️ Firebase đang được sử dụng thay vì backend Node.js cục bộ.');
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kiểm tra kết nối backend tự động
  await checkBackendConnection();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocean Pet',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Tiếng Việt
        Locale('en', 'US'), // English
      ],
      locale: const Locale('vi', 'VN'), // Mặc định tiếng Việt
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6), // Purple theme like Silent Moon
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: R.font.sfpro,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    // For demo purposes, we'll always show onboarding first
    // In real app, you would check SharedPreferences for onboarding status
    setState(() {
      _isLoggedIn = isLoggedIn;
      _hasSeenOnboarding = false; // Always show onboarding for demo
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    return _isLoggedIn ? HomeScreen() : const LoginScreen();
  }
}

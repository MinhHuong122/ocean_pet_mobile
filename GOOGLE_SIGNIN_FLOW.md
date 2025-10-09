# Cách hoạt động của Google Sign-In với Firebase

## Luồng đăng nhập (Authentication Flow)

```
1. User nhấn nút "TIẾP TỤC VỚI GOOGLE"
   ↓
2. App mở Google Sign-In dialog
   ↓
3. User chọn tài khoản Google
   ↓
4. Google trả về accessToken và idToken
   ↓
5. App sử dụng tokens để tạo Firebase credential
   ↓
6. Firebase xác thực credential
   ↓
7. Firebase trả về UserCredential với user info
   ↓
8. App lưu Firebase token và userId vào SharedPreferences
   ↓
9. Chuyển đến WelcomeScreen
```

## Code Flow trong AuthService.dart

### 1. Khởi tạo Google Sign-In
```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);
```

### 2. Đăng nhập với Google
```dart
final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
```
- Mở dialog chọn tài khoản Google
- User chọn tài khoản
- Trả về `GoogleSignInAccount` hoặc `null` (nếu user hủy)

### 3. Lấy thông tin xác thực từ Google
```dart
final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
```
- Lấy `accessToken` và `idToken` từ Google

### 4. Tạo Firebase credential
```dart
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
```
- Chuyển đổi Google tokens thành Firebase credential

### 5. Đăng nhập vào Firebase
```dart
final UserCredential userCredential = 
    await FirebaseAuth.instance.signInWithCredential(credential);
```
- Firebase xác thực credential
- Nếu user chưa tồn tại → tự động tạo mới
- Nếu user đã tồn tại → đăng nhập

### 6. Lấy Firebase token
```dart
final String? firebaseToken = await userCredential.user?.getIdToken();
```
- Firebase token dùng để xác thực API calls sau này

### 7. Lưu trạng thái đăng nhập
```dart
await saveLoginState(firebaseToken, userCredential.user!.uid);
```
- Lưu token và userId vào SharedPreferences
- App sẽ kiểm tra các giá trị này khi khởi động

## Thông tin User từ Firebase

Sau khi đăng nhập thành công, bạn có thể lấy:

```dart
User? user = userCredential.user;

// Thông tin cơ bản
String uid = user!.uid;                    // Firebase User ID (unique)
String? email = user.email;                // Email
String? displayName = user.displayName;    // Tên hiển thị
String? photoURL = user.photoURL;          // Ảnh đại diện

// Token để gọi API
String? token = await user.getIdToken();   // Firebase ID Token
```

## Sử dụng trong UI (login_screen.dart)

```dart
Future<void> _loginWithGoogle() async {
  setState(() {
    _isLoading = true;  // Hiển thị loading
  });
  
  try {
    // Gọi AuthService
    final result = await AuthService.loginWithGoogle();
    
    if (result['success']) {
      // Đăng nhập thành công
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      // Đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  } catch (e) {
    // Xử lý lỗi
  } finally {
    setState(() {
      _isLoading = false;  // Tắt loading
    });
  }
}
```

## Security Best Practices

### 1. Firebase Token Validation
```dart
// Token tự động hết hạn sau 1 giờ
// Firebase SDK tự động refresh token khi cần
```

### 2. Logout đúng cách
```dart
static Future<void> logout() async {
  // 1. Xóa local data
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  // 2. Đăng xuất khỏi Firebase
  await FirebaseAuth.instance.signOut();
  
  // 3. Đăng xuất khỏi Google
  await GoogleSignIn().signOut();
}
```

### 3. Kiểm tra trạng thái đăng nhập
```dart
static Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_logged_in') ?? false;
}
```

## Testing

### Test trên Android
```bash
flutter run
```

### Test trên iOS
```bash
flutter run -d ios
```

### Debug mode
```bash
flutter run -v  # Xem logs chi tiết
```

## Common Use Cases

### 1. Auto-login khi app khởi động
```dart
// Trong main.dart hoặc splash screen
if (await AuthService.isLoggedIn()) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => WelcomeScreen()),
  );
}
```

### 2. Lấy user hiện tại
```dart
User? currentUser = FirebaseAuth.instance.currentUser;
if (currentUser != null) {
  print('User đang đăng nhập: ${currentUser.email}');
}
```

### 3. Refresh token
```dart
String? newToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
```

### 4. Listen to auth state changes
```dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    print('User đã đăng xuất');
  } else {
    print('User đã đăng nhập: ${user.email}');
  }
});
```

## Error Handling

### 1. User hủy đăng nhập
```dart
if (googleUser == null) {
  return {
    'success': false,
    'message': 'Đăng nhập Google bị hủy',
  };
}
```

### 2. Network error
```dart
try {
  // ... login code
} catch (e) {
  return {
    'success': false,
    'message': 'Lỗi đăng nhập Google: $e',
  };
}
```

### 3. Firebase errors
- `user-disabled`: Tài khoản bị vô hiệu hóa
- `user-not-found`: Không tìm thấy user
- `invalid-credential`: Credential không hợp lệ
- `operation-not-allowed`: Google Sign-In chưa được bật trong Firebase

## Next Steps

1. ✅ Cấu hình Firebase Console
2. ✅ Thêm `google-services.json` vào `android/app/`
3. ✅ Cập nhật `build.gradle` files
4. ✅ Chạy `flutter pub get`
5. ✅ Test đăng nhập trên thiết bị/emulator

## Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Auth Flutter](https://pub.dev/packages/firebase_auth)

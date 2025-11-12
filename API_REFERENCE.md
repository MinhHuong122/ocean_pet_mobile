# API Reference - Quên Mật Khẩu & Đăng Nhập Nhanh

## QuickLoginService

### Biometric Management

#### `isBiometricAvailable()`
Kiểm tra thiết bị có hỗ trợ sinh trắc học (Face ID hoặc Fingerprint)

```dart
bool available = await QuickLoginService.isBiometricAvailable();
if (available) {
  // Device hỗ trợ biometric
}
```

**Returns**: `Future<bool>`

---

#### `getAvailableBiometrics()`
Lấy danh sách các phương thức sinh trắc học có sẵn trên thiết bị

```dart
List<BiometricType> biometrics = await QuickLoginService.getAvailableBiometrics();

// Kiểm tra Face ID
if (biometrics.contains(BiometricType.face)) {
  // Device có Face ID
}

// Kiểm tra Fingerprint
if (biometrics.contains(BiometricType.fingerprint)) {
  // Device có Fingerprint
}
```

**Returns**: `Future<List<BiometricType>>`

**BiometricType Values**:
- `BiometricType.face` - Face ID (iOS, Android 10+)
- `BiometricType.fingerprint` - Fingerprint (Android, iOS)
- `BiometricType.iris` - Iris recognition (hiếm)
- `BiometricType.weak` - Weak biometric (lock screen)

---

### Credential Management

#### `saveCredentials()`
Lưu email, password, và cài đặt biometric vào Secure Storage + SharedPreferences

```dart
await QuickLoginService.saveCredentials(
  email: 'user@example.com',
  password: 'hashedPassword123',
  enableBiometric: true,
);
```

**Parameters**:
- `email` (String, required): Email người dùng
- `password` (String, required): Password (Firebase đã hash trước)
- `enableBiometric` (bool, required): Enable Face ID/Fingerprint?

**Throws**: Có thể throw exception nếu storage bị từ chối

**Usage**:
```dart
// Sau khi đăng nhập thành công
final result = await AuthService.login(email, password);
if (result['success']) {
  await QuickLoginService.saveCredentials(
    email: email,
    password: password,
    enableBiometric: false, // User có thể enable sau
  );
}
```

---

#### `getSavedEmail()`
Lấy email đã lưu từ Secure Storage

```dart
String? email = await QuickLoginService.getSavedEmail();
if (email != null) {
  print('Saved email: $email');
}
```

**Returns**: `Future<String?>` (null nếu chưa lưu)

---

#### `getCredentials()`
Lấy cả email và password từ Secure Storage (sau khi xác thực biometric)

```dart
// Sau khi user xác thực biometric thành công
Map<String, String>? credentials = await QuickLoginService.getCredentials();

if (credentials != null) {
  final email = credentials['email'];
  final password = credentials['password'];
  // Đăng nhập với credentials này
}
```

**Returns**: `Future<Map<String, String>?>` 
```dart
{
  'email': 'user@example.com',
  'password': 'hashedPassword123',
}
```

---

#### `clearCredentials()`
Xóa tất cả thông tin đăng nhập và cài đặt (thường gọi khi logout)

```dart
// Khi user logout
await AuthService.logout();
await QuickLoginService.clearCredentials();
```

**Effect**:
- Xóa email từ Secure Storage
- Xóa password từ Secure Storage
- Set `has_logged_in_before` = false
- Set `quick_login_biometric_enabled` = false

---

### Query Methods

#### `hasLoggedInBefore()`
Kiểm tra user đã đăng nhập trước đó chưa (để quyết định show QuickLoginScreen hay LoginScreen)

```dart
bool hasLoggedIn = await QuickLoginService.hasLoggedInBefore();

if (hasLoggedIn) {
  // Show QuickLoginScreen
  navigator.push(QuickLoginScreen());
} else {
  // Show LoginScreen
  navigator.push(LoginScreen());
}
```

**Returns**: `Future<bool>` (từ SharedPreferences key `has_logged_in_before`)

**Used in**: `lib/main.dart` (AuthWrapper)

---

#### `isBiometricEnabled()`
Kiểm tra user đã enable Face ID/Fingerprint chưa

```dart
bool enabled = await QuickLoginService.isBiometricEnabled();

if (enabled) {
  // Show biometric button
  showBiometricButton();
} else {
  // Show password input only
  showPasswordInput();
}
```

**Returns**: `Future<bool>` (từ SharedPreferences key `quick_login_biometric_enabled`)

---

### Biometric Authentication

#### `authenticateWithBiometric()`
Thực hiện xác thực Face ID/Fingerprint

```dart
bool isAuthenticated = await QuickLoginService.authenticateWithBiometric();

if (isAuthenticated) {
  // Get credentials và login
  Map<String, String>? creds = await QuickLoginService.getCredentials();
  if (creds != null) {
    await AuthService.login(creds['email']!, creds['password']!);
  }
} else {
  // Xác thực thất bại - show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Xác thực thất bại')),
  );
}
```

**Returns**: `Future<bool>`
- `true`: Xác thực thành công
- `false`: Xác thực thất bại hoặc user huỷ

**Options**:
```dart
// Bên trong method:
AuthenticationOptions(
  stickyAuth: true,      // Tiếp tục khi app bị tạm dừng
  biometricOnly: true,   // Không dùng PIN/Pattern
)
```

**Error Handling**:
- User huỷ → false
- Device không hỗ trợ → Exception
- Permission bị từ chối → Exception

---

### Settings Management

#### `enableBiometric()`
Enable Face ID/Fingerprint quick login

```dart
await QuickLoginService.enableBiometric();
// Sau đó QuickLoginScreen sẽ show biometric button
```

---

#### `disableBiometric()`
Disable Face ID/Fingerprint quick login

```dart
await QuickLoginService.disableBiometric();
// Sau đó QuickLoginScreen chỉ show password input
```

---

## AuthService - OTP Methods

### Password Reset Flow

#### `generateAndSendOTP()`
Gửi email reset password với Firebase

```dart
final result = await AuthService.generateAndSendOTP('user@example.com');

if (result['success']) {
  // Email đã gửi
  print(result['message']); 
  // "Đã gửi email đặt lại mật khẩu..."
} else {
  // Error
  print(result['message']); 
  // "Không tìm thấy tài khoản..."
}
```

**Returns**: 
```dart
{
  'success': true/false,
  'message': 'Đã gửi email...' or 'Lỗi...'
}
```

**Error Codes**:
- `user-not-found`: Email không tồn tại
- `invalid-email`: Email format sai
- `too-many-requests`: Quá nhiều yêu cầu (rate limit)

**Flow**:
1. Verify email tồn tại trong Firebase
2. Firebase gửi email reset (tự động)
3. Lưu tracking info vào Firestore (optional)
4. Return success message

---

#### `resetPasswordWithCode()`
Đặt lại mật khẩu bằng OOB Code từ email

```dart
final result = await AuthService.resetPasswordWithCode(
  oobCode: 'ABC123XYZ', // Từ email link
  newPassword: 'newPassword123',
);

if (result['success']) {
  // Mật khẩu đã được reset
  print(result['message']); 
  // "Đặt lại mật khẩu thành công..."
  
  // Chuyển user tới LoginScreen
  Navigator.pushReplacement(LoginScreen());
} else {
  // Error
  print(result['message']); 
  // "Đường dẫn không hợp lệ hoặc đã hết hạn"
}
```

**Parameters**:
- `oobCode` (String): Code từ email reset
- `newPassword` (String): Mật khẩu mới (tối thiểu 6 ký tự)

**Returns**: 
```dart
{
  'success': true/false,
  'message': 'Đặt lại mật khẩu thành công...' or 'Lỗi...'
}
```

**Error Codes**:
- `invalid-action-code`: Code không hợp lệ
- `expired-action-code`: Code đã hết hạn (10 phút)
- `weak-password`: Password quá yếu (<6 ký tự)
- `user-disabled`: Account bị vô hiệu hóa

---

#### `verifyResetCode()`
Xác minh OOB Code có hợp lệ không (optional)

```dart
bool isValid = await AuthService.verifyResetCode('ABC123XYZ');

if (isValid) {
  // Code hợp lệ - cho phép nhập mật khẩu mới
} else {
  // Code không hợp lệ - show error
  showError('Đường dẫn không hợp lệ');
}
```

**Returns**: `Future<bool>`

---

## Complete Usage Example

### Quên Mật Khẩu Flow

```dart
// Step 1: User click "Quên mật khẩu?"
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
);

// Step 2: ForgotPasswordScreen - Gửi email
final result = await AuthService.generateAndSendOTP(email);

// Step 3: Email mở link → app nhận via app_links
// Firebase tự động verify code

// Step 4: User nhập mật khẩu mới
final resetResult = await AuthService.resetPasswordWithCode(
  oobCode: codeFromEmail,
  newPassword: newPassword,
);

// Step 5: Quay lại LoginScreen
Navigator.pushReplacement(LoginScreen());
```

---

### Quick Login Flow

```dart
// Step 1: First Time - Normal Login
final loginResult = await AuthService.login(email, password);

// Step 2: Lưu credentials
await QuickLoginService.saveCredentials(
  email: email,
  password: password,
  enableBiometric: true,
);

// Step 3: Logout
await AuthService.logout();
await QuickLoginService.clearCredentials();

// Step 4: Next Time - QuickLoginScreen
bool hasLoggedBefore = await QuickLoginService.hasLoggedInBefore();

// Step 5: User xác thực biometric
bool isAuth = await QuickLoginService.authenticateWithBiometric();

// Step 6: Lấy credentials
if (isAuth) {
  Map<String, String>? creds = await QuickLoginService.getCredentials();
  final result = await AuthService.login(creds['email']!, creds['password']!);
}
```

---

## Error Handling Best Practices

### Quên Mật Khẩu

```dart
try {
  final result = await AuthService.generateAndSendOTP(email);
  
  if (result['success']) {
    setState(() => _emailSent = true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Có lỗi xảy ra: $e')),
  );
}
```

### Quick Login

```dart
try {
  final isAuthenticated = await QuickLoginService.authenticateWithBiometric();
  
  if (isAuthenticated) {
    final credentials = await QuickLoginService.getCredentials();
    // Đăng nhập...
  }
} on PlatformException catch (e) {
  print('Biometric error: ${e.code}');
  // NotAvailable, NotEnrolled, LockedOut, etc.
} catch (e) {
  print('Error: $e');
}
```

---

## SharedPreferences Keys

```dart
// QuickLoginService keys
'has_logged_in_before'                // bool
'quick_login_biometric_enabled'       // bool  
'biometric_available'                 // bool
```

## Secure Storage Keys

```dart
// QuickLoginService keys
'quick_login_email'     // string
'quick_login_password'  // string
```

---

## Constants & Timeouts

```dart
// Firebase OTP
const OTP_TIMEOUT = Duration(minutes: 10); // Link hết hạn
const OTP_RESEND_THROTTLE = Duration(seconds: 60); // Chế độ throttle

// Biometric
const BIOMETRIC_AUTH_TIMEOUT = Duration(seconds: 30);
```

---

## Platform-Specific Notes

### Android
- Biometric library: androidx.biometric:biometric:1.1.0
- Keystore: Android Keystore System
- Face ID: Android 10+
- Fingerprint: Android 6.0+

### iOS
- Biometric: Local Authentication framework
- Keychain: iOS Keychain
- Face ID: iOS 11.2+
- Touch ID: iOS 8.0+

---

## Testing Checklist

- [ ] `isBiometricAvailable()` returns true/false correctly
- [ ] `getAvailableBiometrics()` returns correct types
- [ ] `saveCredentials()` persists data
- [ ] `getCredentials()` retrieves correctly
- [ ] `clearCredentials()` removes all data
- [ ] `authenticateWithBiometric()` shows prompt
- [ ] `generateAndSendOTP()` sends email
- [ ] `resetPasswordWithCode()` works with valid code
- [ ] Error handling catches all cases

---

**Phiên bản API**: 1.0.0  
**Cập nhật**: November 2025

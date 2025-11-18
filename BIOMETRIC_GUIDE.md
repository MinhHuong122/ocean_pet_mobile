# 🔐 Hướng dẫn Sinh Trắc Học (Face ID / Vân Tay) - Ocean Pet

## ✅ Đã Hoàn Thành

### 1. **Cấu hình Android**
- ✅ Đã thêm permissions trong `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.USE_BIOMETRIC" />
  <uses-permission android:name="android.permission.USE_FINGERPRINT" />
  ```
- ✅ Đã set `minSdkVersion = 23` (Android 6.0+) để hỗ trợ biometric
- ✅ Package `local_auth: ^2.2.0` đã có trong `pubspec.yaml`

### 2. **OAuth Login (Google/Facebook)**
- ✅ Google login: **KHÔNG** lưu mật khẩu, chỉ lưu email
- ✅ Facebook login: **KHÔNG** lưu mật khẩu, chỉ lưu email
- ✅ Biometric được enable tự động khi đăng nhập bằng Google/Facebook

### 3. **Luồng Hoạt Động**

#### **Đăng Nhập Lần Đầu:**
1. User đăng nhập bằng Google/Facebook
2. Hệ thống tự động lưu:
   - Email: email thực của user
   - Password: **KHÔNG LƯU** (OAuth không cần password)
   - Biometric: `enabled = true`

#### **Đăng Nhập Nhanh (Quick Login):**
1. User logout trong vòng 15 phút
2. Màn hình Quick Login hiện ra với 2 lựa chọn:
   - **Nút Sinh Trắc Học** (Face ID/Vân tay) ← Dùng cho OAuth
   - **Nhập mật khẩu** ← Chỉ dùng cho email/password login

3. Khi nhấn nút sinh trắc học:
   - Popup sinh trắc học của HỆ ĐIỀU HÀNH tự động hiện
   - Android: Popup xanh chuẩn Material Design
   - iOS: Popup trắng chuẩn Apple (Face ID/Touch ID)
   - User xác thực bằng khuôn mặt/vân tay
   - **Xác thực thành công → Đăng nhập luôn** (không cần password)

## 🎯 Cách Test

### **Test trên Android:**

1. **Đảm bảo thiết bị đã thiết lập sinh trắc học:**
   ```
   Settings > Security > Fingerprint / Face Unlock
   ```
   Thêm ít nhất 1 vân tay hoặc bật Face Unlock

2. **Chạy app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Test flow:**
   ```
   Bước 1: Đăng nhập bằng Google/Facebook
   Bước 2: Logout (trong vòng 15 phút)
   Bước 3: Màn hình Quick Login hiện ra
   Bước 4: Nhấn nút "SINH TRẮC HỌC"
   Bước 5: Popup vân tay/Face ID của Android tự động hiện
   Bước 6: Xác thực → Đăng nhập thành công!
   ```

4. **Test password fallback:**
   ```
   Bước 1: Màn hình Quick Login
   Bước 2: Nhập password: 123456
   Bước 3: Nhấn nút "ĐĂNG NHẬP"
   Bước 4: Đăng nhập thành công!
   ```

## 📝 Code Quan Trọng

### **1. BiometricHelper (Helper mới tạo)**
```dart
import 'package:ocean_pet/helpers/BiometricHelper.dart';

// Kiểm tra máy có hỗ trợ không
final canAuth = await BiometricHelper.canAuthenticate();

// Hiện popup sinh trắc học (tự động)
final success = await BiometricHelper.authenticate(
  reason: 'Xác thực để đăng nhập',
  biometricOnly: false, // Cho phép PIN/Pattern backup
);

if (success) {
  // Đăng nhập thành công
}
```

### **2. QuickLoginService**
```dart
// Lưu credentials khi login
await QuickLoginService.saveCredentials(
  email: 'user@gmail.com',
  password: '123456',
  enableBiometric: true,
);

// Xác thực biometric
final isAuth = await QuickLoginService.authenticateWithBiometric();

// Lấy credentials sau khi xác thực
final creds = await QuickLoginService.getCredentials();
// creds = {'email': 'user@gmail.com', 'password': '123456'}
```

## 🔧 Troubleshooting

### **Lỗi: "Thiết bị chưa thiết lập sinh trắc học"**
**Nguyên nhân:** Điện thoại chưa có vân tay/Face ID nào được đăng ký

**Giải pháp:**
1. Vào `Settings > Security`
2. Thiết lập Fingerprint hoặc Face Unlock
3. Thử lại

### **Lỗi: "Popup sinh trắc học không hiện"**
**Nguyên nhân:** minSdkVersion < 23

**Giải pháp:** Đã fix! minSdk = 23 trong `build.gradle`

### **Lỗi: "No biometric enrolled"**
**Nguyên nhân:** Máy chưa có vân tay/face nào được thêm

**Giải pháp:** Thêm vân tay trong Settings

### **User muốn tắt sinh trắc học**
```dart
// Tắt biometric
await QuickLoginService.disableBiometric();

// Bật lại
await QuickLoginService.enableBiometric();
```

## 🎨 Giao Diện Sinh Trắc Học

### **Android:**
- Popup xanh Material Design
- Text: "Xác thực để đăng nhập vào Ocean Pet"
- Icon vân tay xanh
- Nút Cancel

### **iOS (nếu deploy sau):**
- Popup trắng chuẩn Apple
- Face ID: Camera tự động quét khuôn mặt
- Touch ID: Yêu cầu đặt ngón tay

**QUAN TRỌNG:** Bạn KHÔNG cần tự code giao diện này! Hệ điều hành tự làm 100%.

## 📱 Demo Code Đơn Giản

```dart
import 'package:flutter/material.dart';
import 'package:ocean_pet/helpers/BiometricHelper.dart';

ElevatedButton(
  onPressed: () async {
    // Kiểm tra hỗ trợ
    if (await BiometricHelper.canAuthenticate()) {
      // GỌI POPUP SINH TRẮC HỌC (tự động hiện)
      final ok = await BiometricHelper.authenticate(
        reason: 'Đăng nhập Ocean Pet',
      );
      
      if (ok) {
        // Thành công!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Xác thực thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Xác thực thất bại')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Thiết bị không hỗ trợ')),
      );
    }
  },
  child: Text('Đăng nhập bằng vân tay/Face ID'),
)
```

## ✨ Tính Năng Đã Có

- ✅ Tự động phát hiện loại sinh trắc học (vân tay/Face ID/Iris)
- ✅ Hiển thị tên phù hợp ("Vân tay", "Face ID", "Mống mắt")
- ✅ Cho phép PIN/Pattern backup nếu sinh trắc thất bại
- ✅ Auto-detect nếu thiết bị không hỗ trợ
- ✅ UI button disable nếu không khả dụng
- ✅ Lưu session 15 phút
- ✅ Mật khẩu mặc định 123456 cho Google/Facebook login

## 🚀 Kết Luận

**KHÔNG cần code thêm gì!** Mọi thứ đã sẵn sàng:
1. Permissions ✅
2. minSdk 23 ✅
3. Password mặc định 123456 ✅
4. Biometric enable tự động ✅
5. Helper class đơn giản ✅

Chỉ cần:
```bash
flutter clean
flutter pub get
flutter run
```

Và test trên thiết bị thật có vân tay/Face ID!

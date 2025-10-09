# Tóm tắt tích hợp Firebase - Ocean Pet

## ✅ Đã hoàn thành

1. **Đã cài đặt các packages cần thiết:**
   - `firebase_core: ^2.32.0` - Core Firebase functionality
   - `firebase_auth: ^4.20.0` - Firebase Authentication
   - `google_sign_in: ^6.2.2` - Google Sign-In

2. **Đã cập nhật code:**
   - ✅ `lib/main.dart` - Khởi tạo Firebase
   - ✅ `lib/services/AuthService.dart` - Tích hợp Firebase Auth cho Google Sign-In
   - ✅ `pubspec.yaml` - Thêm dependencies

## 📋 Các bước tiếp theo (QUAN TRỌNG)

### Bước 1: Tạo dự án Firebase
1. Truy cập https://console.firebase.google.com/
2. Tạo dự án mới hoặc sử dụng dự án có sẵn
3. Bật **Authentication** → **Google Sign-In**

### Bước 2: Cấu hình Android

#### 2.1. Lấy SHA-1 Certificate
Chạy lệnh sau trong PowerShell:

```powershell
cd android
./gradlew signingReport
```

Hoặc:

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Copy giá trị SHA-1 (dạng: `AA:BB:CC:...`)

#### 2.2. Thêm App Android vào Firebase
1. Vào Firebase Console → Project Settings → Add app → Android
2. Điền:
   - **Package name**: Xem trong `android/app/build.gradle` (dòng `applicationId`)
   - **SHA-1 certificate**: Dán SHA-1 vừa lấy

#### 2.3. Tải google-services.json
1. Tải file `google-services.json` từ Firebase Console
2. Copy vào: `android/app/google-services.json`

#### 2.4. Cập nhật build.gradle files

**File: `android/build.gradle`**
Thêm vào phần `dependencies`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

**File: `android/app/build.gradle`**
Thêm vào cuối file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Và trong phần `defaultConfig`:
```gradle
defaultConfig {
    minSdkVersion 21  // Tối thiểu Android 5.0
    multiDexEnabled true
}
```

### Bước 3: Build và chạy

```powershell
flutter clean
flutter pub get
flutter run
```

## 🧪 Kiểm tra hoạt động

1. Mở app
2. Nhấn "TIẾP TỤC VỚI GOOGLE"
3. Chọn tài khoản Google
4. Đăng nhập thành công → Chuyển đến WelcomeScreen
5. Kiểm tra Firebase Console → Authentication → Users

## 📝 Tài liệu chi tiết

Xem file `FIREBASE_SETUP_GUIDE.md` để có hướng dẫn đầy đủ và xử lý lỗi.

## ⚠️ Lưu ý quan trọng

- **SHA-1 certificate** là BẮT BUỘC để Google Sign-In hoạt động trên Android
- File `google-services.json` phải nằm đúng trong `android/app/`
- Package name trong Firebase phải khớp với `applicationId` trong `build.gradle`
- Nếu gặp lỗi, xem phần "Xử lý lỗi thường gặp" trong `FIREBASE_SETUP_GUIDE.md`

## 🔧 Các thay đổi trong code

### AuthService.dart
- Thêm import `firebase_auth`
- Method `loginWithGoogle()` giờ sử dụng Firebase Authentication
- Method `registerWithGoogle()` cũng sử dụng Firebase (tự động tạo user mới)
- Method `logout()` đăng xuất khỏi cả Firebase và Google Sign-In

### main.dart
- Thêm `Firebase.initializeApp()` trong hàm `main()`
- Thêm `WidgetsFlutterBinding.ensureInitialized()` trước khi khởi tạo Firebase

## 🚀 Ưu điểm của Firebase Authentication

1. **Bảo mật cao**: Token được quản lý tự động bởi Firebase
2. **Dễ mở rộng**: Có thể thêm nhiều phương thức đăng nhập khác (Facebook, Apple, Email...)
3. **Miễn phí**: Firebase Authentication có quota miễn phí rất lớn
4. **Backend sẵn có**: Không cần viết API backend cho authentication

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra lại SHA-1 certificate trong Firebase Console
2. Đảm bảo `google-services.json` đã được copy đúng vị trí
3. Clean project và rebuild: `flutter clean && flutter pub get`
4. Xem logs chi tiết: `flutter run -v`

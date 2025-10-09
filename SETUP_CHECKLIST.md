# ✅ Firebase Setup Checklist

## Bước 1: Chuẩn bị môi trường ✓

- [x] Flutter SDK đã cài đặt
- [x] Android Studio đã cài đặt
- [x] Tài khoản Google có sẵn
- [x] Dependencies đã được thêm vào `pubspec.yaml`
- [x] Code đã được cập nhật

## Bước 2: Firebase Console 🔥

### 2.1 Tạo Project
- [ ] Truy cập https://console.firebase.google.com/
- [ ] Nhấn "Add project"
- [ ] Đặt tên project: `ocean-pet` (hoặc tên khác)
- [ ] Tắt/Bật Google Analytics (tùy chọn)
- [ ] Nhấn "Create project"

### 2.2 Bật Authentication
- [ ] Vào **Authentication** trong menu bên trái
- [ ] Chọn tab **Sign-in method**
- [ ] Nhấn vào **Google** trong danh sách
- [ ] Bật toggle **Enable**
- [ ] Chọn email hỗ trợ
- [ ] Nhấn **Save**

## Bước 3: Cấu hình Android 📱

### 3.1 Lấy Package Name
- [ ] Mở file: `android/app/build.gradle`
- [ ] Tìm dòng `applicationId` (ví dụ: `com.example.ocean_pet`)
- [ ] Copy package name này

### 3.2 Lấy SHA-1 Certificate

**Chọn một trong hai cách:**

**Cách 1: Dùng Gradle**
```powershell
cd android
./gradlew signingReport
```
- [ ] Chạy lệnh trên
- [ ] Tìm dòng `SHA1:` trong output
- [ ] Copy giá trị SHA-1

**Cách 2: Dùng Keytool**
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```
- [ ] Chạy lệnh trên
- [ ] Tìm dòng `SHA1:`
- [ ] Copy giá trị SHA-1

### 3.3 Đăng ký Android App trong Firebase
- [ ] Vào Firebase Console → Project Settings
- [ ] Nhấn icon Android ở phần "Your apps"
- [ ] Dán **Package name** vào ô đầu tiên
- [ ] Dán **SHA-1 certificate** vào ô thứ hai
- [ ] Đặt **App nickname** (tùy chọn): `Ocean Pet Android`
- [ ] Nhấn **Register app**

### 3.4 Download google-services.json
- [ ] Nhấn **Download google-services.json**
- [ ] Lưu file vào máy

### 3.5 Copy google-services.json vào project
- [ ] Mở thư mục `android/app/` trong project
- [ ] Copy file `google-services.json` vào đây
- [ ] Kiểm tra đường dẫn: `android/app/google-services.json`

### 3.6 Cập nhật android/build.gradle
- [ ] Mở file `android/build.gradle`
- [ ] Tìm block `buildscript { dependencies { ... } }`
- [ ] Thêm dòng này vào trong `dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

**Ví dụ đầy đủ:**
```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // ← Thêm dòng này
    }
}
```
- [ ] Save file

### 3.7 Cập nhật android/app/build.gradle
- [ ] Mở file `android/app/build.gradle`
- [ ] Cuộn xuống cuối file
- [ ] Thêm dòng này ở cuối cùng:
```gradle
apply plugin: 'com.google.gms.google-services'
```

- [ ] Tìm block `defaultConfig { ... }`
- [ ] Kiểm tra `minSdkVersion` >= 21:
```gradle
defaultConfig {
    minSdkVersion 21  // Phải >= 21
    multiDexEnabled true  // Thêm nếu chưa có
}
```
- [ ] Save file

## Bước 4: Build và Test 🚀

### 4.1 Clean và Rebuild
```powershell
flutter clean
flutter pub get
```
- [ ] Chạy `flutter clean`
- [ ] Chạy `flutter pub get`
- [ ] Đợi dependencies download

### 4.2 Chạy App
```powershell
flutter run
```
- [ ] Kết nối device/emulator
- [ ] Chạy `flutter run`
- [ ] Đợi app build và cài đặt

### 4.3 Test Google Sign-In
- [ ] Mở app
- [ ] Nhấn nút "TIẾP TỤC VỚI GOOGLE"
- [ ] Google Sign-In dialog xuất hiện
- [ ] Chọn tài khoản Google
- [ ] Đăng nhập thành công
- [ ] Được chuyển đến WelcomeScreen

### 4.4 Kiểm tra Firebase Console
- [ ] Vào Firebase Console
- [ ] Mở **Authentication** → **Users**
- [ ] Thấy user vừa đăng nhập trong danh sách

## Bước 5: Verification ✅

### Code Verification
- [ ] File `lib/main.dart` có `Firebase.initializeApp()`
- [ ] File `lib/services/AuthService.dart` có `firebase_auth` import
- [ ] File `pubspec.yaml` có `firebase_core` và `firebase_auth`

### Android Configuration Verification
- [ ] File `android/app/google-services.json` tồn tại
- [ ] File `android/build.gradle` có `google-services:4.4.0`
- [ ] File `android/app/build.gradle` có `apply plugin: 'com.google.gms.google-services'`
- [ ] `minSdkVersion` >= 21

### Firebase Console Verification
- [ ] Google Sign-In provider được enable
- [ ] Android app đã được đăng ký
- [ ] SHA-1 certificate đã được thêm
- [ ] Package name đúng

## Troubleshooting 🐛

Nếu gặp lỗi, check lại:

### "Default FirebaseApp is not initialized"
- [ ] `google-services.json` có trong `android/app/`
- [ ] `apply plugin: 'com.google.gms.google-services'` có trong `android/app/build.gradle`
- [ ] Đã chạy `flutter clean && flutter pub get`

### "PlatformException(sign_in_failed)"
- [ ] SHA-1 đã được thêm vào Firebase Console
- [ ] Download lại `google-services.json` mới nhất
- [ ] Package name khớp với Firebase

### "DEVELOPER_ERROR"
- [ ] SHA-1 không đúng hoặc chưa thêm
- [ ] Package name không khớp
- [ ] Đợi 5-10 phút sau khi thêm SHA-1

### App không build được
- [ ] Chạy `flutter clean`
- [ ] Xóa folder `build/`
- [ ] Chạy lại `flutter pub get`
- [ ] Chạy `flutter run -v` để xem logs chi tiết

## Additional Notes 📝

### For Production
Khi build production APK, bạn cần:
- [ ] Lấy SHA-1 của release keystore
- [ ] Thêm SHA-1 release vào Firebase Console
- [ ] Build release APK: `flutter build apk --release`

### For iOS (nếu cần)
- [ ] Download `GoogleService-Info.plist`
- [ ] Add vào Xcode project
- [ ] Cập nhật `ios/Podfile`
- [ ] Chạy `pod install`

## Resources 📚

- [x] `FIREBASE_SETUP_GUIDE.md` - Hướng dẫn chi tiết
- [x] `FIREBASE_QUICKSTART.md` - Quick reference
- [x] `GOOGLE_SIGNIN_FLOW.md` - Luồng đăng nhập
- [x] `ARCHITECTURE_DIAGRAM.md` - Sơ đồ kiến trúc
- [x] `FIREBASE_INTEGRATION_SUMMARY.md` - Tóm tắt tích hợp

## Success Criteria ✨

Khi tất cả checklist hoàn thành:
- ✅ App chạy không lỗi
- ✅ Nhấn nút Google Sign-In hiện dialog
- ✅ Đăng nhập thành công
- ✅ Chuyển đến WelcomeScreen
- ✅ User xuất hiện trong Firebase Console

---

**Lưu ý:** Hoàn thành tất cả các mục trong checklist này trước khi báo cáo vấn đề!

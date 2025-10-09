# Hướng dẫn cấu hình Firebase cho Ocean Pet

## Bước 1: Tạo dự án Firebase

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Đăng nhập bằng tài khoản Google của bạn
3. Nhấn "Add project" (Thêm dự án)
4. Đặt tên dự án: `ocean-pet` hoặc tên bạn muốn
5. Tắt Google Analytics (không bắt buộc) hoặc để bật nếu cần
6. Nhấn "Create project" và đợi quá trình tạo hoàn tất

## Bước 2: Cấu hình Firebase cho Android

### 2.1. Thêm ứng dụng Android vào Firebase

1. Trong Firebase Console, chọn dự án vừa tạo
2. Nhấn vào biểu tượng Android để thêm ứng dụng Android
3. Điền thông tin:
   - **Android package name**: Tìm trong file `android/app/build.gradle` (dòng `applicationId`)
     - Ví dụ: `com.example.ocean_pet` hoặc `com.oceanpet.app`
   - **App nickname** (tùy chọn): Ocean Pet Android
   - **Debug signing certificate SHA-1**: Xem hướng dẫn bên dưới để lấy SHA-1

### 2.2. Lấy SHA-1 Certificate

Mở terminal trong thư mục gốc của dự án và chạy:

```bash
# Trên Windows (PowerShell)
cd android
./gradlew signingReport

# Hoặc
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Tìm dòng `SHA1:` và copy giá trị, ví dụ:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

Dán SHA-1 vào ô **Debug signing certificate SHA-1** trong Firebase Console.

### 2.3. Tải và cấu hình google-services.json

1. Sau khi đăng ký app Android, Firebase sẽ cho phép tải file `google-services.json`
2. Tải file này về
3. Copy file `google-services.json` vào thư mục: `android/app/`

### 2.4. Cập nhật file build.gradle

**File `android/build.gradle`** (project level):

Thêm Google services classpath vào phần dependencies:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // Thêm dòng này
    }
}
```

**File `android/app/build.gradle`** (app level):

Thêm plugin Google services vào cuối file:

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    // ... cấu hình khác
    
    defaultConfig {
        applicationId "com.example.ocean_pet"  // Package name của bạn
        minSdkVersion 21  // Tối thiểu Android 5.0
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
        multiDexEnabled true  // Thêm dòng này nếu cần
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}

apply plugin: 'com.google.gms.google-services'  // Thêm dòng này ở cuối
```

## Bước 3: Cấu hình Firebase cho iOS (nếu cần)

### 3.1. Thêm ứng dụng iOS vào Firebase

1. Trong Firebase Console, nhấn vào biểu tượng iOS
2. Điền thông tin:
   - **iOS bundle ID**: Tìm trong file `ios/Runner/Info.plist` hoặc Xcode
     - Ví dụ: `com.example.oceanPet`
   - **App nickname** (tùy chọn): Ocean Pet iOS

### 3.2. Tải và cấu hình GoogleService-Info.plist

1. Tải file `GoogleService-Info.plist` từ Firebase Console
2. Mở Xcode: `open ios/Runner.xcworkspace`
3. Kéo thả file `GoogleService-Info.plist` vào thư mục `Runner` trong Xcode
4. Đảm bảo checkbox "Copy items if needed" được chọn

### 3.3. Cập nhật Podfile

File `ios/Podfile`:

```ruby
platform :ios, '12.0'  # Tối thiểu iOS 12

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

Chạy lệnh sau để cài đặt pods:

```bash
cd ios
pod install
cd ..
```

## Bước 4: Bật Google Sign-In trong Firebase

1. Trong Firebase Console, vào **Authentication** → **Sign-in method**
2. Nhấn vào **Google** trong danh sách providers
3. Bật toggle "Enable"
4. Chọn email hỗ trợ dự án
5. Nhấn "Save"

## Bước 5: Cài đặt dependencies

Chạy lệnh sau trong terminal:

```bash
flutter pub get
```

## Bước 6: Chạy ứng dụng

```bash
# Chạy trên Android
flutter run

# Hoặc build APK
flutter build apk

# Chạy trên iOS (chỉ trên macOS)
flutter run -d ios
```

## Xử lý lỗi thường gặp

### Lỗi: "Default FirebaseApp is not initialized"

**Giải pháp:**
- Đảm bảo file `google-services.json` nằm trong `android/app/`
- Đảm bảo đã thêm `apply plugin: 'com.google.gms.google-services'` vào cuối file `android/app/build.gradle`
- Clean và rebuild project:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### Lỗi: "PlatformException(sign_in_failed)"

**Giải pháp:**
- Đảm bảo SHA-1 certificate đã được thêm vào Firebase Console
- Tải lại file `google-services.json` mới nhất và thay thế file cũ
- Kiểm tra package name trong Firebase Console khớp với `applicationId` trong `android/app/build.gradle`

### Lỗi: "API key not valid"

**Giải pháp:**
- Vào [Google Cloud Console](https://console.cloud.google.com/)
- Chọn project của bạn
- Vào **APIs & Services** → **Credentials**
- Kiểm tra API key có bật **Android** restriction
- Thêm package name và SHA-1 certificate vào API key

### Lỗi build trên Android

**Giải pháp:**
- Đảm bảo `minSdkVersion` tối thiểu là 21 trong `android/app/build.gradle`
- Thêm `multiDexEnabled true` nếu cần
- Clean project: `flutter clean && flutter pub get`

## Kiểm tra cấu hình

Sau khi hoàn tất các bước trên, bạn có thể kiểm tra:

1. Mở app và nhấn nút "TIẾP TỤC VỚI GOOGLE"
2. Chọn tài khoản Google
3. Nếu đăng nhập thành công, bạn sẽ được chuyển đến WelcomeScreen
4. Kiểm tra Firebase Console → Authentication → Users để xem user vừa đăng ký

## Cấu trúc file sau khi hoàn thành

```
ocean_pet/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← File này phải có
│   │   └── build.gradle          ← Đã cập nhật
│   └── build.gradle              ← Đã cập nhật
├── ios/
│   ├── Runner/
│   │   └── GoogleService-Info.plist  ← File này phải có (nếu build iOS)
│   └── Podfile                   ← Đã cập nhật
├── lib/
│   ├── main.dart                 ← Đã thêm Firebase.initializeApp()
│   └── services/
│       └── AuthService.dart      ← Đã tích hợp Firebase Auth
└── pubspec.yaml                  ← Đã thêm firebase packages
```

## Tài liệu tham khảo

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Auth for Flutter](https://pub.dev/packages/firebase_auth)

## Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. Firebase Console → Authentication → Users (xem có lỗi gì không)
2. Android Studio → Logcat (xem log chi tiết)
3. Flutter log: `flutter run -v` (verbose mode)

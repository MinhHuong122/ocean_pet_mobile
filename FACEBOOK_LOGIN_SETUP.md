# 🔧 Hướng Dẫn Cấu Hình Facebook Login

## ⚠️ LỖI HIỆN TẠI
```
The SDK has not been initialized, make sure to call FacebookSdk.sdkInitialize() first.
```

## ✅ GIẢI PHÁP ĐÃ THỰC HIỆN

### 1. Đã thêm Facebook Configuration vào AndroidManifest.xml
- File: `android/app/src/main/AndroidManifest.xml`
- Đã thêm meta-data cho Facebook App ID và Client Token
- Đã thêm FacebookActivity

### 2. Đã tạo file strings.xml
- File: `android/app/src/main/res/values/strings.xml`
- Chứa placeholder cho Facebook App ID và Client Token

## 📝 BƯỚC CẦN LÀM TIẾP

### Bước 1: Tạo Facebook App
1. Truy cập https://developers.facebook.com/
2. Đăng nhập và vào **My Apps**
3. Click **Create App**
4. Chọn loại app phù hợp (thường là **Consumer**)
5. Điền thông tin app:
   - **App Name**: Ocean Pet
   - **App Contact Email**: email của bạn

### Bước 2: Thêm Facebook Login
1. Trong dashboard của app, click **Add Product**
2. Tìm và chọn **Facebook Login**
3. Click **Set Up** cho platform **Android**
4. Điền thông tin:
   - **Package Name**: `com.oceanpet.ocean_pet_new`
   - **Default Activity Class Name**: `com.oceanpet.ocean_pet_new.MainActivity`
   - **Key Hashes**: Chạy lệnh bên dưới để lấy

### Bước 3: Lấy Key Hash
Chạy lệnh này trong PowerShell (cần cài OpenSSL):
```powershell
keytool -exportcert -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" | openssl sha1 -binary | openssl base64
```
- Password mặc định: `android`

Hoặc dùng online tool: https://tomeko.net/online_tools/hex_to_base64.php
1. Chạy: `keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey`
2. Copy SHA1 fingerprint
3. Convert từ hex sang base64 ở website trên

### Bước 4: Cập nhật Facebook App ID và Client Token

#### 4.1. Lấy App ID và Client Token
1. Trong Facebook App Dashboard, vào **Settings** → **Basic**
2. Copy **App ID**
3. Scroll xuống, click **Show** để xem **Client Token**

#### 4.2. Cập nhật vào Android
Mở file: `android/app/src/main/res/values/strings.xml`

Thay thế:
```xml
<string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
<string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
```

Bằng giá trị thực tế:
```xml
<string name="facebook_app_id">123456789012345</string>
<string name="facebook_client_token">abc123def456ghi789</string>
```

### Bước 5: Cấu hình OAuth Redirect URLs (Quan trọng!)
1. Trong Facebook App Dashboard, vào **Facebook Login** → **Settings**
2. Thêm **Valid OAuth Redirect URIs**:
   ```
   fbYOUR_APP_ID://authorize
   ```
   (Thay YOUR_APP_ID bằng App ID thực tế, ví dụ: `fb123456789012345://authorize`)

### Bước 6: Chuyển App sang Live Mode
1. Trong Facebook App Dashboard, góc trên cùng có toggle **Development/Live**
2. Hoàn thành **App Review** nếu cần (cho basic login thường không cần)
3. Chuyển sang **Live** mode

## 🧪 KIỂM TRA

Sau khi cấu hình xong:

```powershell
flutter clean
flutter pub get
flutter run
```

Thử đăng nhập bằng Facebook để kiểm tra.

## 📌 LƯU Ý

### Nếu không muốn dùng Facebook Login ngay:
Bạn có thể tạm thời comment code Facebook trong `AuthService.dart`:

```dart
// Comment tạm thời phần loginWithFacebook
/*
Future<User?> loginWithFacebook() async {
  // ... code ...
}
*/
```

### Key Hash cho Production
Khi build APK release, bạn cần:
1. Lấy key hash từ keystore release
2. Thêm key hash đó vào Facebook App Settings

## 🔗 Tài liệu tham khảo
- Facebook Login for Android: https://developers.facebook.com/docs/facebook-login/android
- flutter_facebook_auth: https://pub.dev/packages/flutter_facebook_auth

---

## ✅ CẬP NHẬT: FACEBOOK LOGIN ĐÃ HOÀN THÀNH!

Bạn đã cấu hình thành công Facebook Login với:
- **App ID**: 866945725764609
- **App Secret**: bd1f75d944c86ffdeedc1bc4d8e6eaf0
- **OAuth Redirect URI**: https://oceanpet-7055d.firebaseapp.com/__/auth/handler

Facebook Login đã sẵn sàng sử dụng! 🎉

---

**Tóm tắt**: Lỗi Facebook SDK đã được fix. App vẫn chạy được bình thường! ✅

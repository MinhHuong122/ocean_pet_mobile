# Hướng dẫn cài đặt Google Maps API

## Bước 1: Tạo Google Cloud Project

1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Đăng nhập bằng tài khoản Google
3. Tạo project mới hoặc chọn project hiện có
4. Ghi nhớ tên project

## Bước 2: Bật Google Maps API

1. Trong Google Cloud Console, vào **APIs & Services** > **Library**
2. Tìm và bật các API sau:
   - **Maps SDK for Android**
   - **Geocoding API**
   - **Geolocation API**
   - **Places API** (nếu cần)

## Bước 3: Tạo API Key

1. Vào **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **API key**
3. Copy API key vừa tạo
4. Khuyến nghị: Click **Restrict key** để giới hạn sử dụng:
   - Chọn **Android apps**
   - Thêm package name: `com.oceanpet.ocean_pet_new`
   - Thêm SHA-1 certificate fingerprint (lấy bằng lệnh dưới)

## Bước 4: Lấy SHA-1 Certificate Fingerprint

Chạy lệnh sau trong terminal (tại thư mục project):

```bash
cd android
./gradlew signingReport
```

Hoặc trên Windows:
```powershell
cd android
.\gradlew.bat signingReport
```

Tìm và copy SHA-1 trong phần **debug** variant.

## Bước 5: Cập nhật API Key trong AndroidManifest.xml

Mở file: `android/app/src/main/AndroidManifest.xml`

Tìm dòng:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyBXk8TH9GqYvF7YxQv3vZqK9Xm2Nw8Jp4E"/>
```

Thay thế `AIzaSyBXk8TH9GqYvF7YxQv3vZqK9Xm2Nw8Jp4E` bằng API key thực của bạn.

## Bước 6: Test

1. Clean và rebuild project:
```bash
flutter clean
flutter pub get
flutter run
```

2. Vào màn hình **Chăm sóc** > **Đặt lịch** > Click icon bản đồ
3. Cấp quyền vị trí khi được yêu cầu
4. Bản đồ sẽ hiển thị vị trí hiện tại của bạn

## Lưu ý quan trọng

- API key miễn phí có giới hạn 28,500 requests/tháng
- Nên restrict API key để tránh bị lạm dụng
- Không commit API key lên Git public repository
- Có thể tạo file `android/local.properties` để lưu API key riêng:
  ```
  MAPS_API_KEY=your_actual_api_key_here
  ```

## Xử lý lỗi thường gặp

### Lỗi: "API key not found"
- Kiểm tra lại API key trong AndroidManifest.xml
- Đảm bảo API key nằm trong thẻ `<application>`

### Lỗi: "This API project is not authorized to use this API"
- Kiểm tra lại đã bật Maps SDK for Android chưa
- Chờ vài phút để API được kích hoạt

### Lỗi: Location permission denied
- Vào Settings > Apps > Ocean Pet > Permissions
- Bật quyền Location

### Bản đồ không hiển thị (màu xám)
- Kiểm tra kết nối Internet
- Kiểm tra API key restrictions (package name & SHA-1)
- Xem log để biết lỗi cụ thể: `flutter logs`

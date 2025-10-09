# Hướng dẫn cập nhật Logo Ocean Pet

## Tổng quan
Đã cập nhật ứng dụng Ocean Pet để sử dụng logo thật từ file `LOGO.png` thay vì icon mặc định.

## Thay đổi đã thực hiện

### 1. Cập nhật Drawables Resource (`lib/res/generated/drawables.g.dart`)
```dart
class Drawables {
  String get logo => "lib/res/drawables/setting/LOGO.png";
  String get facebook => "lib/res/drawables/setting/Facebook.png";
  String get google => "lib/res/drawables/setting/Google.png";
}
```

### 2. Cập nhật OnboardingScreen (`lib/screens/onboarding_screen.dart`)
- Thay thế `Icon(Icons.pets)` bằng `Image.asset(R.drawable.logo)`
- Sử dụng `ClipRRect` để bo góc logo
- Kích thước: 80x80 pixels

### 3. Cập nhật WelcomeScreen (`lib/screens/welcome_screen.dart`)
- Thay thế icon bằng logo thật
- Giữ nguyên background với opacity
- Kích thước: 80x80 pixels

### 4. Cập nhật LoginScreen & RegisterScreen
- Thay thế icon Facebook/Google bằng image assets
- Cập nhật `_buildSocialButton` để hỗ trợ cả icon và image
- Sử dụng `R.drawable.facebook` và `R.drawable.google`

## Cấu trúc Assets

```
lib/res/drawables/setting/
├── LOGO.png          # Logo chính của Ocean Pet
├── Facebook.png      # Icon Facebook
├── Google.png        # Icon Google
├── LOG.png           # Logo khác (không sử dụng)
└── LOG_2.png         # Logo khác (không sử dụng)
```

## Cách sử dụng Logo

### Trong code:
```dart
// Sử dụng logo chính
Image.asset(
  R.drawable.logo,
  width: 80,
  height: 80,
  fit: BoxFit.cover,
)

// Sử dụng logo social
Image.asset(
  R.drawable.facebook,
  width: 20,
  height: 20,
  fit: BoxFit.contain,
)
```

### Thay đổi logo:
1. Thay thế file `LOGO.png` trong `lib/res/drawables/setting/`
2. Giữ nguyên tên file và kích thước
3. Hot reload để xem thay đổi

## Tính năng đã cập nhật

### ✅ Hoàn thành:
- [x] Logo chính hiển thị trong OnboardingScreen
- [x] Logo chính hiển thị trong WelcomeScreen  
- [x] Logo Facebook trong social login buttons
- [x] Logo Google trong social login buttons
- [x] Responsive design với ClipRRect
- [x] Proper image fitting và sizing

### 🎨 Thiết kế:
- **Logo size**: 80x80px cho logo chính
- **Social icons**: 20x20px cho Facebook/Google
- **Border radius**: 20px cho logo container
- **Fit**: BoxFit.cover cho logo chính, BoxFit.contain cho social icons

## Lưu ý kỹ thuật

1. **File format**: PNG với background trong suốt
2. **Resolution**: High resolution để hiển thị sắc nét
3. **Aspect ratio**: 1:1 (vuông) cho logo chính
4. **File size**: Tối ưu để không ảnh hưởng performance

## Test

Để test logo hiển thị đúng:
1. Chạy `flutter run`
2. Kiểm tra OnboardingScreen - logo hiển thị ở đầu
3. Đăng nhập/đăng ký - kiểm tra social buttons
4. WelcomeScreen - logo hiển thị với gradient background

Logo giờ đây sẽ hiển thị chính xác theo thiết kế thật của Ocean Pet! 🐾

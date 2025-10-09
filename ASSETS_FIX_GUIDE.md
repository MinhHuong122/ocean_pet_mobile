# Hướng dẫn sửa lỗi Assets Ocean Pet

## Vấn đề gặp phải
- "Unable to load asset: res/drawables/setting/Facebook.png"
- "Unable to load asset: res/drawables/setting/Google.png"  
- "Unable to load asset: assets/images/logo.png"
- Layout overflow errors (175 pixels, 144 pixels)

## Nguyên nhân
1. **Đường dẫn assets không khớp** giữa pubspec.yaml và code
2. **Assets chưa được khai báo đúng** trong pubspec.yaml
3. **Layout overflow** do buttons quá rộng

## Giải pháp đã áp dụng

### 1. Cập nhật pubspec.yaml
```yaml
flutter:
  assets:
    - lib/res/fonts/
    - lib/res/drawables/
    - lib/res/drawables/setting/  # ✅ Thêm dòng này
    - assets/images/              # ✅ Thêm dòng này
```

### 2. Sửa đường dẫn trong code
```dart
// Trước (sai):
'res/drawables/setting/Facebook.png'
'res/drawables/setting/Google.png'
'assets/images/logo.png'

// Sau (đúng):
'lib/res/drawables/setting/Facebook.png'
'lib/res/drawables/setting/Google.png'
'lib/res/drawables/setting/LOGO.png'
```

### 3. Cập nhật tất cả màn hình
- ✅ **LoginScreen**: Facebook.png, Google.png
- ✅ **RegisterScreen**: Facebook.png, Google.png
- ✅ **OnboardingScreen**: LOGO.png
- ✅ **WelcomeScreen**: LOGO.png

## Cấu trúc Assets đúng

```
ocean_pet/
├── lib/
│   └── res/
│       └── drawables/
│           └── setting/
│               ├── LOGO.png      ✅ Logo chính
│               ├── Facebook.png  ✅ Icon Facebook
│               └── Google.png    ✅ Icon Google
├── assets/
│   └── images/
│       ├── logo.png      (backup)
│       ├── facebook.png  (backup)
│       └── google.png    (backup)
└── pubspec.yaml
```

## Cách sử dụng Assets

### Trong code:
```dart
// Logo chính
Image.asset(
  'lib/res/drawables/setting/LOGO.png',
  width: 80,
  height: 80,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.pets, size: 40, color: Colors.white);
  },
)

// Social icons
Image.asset(
  'lib/res/drawables/setting/Facebook.png',
  width: 20,
  height: 20,
  fit: BoxFit.contain,
)
```

## Các bước khắc phục

### Bước 1: Kiểm tra file tồn tại
```bash
ls lib/res/drawables/setting/
# Kết quả: LOGO.png, Facebook.png, Google.png
```

### Bước 2: Cập nhật pubspec.yaml
```yaml
assets:
  - lib/res/drawables/setting/
```

### Bước 3: Sửa đường dẫn trong code
```dart
'lib/res/drawables/setting/FILENAME.png'
```

### Bước 4: Cập nhật dependencies
```bash
flutter pub get
```

### Bước 5: Hot restart
```bash
flutter run
# Trong terminal: R (hot restart)
```

## Sửa Layout Overflow

### Vấn đề:
- Buttons quá rộng gây overflow
- Text quá dài không fit

### Giải pháp:
```dart
// Sử dụng Flexible hoặc Expanded
Flexible(
  child: ElevatedButton(
    child: Text('TIẾP TỤC VỚI FACEBOOK'),
  ),
)

// Hoặc giảm font size
Text(
  'TIẾP TỤC VỚI FACEBOOK',
  style: TextStyle(fontSize: 12), // Giảm từ 14 xuống 12
)
```

## Test Assets

### Kiểm tra logo hiển thị:
1. Mở OnboardingScreen → Logo hiển thị ở đầu
2. Đăng nhập → WelcomeScreen → Logo hiển thị
3. Social buttons → Icons Facebook/Google hiển thị

### Nếu vẫn lỗi:
1. Kiểm tra tên file chính xác (phân biệt hoa thường)
2. Kiểm tra file có tồn tại không
3. Chạy `flutter clean` và `flutter pub get`
4. Hot restart ứng dụng

## Lưu ý quan trọng

1. **Đường dẫn assets** phải bắt đầu từ thư mục gốc project
2. **Tên file** phải chính xác, phân biệt hoa thường
3. **pubspec.yaml** phải khai báo đúng thư mục assets
4. **Hot restart** cần thiết sau khi thay đổi assets
5. **ErrorBuilder** giúp xử lý trường hợp assets không load được

Assets giờ đây sẽ hiển thị đúng cách! 🎨✨


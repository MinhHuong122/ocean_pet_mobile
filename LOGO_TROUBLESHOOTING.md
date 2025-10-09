# Khắc phục sự cố Logo Ocean Pet

## Vấn đề
Logo không hiển thị với lỗi: "Unable to load asset: 'lib/res/drawables/setting/LOGO.png'"

## Nguyên nhân có thể
1. **Đường dẫn assets không đúng** trong Flutter
2. **Assets chưa được khai báo** trong pubspec.yaml
3. **File không tồn tại** hoặc tên file sai
4. **Cache Flutter** chưa được cập nhật

## Giải pháp đã áp dụng

### 1. Kiểm tra file tồn tại
```
lib/res/drawables/setting/
├── LOGO.png          ✅ Tồn tại
├── Facebook.png      ✅ Tồn tại  
├── Google.png        ✅ Tồn tại
├── LOG.png           ✅ Tồn tại
└── LOG_2.png         ✅ Tồn tại
```

### 2. Cập nhật pubspec.yaml
```yaml
flutter:
  assets:
    - lib/res/fonts/
    - lib/res/drawables/  # ✅ Đã khai báo
```

### 3. Sử dụng đường dẫn trực tiếp
Thay vì sử dụng `R.drawable.logo`, sử dụng đường dẫn trực tiếp:
```dart
Image.asset(
  'lib/res/drawables/setting/LOGO.png',
  width: 80,
  height: 80,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    // Fallback icon nếu logo không load được
    return Icon(Icons.pets, size: 40, color: Colors.white);
  },
)
```

### 4. Thêm errorBuilder
Để xử lý trường hợp logo không load được:
```dart
errorBuilder: (context, error, stackTrace) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: const Color(0xFF8B5CF6),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Icon(
      Icons.pets,
      size: 40,
      color: Colors.white,
    ),
  );
}
```

## Các bước khắc phục

### Bước 1: Clean và rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Bước 2: Kiểm tra đường dẫn
- Đảm bảo file `LOGO.png` tồn tại trong `lib/res/drawables/setting/`
- Kiểm tra tên file chính xác (phân biệt hoa thường)

### Bước 3: Cập nhật assets
```bash
flutter pub get
```

### Bước 4: Hot restart
```bash
# Trong terminal đang chạy Flutter
R  # Hot restart
```

## Cấu trúc file đã cập nhật

### OnboardingScreen
```dart
Image.asset(
  'lib/res/drawables/setting/LOGO.png',
  width: 80,
  height: 80,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(/* fallback icon */);
  },
)
```

### WelcomeScreen
```dart
Image.asset(
  'lib/res/drawables/setting/LOGO.png',
  width: 80,
  height: 80,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(/* fallback icon */);
  },
)
```

### Social Buttons
```dart
Image.asset(
  'lib/res/drawables/setting/Facebook.png',
  width: 20,
  height: 20,
  fit: BoxFit.contain,
)
```

## Test

Để test logo hiển thị:
1. Chạy `flutter run`
2. Kiểm tra OnboardingScreen - logo hiển thị ở đầu
3. Nếu logo không hiển thị, sẽ thấy fallback icon
4. Kiểm tra console để xem lỗi chi tiết

## Lưu ý

- **File format**: PNG với background trong suốt
- **File size**: Tối ưu để không ảnh hưởng performance
- **Naming**: Tên file phải chính xác, phân biệt hoa thường
- **Path**: Đường dẫn phải bắt đầu từ thư mục gốc project

Nếu vẫn gặp vấn đề, kiểm tra console log để xem lỗi chi tiết!

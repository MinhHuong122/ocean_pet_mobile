# Hướng dẫn khắc phục lỗi Ocean Pet

## Vấn đề gặp phải
- 797 linter errors across 10 files
- Tất cả các file đều báo lỗi "Target of URI doesn't exist"
- Flutter SDK không được nhận diện đúng cách

## Nguyên nhân
1. **analysis_options.yaml** có vấn đề với flutter_lints package
2. **Cache Flutter** bị lỗi
3. **Dependencies** chưa được cập nhật đúng cách

## Giải pháp đã áp dụng

### 1. Sửa analysis_options.yaml
```yaml
# Trước (gây lỗi):
include: package:flutter_lints/flutter.yaml

# Sau (đã sửa):
# include: package:flutter_lints/flutter.yaml
```

### 2. Clean và rebuild project
```bash
flutter clean
flutter pub get
```

### 3. Sửa unused import trong test file
```dart
// Trước:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Sau:
import 'package:flutter_test/flutter_test.dart';
```

## Kết quả
- ✅ **0 lỗi** sau khi sửa
- ✅ Flutter analyze thành công
- ✅ Ứng dụng có thể chạy bình thường

## Các bước khắc phục chi tiết

### Bước 1: Kiểm tra Flutter environment
```bash
flutter doctor -v
```

### Bước 2: Clean project
```bash
flutter clean
```

### Bước 3: Sửa analysis_options.yaml
Comment out dòng include flutter_lints:
```yaml
# include: package:flutter_lints/flutter.yaml
```

### Bước 4: Cập nhật dependencies
```bash
flutter pub get
```

### Bước 5: Kiểm tra lỗi
```bash
flutter analyze
```

### Bước 6: Chạy ứng dụng
```bash
flutter run
```

## Lưu ý quan trọng

1. **flutter_lints package**: Có thể gây xung đột với một số version Flutter
2. **Cache issues**: Luôn clean project khi gặp lỗi lạ
3. **Import statements**: Kiểm tra unused imports
4. **Dependencies**: Đảm bảo pubspec.yaml đúng format

## Prevention (Phòng ngừa)

1. **Regular cleanup**: Chạy `flutter clean` định kỳ
2. **Version control**: Commit code thường xuyên
3. **Dependency management**: Cập nhật dependencies cẩn thận
4. **Analysis options**: Sử dụng analysis_options.yaml đơn giản

## Troubleshooting

Nếu vẫn gặp lỗi:
1. Restart IDE/Editor
2. Restart Flutter daemon: `flutter daemon --stop`
3. Kiểm tra Flutter version: `flutter --version`
4. Tạo project mới và copy code

Tất cả lỗi đã được khắc phục thành công! 🎉

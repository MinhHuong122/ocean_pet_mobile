# Hướng dẫn sử dụng tính năng đăng nhập Ocean Pet

## Tổng quan
Ứng dụng Ocean Pet đã được tích hợp tính năng đăng nhập hoàn chỉnh với giao diện đẹp và chức năng xác thực.

## Cấu trúc dự án

### 1. AuthService (`lib/services/auth_service.dart`)
- Xử lý logic đăng nhập/đăng xuất
- Lưu trữ trạng thái đăng nhập bằng SharedPreferences
- Hỗ trợ cả API thật và mock data cho demo

### 2. LoginScreen (`lib/screens/login_screen.dart`)
- Giao diện đăng nhập với gradient đẹp mắt
- Validation form đầy đủ
- Hiển thị loading state khi đăng nhập
- Demo credentials để test

### 3. HomeScreen (`lib/screens/home_screen.dart`)
- Màn hình chính sau khi đăng nhập thành công
- Hiển thị thông tin user
- Các tính năng chính của app (đang phát triển)
- Nút đăng xuất

### 4. AuthWrapper (`lib/main.dart`)
- Quản lý trạng thái đăng nhập toàn app
- Tự động chuyển hướng giữa LoginScreen và HomeScreen

## Demo Credentials

Để test tính năng đăng nhập, sử dụng một trong các tài khoản sau:

### Tài khoản Admin:
- **Email:** `admin@oceanpet.com`
- **Password:** `123456`

### Tài khoản User:
- **Email:** `user@oceanpet.com`
- **Password:** `password`

## Tính năng chính

### ✅ Đã hoàn thành:
- [x] Giao diện đăng nhập đẹp với gradient
- [x] Validation form (email, password)
- [x] Loading state khi đăng nhập
- [x] Lưu trữ trạng thái đăng nhập
- [x] Tự động chuyển hướng sau đăng nhập
- [x] Màn hình chính với thông tin user
- [x] Chức năng đăng xuất
- [x] Mock authentication cho demo

### 🔄 Đang phát triển:
- [ ] Tích hợp API thật
- [ ] Quản lý thú cưng
- [ ] Lịch khám bệnh
- [ ] Mua sắm
- [ ] Tư vấn

## Cách chạy ứng dụng

1. Cài đặt dependencies:
```bash
flutter pub get
```

2. Chạy ứng dụng:
```bash
flutter run
```

3. Sử dụng demo credentials để đăng nhập

## Cấu hình API

Để tích hợp với API thật, chỉnh sửa trong `lib/services/auth_service.dart`:

```dart
static const String _baseUrl = 'https://your-api-url.com';
static const String _loginEndpoint = '/api/auth/login';
```

## Dependencies đã thêm

- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Lưu trữ local
- `http: ^1.1.2` - HTTP requests

## Lưu ý

- Ứng dụng sử dụng font SF Pro từ thư mục `lib/res/fonts/`
- Màu sắc chính: Blue gradient (#1E3A8A → #3B82F6 → #60A5FA)
- Responsive design cho các kích thước màn hình khác nhau

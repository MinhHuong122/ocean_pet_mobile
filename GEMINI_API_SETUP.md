# Hướng dẫn cấu hình Gemini API

## Bước 1: Lấy API Key từ Google AI Studio

1. Truy cập: https://makersuite.google.com/app/apikey
2. Đăng nhập bằng tài khoản Google của bạn
3. Click "Create API Key"
4. Chọn project hoặc tạo project mới
5. Copy API key vừa tạo

## Bước 2: Thêm API Key vào code

Mở file `lib/screens/ai_chat_screen.dart` và thay thế dòng:

```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

Bằng:

```dart
static const String _apiKey = 'AIza...'; // API key của bạn
```

## Bước 3: Kiểm tra

1. Chạy app: `flutter run`
2. Bấm vào nút FAB (Floating Action Button) màu tím ở góc dưới bên phải
3. Chọn "Hỗ trợ nhanh với AI"
4. Gửi tin nhắn thử nghiệm

## Lưu ý

- API key là miễn phí với giới hạn 60 requests/phút
- **KHÔNG** commit API key lên Git/GitHub
- Nên lưu API key trong environment variables hoặc file .env

## Troubleshooting

Nếu gặp lỗi:
- Kiểm tra API key có đúng không
- Kiểm tra kết nối internet
- Kiểm tra console logs để xem chi tiết lỗi

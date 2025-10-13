# Hướng dẫn cấu hình gửi Email OTP

## Bước 1: Cấu hình Gmail App Password

1. Truy cập: https://myaccount.google.com/security
2. Bật **2-Step Verification** (Xác minh 2 bước)
3. Sau khi bật, tìm mục **App passwords** (Mật khẩu ứng dụng)
4. Tạo mật khẩu ứng dụng mới:
   - Chọn app: **Mail**
   - Chọn device: **Other** (nhập: "Ocean Pet Backend")
   - Copy mật khẩu 16 ký tự được tạo ra

## Bước 2: Cập nhật server.js

Mở file `lib/backend/server.js` và thay đổi:

```javascript
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'your_email@gmail.com', // ⚠️ Thay bằng email của bạn
        pass: 'your_app_password'     // ⚠️ Thay bằng App Password vừa tạo (16 ký tự)
    }
});
```

**Ví dụ:**
```javascript
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'oceanpet@gmail.com',
        pass: 'abcd efgh ijkl mnop'  // 16 ký tự không có dấu cách
    }
});
```

## Bước 3: Cập nhật Database

Chạy SQL sau trong MySQL Workbench:

```sql
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;
```

Hoặc chạy file `lib/backend/update_database.sql`

## Bước 4: Khởi động lại Backend

```powershell
# Dừng backend nếu đang chạy (Ctrl+C)
npm start
```

## Bước 5: Test chức năng

1. Mở app Flutter và đăng ký tài khoản mới
2. Kiểm tra email để lấy mã OTP (6 số)
3. Nhập mã OTP vào app
4. Sau khi xác thực thành công, sẽ chuyển sang màn hình đăng nhập

## Lưu ý:

- **Mã OTP có hiệu lực 10 phút**
- Có thể **gửi lại OTP** sau khi hết thời gian
- Mã OTP được log ra console backend để debug (trong môi trường dev)
- Trong production, nên dùng **Redis** thay vì Map để lưu OTP
- **KHÔNG** commit App Password lên Git (dùng .env file)

## Troubleshooting:

### Không nhận được email?
1. Kiểm tra folder Spam/Junk
2. Kiểm tra App Password đúng chưa
3. Xem log backend: `console.log` sẽ in ra mã OTP

### Lỗi "Invalid login"?
- App Password sai hoặc chưa bật 2-Step Verification

### Lỗi "Access denied"?
- Chưa tạo App Password, đang dùng mật khẩu thường

## Test không cần email (Development):

Trong quá trình phát triển, mã OTP được log ra console:

```
OTP sent to user@example.com: 123456
```

Bạn có thể copy mã này để test mà không cần check email.

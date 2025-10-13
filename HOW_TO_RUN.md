# Hướng dẫn chạy Ocean Pet App

## 🚀 Cách chạy tự động (Khuyên dùng)

### Windows:
```bash
start_app.bat
```

Script này sẽ:
1. ✅ Kiểm tra backend đã chạy chưa
2. ✅ Tự động khởi động Node.js backend (kết nối MySQL)
3. ✅ Chạy Flutter app
4. ✅ Kiểm tra kết nối backend khi app khởi động

---

## 🔧 Cách chạy thủ công

### Bước 1: Khởi động Backend
Mở terminal/cmd và chạy:
```bash
node lib/backend/server.js
```

Bạn sẽ thấy:
```
Kết nối MySQL thành công!
Server chạy trên cổng 3000
```

### Bước 2: Chạy Flutter App
Mở terminal khác và chạy:
```bash
flutter run
```

---

## 🔍 Kiểm tra kết nối

### Kiểm tra Backend đang chạy:
```bash
# Windows PowerShell
curl http://localhost:3000

# Windows CMD
curl http://localhost:3000
```

Kết quả mong đợi:
```json
{
  "status": "OK",
  "message": "Server và Database đã kết nối thành công!",
  "timestamp": "2025-10-13T..."
}
```

### Kiểm tra từ trình duyệt:
Mở: http://localhost:3000

---

## ⚠️ Lưu ý

### 1. Cấu hình MySQL
Trước khi chạy, hãy cập nhật mật khẩu MySQL trong `lib/backend/server.js`:
```javascript
const dbConfig = {
    host: '127.0.0.1',
    user: 'root',
    password: 'your_mysql_password', // ⚠️ THAY ĐỔI TẠI ĐÂY
    database: 'ocean_pet_app',
    port: 3306,
};
```

### 2. Tạo Database
```sql
CREATE DATABASE ocean_pet_app;

USE ocean_pet_app;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255),
    name VARCHAR(255),
    provider VARCHAR(50),
    provider_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Cài đặt dependencies
#### Backend (Node.js):
```bash
cd lib/backend
npm install express mysql2 bcryptjs jsonwebtoken passport passport-google-oauth20 passport-facebook cors google-auth-library node-fetch
```

#### Flutter:
```bash
flutter pub get
```

---

## 🐛 Xử lý lỗi

### Lỗi: "Backend chưa chạy"
- Chạy `node lib/backend/server.js` trước
- Hoặc dùng `start_app.bat`

### Lỗi: "ECONNREFUSED ::1:3000"
- MySQL chưa chạy. Khởi động MySQL server
- Kiểm tra mật khẩu trong `dbConfig`

### Lỗi: "Port 3000 đã được sử dụng"
```bash
# Windows - Tìm và dừng process đang dùng port 3000
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

---

## 📱 Tính năng tự động

Khi chạy `flutter run`, app sẽ:
1. ✅ Tự động kiểm tra backend có đang chạy không
2. ✅ Hiển thị thông báo trong console:
   - `✅ Backend đã kết nối thành công!`
   - `⚠️ Cảnh báo: Backend chưa chạy`
3. ✅ App vẫn chạy được (sử dụng Firebase Authentication)
4. ✅ Các tính năng đăng nhập email/password cần backend

---

## 🔗 Kiến trúc hệ thống

```
┌─────────────────┐      HTTP      ┌─────────────────┐
│                 │ ─────────────> │                 │
│  Flutter App    │    API Calls   │  Node.js Server │
│  (Frontend)     │ <───────────── │  (Backend)      │
│                 │    JSON        │                 │
└─────────────────┘                └─────────────────┘
                                            │
                                            │ MySQL
                                            ▼
                                   ┌─────────────────┐
                                   │                 │
                                   │  MySQL Database │
                                   │  (ocean_pet_app)│
                                   │                 │
                                   └─────────────────┘
```

---

## 📞 Hỗ trợ

Nếu gặp vấn đề, kiểm tra:
1. MySQL server đang chạy
2. Node.js đã cài đặt (`node --version`)
3. Flutter đã cài đặt (`flutter doctor`)
4. Dependencies đã cài đặt đầy đủ

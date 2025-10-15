# Ocean Pet Backend - API Documentation

## 📋 Mục lục

1. [Cài đặt](#cài-đặt)
2. [Cấu hình](#cấu-hình)
3. [Chạy server](#chạy-server)
4. [API Endpoints](#api-endpoints)
5. [Authentication](#authentication)
6. [Error Codes](#error-codes)

---

## 🚀 Cài đặt

### Yêu cầu

- Node.js >= 14.x
- MySQL >= 8.0
- npm hoặc yarn

### Các bước cài đặt

```bash
# Di chuyển vào thư mục backend
cd backend

# Cài đặt dependencies
npm install

# Tạo file .env từ .env.example
copy .env.example .env

# Chỉnh sửa file .env với thông tin của bạn
```

---

## ⚙️ Cấu hình

### File `.env`

```env
# Server Port
PORT=3000

# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=ocean_pet

# JWT Secret
JWT_SECRET=your_secret_key_here

# Email Configuration (Gmail)
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
```

### Cách lấy App Password cho Gmail

1. Truy cập: https://myaccount.google.com/security
2. Bật "2-Step Verification"
3. Vào "App passwords"
4. Chọn app = "Mail", device = "Other"
5. Copy password và dán vào `EMAIL_PASSWORD`

---

## ▶️ Chạy server

```bash
# Development mode (tự động restart)
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

---

## 📡 API Endpoints

### Base URL: `http://localhost:3000`

---

## 1. Authentication

### 1.1. Đăng ký

**POST** `/register`

**Body:**
```json
{
  "name": "Nguyễn Văn A",
  "email": "example@gmail.com",
  "password": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đăng ký thành công. Vui lòng kiểm tra email để xác thực.",
  "userId": 1
}
```

---

### 1.2. Xác thực OTP

**POST** `/verify-otp`

**Body:**
```json
{
  "email": "example@gmail.com",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Xác thực thành công"
}
```

---

### 1.3. Gửi lại OTP

**POST** `/resend-otp`

**Body:**
```json
{
  "email": "example@gmail.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã gửi lại mã OTP"
}
```

---

### 1.4. Đăng nhập

**POST** `/login`

**Body:**
```json
{
  "email": "example@gmail.com",
  "password": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "Nguyễn Văn A",
    "email": "example@gmail.com",
    "avatarUrl": null
  }
}
```

---

## 2. User Management

### 2.1. Lấy thông tin user

**GET** `/user/:userId`

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "Nguyễn Văn A",
    "email": "example@gmail.com",
    "avatar_url": null
  }
}
```

---

### 2.2. Cập nhật thông tin user

**PUT** `/user/:userId`

**Body:**
```json
{
  "name": "Nguyễn Văn B",
  "avatarUrl": "https://example.com/avatar.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Cập nhật thành công",
  "user": {
    "id": 1,
    "name": "Nguyễn Văn B",
    "email": "example@gmail.com",
    "avatar_url": "https://example.com/avatar.jpg"
  }
}
```

---

## 3. Folders

### 3.1. Lấy danh sách folders

**GET** `/folders/:userId`

**Response:**
```json
{
  "success": true,
  "folders": [
    {
      "id": 1,
      "name": "Mèo",
      "icon": "🐱",
      "color": "#EC4899"
    },
    {
      "id": 2,
      "name": "Chó",
      "icon": "🐕",
      "color": "#8B5CF6"
    }
  ]
}
```

---

### 3.2. Đồng bộ folders từ selected pets

**POST** `/folders/sync`

**Body:**
```json
{
  "userId": 1,
  "selectedPets": ["Mèo", "Chó", "Cá"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã đồng bộ thư mục"
}
```

---

## 4. Diary Entries

### 4.1. Lấy tất cả diary entries

**GET** `/diary/:userId`

**Response:**
```json
{
  "success": true,
  "entries": [
    {
      "id": 1,
      "user_id": 1,
      "folder_id": 1,
      "folder_name": "Mèo",
      "title": "Ngày đầu nuôi mèo",
      "description": "Hôm nay mèo về nhà...",
      "category": "Chăm sóc",
      "entry_date": "2024-01-15",
      "entry_time": "14:30:00",
      "bg_color": "#FFE5E5",
      "has_password": false,
      "password": null,
      "is_deleted": false,
      "deleted_at": null,
      "images": [
        "https://example.com/image1.jpg",
        "https://example.com/image2.jpg"
      ]
    }
  ]
}
```

---

### 4.2. Thêm diary entry

**POST** `/diary`

**Body:**
```json
{
  "userId": 1,
  "folderId": 1,
  "title": "Ngày đầu nuôi mèo",
  "description": "Hôm nay mèo về nhà...",
  "category": "Chăm sóc",
  "entryDate": "2024-01-15",
  "entryTime": "14:30:00",
  "bgColor": "#FFE5E5",
  "password": null,
  "images": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã thêm nhật ký",
  "entryId": 1
}
```

---

### 4.3. Cập nhật diary entry

**PUT** `/diary/:entryId`

**Body:**
```json
{
  "title": "Ngày đầu nuôi mèo (Updated)",
  "description": "Cập nhật nội dung...",
  "category": "Vui chơi",
  "folderId": 2,
  "bgColor": "#E5F5FF"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã cập nhật"
}
```

---

### 4.4. Xóa diary entry (Soft Delete - vào thùng rác)

**DELETE** `/diary/:entryId`

**Response:**
```json
{
  "success": true,
  "message": "Đã chuyển vào thùng rác"
}
```

---

### 4.5. Lấy entries trong thùng rác

**GET** `/diary/trash/:userId`

**Response:**
```json
{
  "success": true,
  "trashedEntries": [
    {
      "id": 5,
      "title": "Entry đã xóa",
      "deleted_at": "2024-01-15T10:00:00.000Z",
      "days_left": 28
    }
  ]
}
```

---

### 4.6. Khôi phục từ thùng rác

**POST** `/diary/restore/:entryId`

**Response:**
```json
{
  "success": true,
  "message": "Đã khôi phục"
}
```

---

### 4.7. Xóa vĩnh viễn

**DELETE** `/diary/permanent/:entryId`

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa vĩnh viễn"
}
```

---

## 🔐 Authentication

Các endpoint yêu cầu authentication cần thêm header:

```
Authorization: Bearer <token>
```

---

## ⚠️ Error Codes

| Status Code | Ý nghĩa |
|-------------|---------|
| 200 | Thành công |
| 400 | Bad Request (Dữ liệu không hợp lệ) |
| 401 | Unauthorized (Token không hợp lệ) |
| 403 | Forbidden (Token hết hạn hoặc không có quyền) |
| 404 | Not Found (Không tìm thấy resource) |
| 500 | Internal Server Error (Lỗi server) |

---

## 📝 Lưu ý

- OTP có thời hạn 10 phút
- JWT token có thời hạn 7 ngày
- Entries trong thùng rác sẽ tự động xóa sau 30 ngày (do MySQL Event)
- Password của diary entries được hash bằng bcrypt

---

**Developed by Ocean Pet Team** 🐾

# OCEAN PET - API Documentation & Database Logic

## 📋 Mục lục
1. [Database Schema](#database-schema)
2. [API Endpoints](#api-endpoints)
3. [Logic Flow](#logic-flow)
4. [Error Handling](#error-handling)
5. [Security](#security)

---

## 🗄️ Database Schema

### Các bảng chính:

#### 1. **users** - Quản lý người dùng
```sql
- id (PK)
- name, email (UNIQUE), password
- provider (email/google/facebook)
- avatar_url, is_verified
- otp_code, otp_expires_at
```

#### 2. **pets** - Thú cưng
```sql
- id (PK), user_id (FK)
- name, type, breed, age, weight, gender
- avatar_url, notes
```

#### 3. **folders** - Thư mục nhật ký (từ pets)
```sql
- id (PK), user_id (FK)
- name (tên thú cưng)
- icon, color
```

#### 4. **diary_entries** - Nhật ký
```sql
- id (PK), user_id (FK), folder_id (FK)
- title, description, category
- entry_date, entry_time
- bg_color, has_password, password
- is_deleted, deleted_at (soft delete - thùng rác)
```

#### 5. **diary_images** - Hình ảnh nhật ký
```sql
- id (PK), diary_entry_id (FK)
- image_url, display_order
```

#### 6. **appointments** - Lịch hẹn
```sql
- id (PK), user_id (FK), pet_id (FK)
- title, description, appointment_date, appointment_time
- location, service_type, status
```

---

## 🔌 API Endpoints

### **Authentication**

#### 1. POST `/register`
```json
Request:
{
  "name": "string",
  "email": "string",
  "password": "string"
}

Response:
{
  "success": true,
  "message": "Đăng ký thành công",
  "userId": 1
}
```

#### 2. POST `/verify-otp`
```json
Request:
{
  "email": "string",
  "otp": "123456"
}

Response:
{
  "success": true,
  "message": "Xác thực thành công"
}
```

#### 3. POST `/login`
```json
Request:
{
  "email": "string",
  "password": "string"
}

Response:
{
  "success": true,
  "token": "jwt_token",
  "user": {
    "id": 1,
    "name": "string",
    "email": "string",
    "avatarUrl": "string"
  }
}
```

#### 4. POST `/google-login` / `/facebook-login`
```json
Request:
{
  "accessToken": "oauth_access_token"
}

Response:
{
  "success": true,
  "token": "jwt_token",
  "user": {...}
}
```

### **User Management**

#### 5. GET `/user/:userId`
```json
Response:
{
  "success": true,
  "user": {
    "id": 1,
    "name": "string",
    "email": "string",
    "avatarUrl": "string"
  }
}
```

#### 6. PUT `/user/:userId`
```json
Request:
{
  "name": "string",
  "avatarUrl": "string"
}

Response:
{
  "success": true,
  "message": "Cập nhật thành công",
  "user": {...}
}
```

### **Pets Management**

#### 7. GET `/pets/:userId`
```json
Response:
{
  "success": true,
  "pets": [
    {
      "id": 1,
      "name": "Mochi",
      "type": "Chó",
      "breed": "Poodle",
      "age": 24,
      "weight": 5.5
    }
  ]
}
```

#### 8. POST `/pets`
```json
Request:
{
  "userId": 1,
  "name": "Mochi",
  "type": "Chó",
  "breed": "Poodle",
  "age": 24,
  "weight": 5.5,
  "gender": "female"
}
```

### **Folders (Thư mục từ pets đã chọn)**

#### 9. GET `/folders/:userId`
```json
Response:
{
  "success": true,
  "folders": [
    {
      "id": 1,
      "name": "Chó",
      "icon": "🐕",
      "color": "#8B5CF6"
    }
  ]
}
```

#### 10. POST `/folders/sync`
```json
Request:
{
  "userId": 1,
  "selectedPets": ["Chó", "Mèo", "Cá"]
}

Response:
{
  "success": true,
  "message": "Đã đồng bộ thư mục"
}
```

### **Diary Entries**

#### 11. GET `/diary/:userId`
```json
Response:
{
  "success": true,
  "entries": [
    {
      "id": 1,
      "title": "Mochi ăn sáng",
      "description": "...",
      "category": "Ăn uống",
      "entryDate": "2025-09-17",
      "entryTime": "08:00:00",
      "folderId": 1,
      "folderName": "Chó",
      "bgColor": "#FFF9E6",
      "hasPassword": false,
      "images": ["url1", "url2"]
    }
  ]
}
```

#### 12. POST `/diary`
```json
Request:
{
  "userId": 1,
  "folderId": 1,
  "title": "string",
  "description": "string",
  "category": "Ăn uống",
  "entryDate": "2025-09-17",
  "entryTime": "08:00:00",
  "bgColor": "#FFF9E6",
  "password": "optional_hashed_password",
  "images": ["url1", "url2"]
}
```

#### 13. PUT `/diary/:entryId`
```json
Request:
{
  "title": "string",
  "description": "string",
  "category": "Ăn uống",
  "folderId": 1,
  "bgColor": "#FFF9E6"
}
```

#### 14. DELETE `/diary/:entryId` (Soft delete - vào thùng rác)
```json
Response:
{
  "success": true,
  "message": "Đã chuyển vào thùng rác"
}
```

#### 15. GET `/diary/trash/:userId`
```json
Response:
{
  "success": true,
  "trashedEntries": [
    {
      "id": 1,
      "title": "...",
      "deletedAt": "2025-09-17T10:00:00",
      "daysLeft": 25
    }
  ]
}
```

#### 16. POST `/diary/restore/:entryId`
```json
Response:
{
  "success": true,
  "message": "Đã khôi phục"
}
```

#### 17. DELETE `/diary/permanent/:entryId`
```json
Response:
{
  "success": true,
  "message": "Đã xóa vĩnh viễn"
}
```

### **Appointments**

#### 18. GET `/appointments/:userId`
```json
Response:
{
  "success": true,
  "appointments": [
    {
      "id": 1,
      "title": "Khám sức khỏe",
      "appointmentDate": "2025-09-20",
      "appointmentTime": "10:00:00",
      "location": "Phòng khám Pet Care",
      "serviceType": "Khám sức khỏe",
      "status": "confirmed"
    }
  ]
}
```

#### 19. POST `/appointments`
```json
Request:
{
  "userId": 1,
  "petId": 1,
  "title": "string",
  "description": "string",
  "appointmentDate": "2025-09-20",
  "appointmentTime": "10:00:00",
  "location": "string",
  "serviceType": "Khám sức khỏe"
}
```

---

## 🔄 Logic Flow

### **1. Flow Đăng ký & Đăng nhập**

```
1. User nhập email/password → POST /register
2. Backend:
   - Kiểm tra email đã tồn tại chưa
   - Hash password (bcrypt)
   - Tạo OTP code (6 số)
   - Lưu vào DB với otp_expires_at = NOW() + 10 phút
   - Gửi email OTP
3. User nhập OTP → POST /verify-otp
4. Backend:
   - Kiểm tra OTP và thời gian hết hạn
   - Set is_verified = TRUE
   - Trả về success
5. User đăng nhập → POST /login
6. Backend:
   - Kiểm tra email, password
   - Kiểm tra is_verified
   - Tạo JWT token
   - Trả về token + user info
7. App lưu token vào SharedPreferences
```

### **2. Flow Chọn thú cưng & Tạo thư mục**

```
1. User chọn pets ở ChoosePetScreen
2. App lưu selected_pets vào SharedPreferences:
   ["Chó", "Mèo", "Cá"]
3. POST /folders/sync với userId và selectedPets
4. Backend:
   - Xóa folders cũ của user
   - Tạo folders mới dựa trên selectedPets
   - Mỗi folder có name, icon, color tương ứng
5. Khi vào DiaryScreen:
   - GET /folders/:userId
   - Hiển thị folders trong Drawer
```

### **3. Flow Thêm/Sửa/Xóa Nhật ký**

#### **Thêm:**
```
1. User tap nút "+" → Hiện dialog
2. User nhập title, description, chọn category, folder
3. POST /diary với data
4. Backend:
   - Insert vào diary_entries
   - Nếu có images: Insert vào diary_images
   - Trả về entry mới
5. App cập nhật UI
```

#### **Sửa:**
```
1. User tap vào entry → Vào DiaryDetailScreen
2. User tap vào text → Inline edit (không qua dialog)
3. Khi blur/tap outside → PUT /diary/:entryId
4. Backend cập nhật DB
5. App cập nhật local state
```

#### **Xóa (Soft delete):**
```
1. User chọn "Xóa" → Confirm dialog
2. DELETE /diary/:entryId
3. Backend:
   - Set is_deleted = TRUE
   - Set deleted_at = NOW()
   - KHÔNG xóa khỏi DB
4. Entry biến mất khỏi Diary nhưng vẫn ở DB
5. GET /diary/trash/:userId để hiện trong TrashScreen
```

#### **Khôi phục:**
```
1. User vào TrashScreen → Tap "Khôi phục"
2. POST /diary/restore/:entryId
3. Backend:
   - Set is_deleted = FALSE
   - Set deleted_at = NULL
4. Entry quay lại DiaryScreen
```

#### **Xóa vĩnh viễn:**
```
1. Sau 30 ngày, Event tự động chạy: CleanupTrashedEntries()
2. Hoặc user chọn "Xóa vĩnh viễn" → DELETE /diary/permanent/:entryId
3. Backend DELETE FROM diary_entries WHERE id = ?
4. Xóa hẳn khỏi DB
```

### **4. Flow Password Protection**

```
1. User chọn "Đặt mật khẩu" trong DiaryDetailScreen
2. Nhập password → Hash bằng bcrypt
3. PUT /diary/:entryId với { password: hashed, hasPassword: true }
4. Khi mở entry có password:
   - Hiện PasswordDialog
   - User nhập password
   - So sánh với DB (bcrypt.compare)
   - Nếu đúng → Mở entry
   - Nếu sai → Báo lỗi
```

---

## ⚠️ Error Handling

### **Common Errors:**

```javascript
// 1. Network timeout
{
  success: false,
  message: "Lỗi kết nối sau 2 lần thử: TimeoutException"
}

// 2. Invalid credentials
{
  success: false,
  message: "Email hoặc mật khẩu không đúng"
}

// 3. OTP expired
{
  success: false,
  message: "Mã OTP đã hết hạn"
}

// 4. Duplicate entry
{
  success: false,
  message: "Email đã được sử dụng"
}

// 5. Unauthorized
{
  success: false,
  message: "Token không hợp lệ hoặc đã hết hạn"
}
```

### **Frontend Error Handling:**

```dart
try {
  final result = await AuthService.login(email, password);
  if (result['success']) {
    // Success flow
  } else {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message']))
    );
  }
} catch (e) {
  // Network or unexpected error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Lỗi kết nối: $e'))
  );
}
```

---

## 🔒 Security

### **1. Password Hashing:**
```javascript
const bcrypt = require('bcrypt');
const saltRounds = 10;
const hashedPassword = await bcrypt.hash(plainPassword, saltRounds);
```

### **2. JWT Token:**
```javascript
const jwt = require('jsonwebtoken');
const token = jwt.sign(
  { id: user.id, email: user.email },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);
```

### **3. OTP Security:**
- OTP 6 số random
- Hết hạn sau 10 phút
- Chỉ gửi qua email đã đăng ký

### **4. SQL Injection Prevention:**
```javascript
// ✅ GOOD: Sử dụng parameterized queries
connection.query(
  'SELECT * FROM users WHERE email = ?',
  [email]
);

// ❌ BAD: String concatenation
connection.query(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

### **5. Input Validation:**
```dart
// Frontend validation
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập email';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Email không hợp lệ';
  }
  return null;
}
```

---

## 📊 Database Indexes

```sql
-- Performance optimization
CREATE INDEX idx_diary_user_date ON diary_entries(user_id, entry_date, is_deleted);
CREATE INDEX idx_appointments_user_date ON appointments(user_id, appointment_date, status);
CREATE INDEX idx_email ON users(email);
```

---

## 🔄 Sync Logic (SharedPreferences ↔ Database)

### **Lưu vào SharedPreferences:**
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);
await prefs.setString('user_id', userId);
await prefs.setStringList('selected_pets', ['Chó', 'Mèo']);
```

### **Đồng bộ với Database:**
```
1. App khởi động → Đọc selected_pets từ SharedPreferences
2. Hiển thị trong DiaryScreen Drawer
3. Khi có thay đổi:
   - Cập nhật SharedPreferences
   - POST /folders/sync để cập nhật DB
4. Đảm bảo consistency giữa app và server
```

---

## 🧪 Testing Checklist

### **Authentication:**
- [ ] Đăng ký với email hợp lệ
- [ ] Đăng ký với email đã tồn tại → Lỗi
- [ ] Xác thực OTP đúng
- [ ] Xác thực OTP sai → Lỗi
- [ ] Xác thực OTP hết hạn → Lỗi
- [ ] Đăng nhập thành công
- [ ] Đăng nhập với email chưa xác thực → Lỗi

### **Diary:**
- [ ] Thêm entry mới
- [ ] Sửa entry (inline edit)
- [ ] Xóa entry → Vào thùng rác
- [ ] Khôi phục từ thùng rác
- [ ] Xóa vĩnh viễn từ thùng rác
- [ ] Tự động xóa sau 30 ngày
- [ ] Thêm hình ảnh
- [ ] Đặt mật khẩu
- [ ] Thêm vào thư mục

### **Folders:**
- [ ] Đồng bộ từ selected_pets
- [ ] Hiển thị đúng trong Drawer
- [ ] Lọc entries theo folder

---

## 📝 Notes

1. **SharedPreferences chỉ lưu UI state**, database là source of truth
2. **Soft delete** cho diary entries để có thể khôi phục
3. **JWT token** hết hạn sau 7 ngày, cần refresh hoặc login lại
4. **OTP** hết hạn sau 10 phút
5. **Thùng rác** tự động dọn dẹp sau 30 ngày

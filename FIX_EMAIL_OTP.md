# 🔧 Khắc phục lỗi không nhận được Email OTP

## ✅ ĐÃ SỬA:

1. ✅ Cập nhật địa chỉ "from" email thành `tutumanhmanh@gmail.com`
2. ✅ Thêm log chi tiết hơn để debug
3. ✅ Hiển thị mã OTP trong console nếu gửi email thất bại

---

## 🚀 CÁCH LẤY MÃ OTP:

### **Phương án 1: Lấy từ Console Backend (NHANH NHẤT)**

1. Mở terminal backend (nơi chạy `npm start`)
2. Sau khi đăng ký, xem log:

```
✅ OTP đã gửi thành công đến donguyenminhhuong0122@gmail.com: 123456
```

hoặc nếu email thất bại:

```
❌ Lỗi gửi email: Invalid login: 535-5.7.8 Username and Password not accepted
⚠️ Mã OTP để test (không gửi được email): 123456
```

3. **Copy mã 6 số** (ví dụ: `123456`)
4. Nhập vào app

---

### **Phương án 2: Kiểm tra Email**

Nếu email gửi thành công, kiểm tra:

1. **Hộp thư đến** (Inbox)
2. **Thư rác** (Spam/Junk) ← Rất quan trọng!
3. **Promotions/Social** (nếu dùng Gmail)

Email sẽ có tiêu đề: **"Mã xác thực OTP - Ocean Pet"**

---

### **Phương án 3: Kiểm tra cấu hình Gmail**

Nếu vẫn không gửi được email, kiểm tra:

#### 1. App Password có đúng không?

Trong `server.js`:
```javascript
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'tutumanhmanh@gmail.com',
        pass: 'wtel pqym azfd fdrk'  // ← Kiểm tra lại
    }
});
```

#### 2. Tạo App Password mới:

1. Truy cập: https://myaccount.google.com/security
2. Bật **"2-Step Verification"** (Xác minh 2 bước)
3. Tìm **"App passwords"** (Mật khẩu ứng dụng)
4. Tạo mới:
   - App: **Mail**
   - Device: **Other** (nhập: "Ocean Pet")
5. Copy mật khẩu 16 ký tự (không có dấu cách)
6. Thay vào `server.js`
7. Khởi động lại backend: `npm start`

---

## 🧪 TEST NGAY:

### Bước 1: Đăng ký tài khoản mới

### Bước 2: Xem log backend

Terminal sẽ hiển thị:
```
✅ OTP đã gửi thành công đến email@example.com: 123456
```

### Bước 3: Copy mã và nhập vào app

### Bước 4: Xác thực thành công! ✅

---

## 📊 LOG MẪU:

### Thành công:
```
Server chạy trên cổng 3000
Kết nối MySQL thành công!
✅ OTP đã gửi thành công đến donguyenminhhuong0122@gmail.com: 847293
```

### Thất bại (vẫn lấy được mã để test):
```
Server chạy trên cổng 3000
Kết nối MySQL thành công!
❌ Lỗi gửi email: Invalid login: 535-5.7.8 Username and Password not accepted
⚠️ Mã OTP để test (không gửi được email): 847293
```

→ **Trong cả 2 trường hợp, bạn đều lấy được mã OTP để test!**

---

## 🎯 TÓM TẮT:

1. ✅ Khởi động backend: `npm start`
2. ✅ Đăng ký tài khoản trong app
3. ✅ Xem terminal backend → Copy mã 6 số
4. ✅ Nhập mã vào app
5. ✅ Xác thực thành công!

**Không cần cấu hình email để test!** 🎉

---

## 💡 LƯU Ý:

- Mã OTP hết hạn sau **10 phút**
- Mỗi email chỉ có **1 mã OTP** hợp lệ
- Backend **luôn log mã OTP** để bạn test dễ dàng
- Trong production, nên tắt logging mã OTP

---

## 🆘 NẾU VẪN LỖI:

1. Đảm bảo backend đang chạy (`npm start`)
2. Xem terminal backend để lấy mã OTP
3. Kiểm tra email trong folder Spam
4. Tạo lại App Password nếu cần

**Mọi thắc mắc, check terminal backend trước!** 👍

# 🚀 HƯỚNG DẪN FIX GOOGLE SIGN-IN - NHANH GỌN

## ❌ Vấn đề hiện tại:
- App bị **Lost connection to device** khi đăng nhập Google
- Nguyên nhân: **Chưa enable Identity Toolkit API**

---

## ✅ GIẢI PHÁP - 3 BƯỚC ĐƠN GIẢN

### Bước 1️⃣: Enable Identity Toolkit API (BẮT BUỘC!)

**Click vào link này và bấm nút ENABLE:**

🔗 https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=oceanpet-7055d

→ Sau khi vào, click nút **"ENABLE"** màu xanh
→ Đợi 10-20 giây

---

### Bước 2️⃣: Enable People API (BẮT BUỘC!)

**Click vào link này và bấm nút ENABLE:**

🔗 https://console.cloud.google.com/apis/library/people.googleapis.com?project=oceanpet-7055d

→ Click nút **"ENABLE"** màu xanh
→ Đợi 10-20 giây

---

### Bước 3️⃣: Chạy lại app

```powershell
# Trong terminal, nhấn 'r' để hot reload
r

# Hoặc nếu app đã tắt:
flutter run
```

---

## 🔍 DEBUG - Xem log chi tiết

Tôi đã thêm debug logs vào code. Khi bạn thử đăng nhập Google lần nữa, hãy xem terminal để thấy log chi tiết:

```
🔵 [Google Sign-In] Bắt đầu đăng nhập...
🔵 [Google Sign-In] Đã sign out tài khoản cũ
🔵 [Google Sign-In] Đang mở dialog chọn tài khoản...
🔵 [Google Sign-In] Kết quả: your-email@gmail.com
...
✅ [Google Sign-In] Hoàn tất!
```

Nếu có lỗi, sẽ hiện:
```
❌ [Google Sign-In] Exception: ...
```

Copy toàn bộ log lỗi và gửi cho tôi nếu vẫn không hoạt động.

---

## 📋 CHECKLIST

- [ ] ✅ Đã enable **Identity Toolkit API**
- [ ] ✅ Đã enable **People API**
- [ ] ✅ Đã đợi 10-20 giây sau khi enable
- [ ] ✅ Đã chạy lại app (`r` trong terminal hoặc `flutter run`)
- [ ] ✅ Thử đăng nhập Google và xem log

---

## 💡 LƯU Ý

- **SHA-1 fingerprint** đã đúng: `b294d6c6c37552a0f1f5658709531b2e0fc7d0fa` ✅
- **OAuth Configuration** đã đúng (từ ảnh bạn gửi) ✅
- **Chỉ thiếu enable 2 APIs** mà thôi!

---

## 🎯 SAU KHI FIX

Nếu thành công, log sẽ hiện:
```
✅ [Google Sign-In] Hoàn tất!
I/flutter: Đăng nhập Google thành công
```

Và app sẽ chuyển sang màn hình chính! 🎉

---

## ❓ NẾU VẪN LỖI

Gửi cho tôi:
1. ❌ Toàn bộ log trong terminal (phần có `[Google Sign-In]`)
2. 📸 Screenshot màn hình lỗi (nếu có)
3. ✅ Xác nhận đã enable cả 2 APIs

Tôi sẽ giúp debug tiếp! 🚀

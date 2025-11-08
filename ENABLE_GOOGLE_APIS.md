# 🚀 ENABLE GOOGLE APIS - HƯỚNG DẪN TỰ ĐỘNG

## 📖 HƯỚ DẪN ENABLE APIS - 3 LINK TRỰC TIẾP

### ⚠️ QUAN TRỌNG: Bạn cần bấm 3 link dưới đây và enable từng cái

---

## 🔵 **API 1: Identity Toolkit API (BẮT BUỘC!)**

Mở link này:
```
https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=oceanpet-7055d
```

Các bước:
1. Click link trên → Trình duyệt mở Google Cloud Console
2. Tìm nút **"ENABLE"** (màu xanh) hoặc **"BẬT"** (tiếng Việt)
3. Click vào nó
4. Đợi khoảng 10-20 giây để enable xong
5. ✅ Xong API 1

---

## 🔵 **API 2: People API (BẮT BUỘC!)**

Mở link này:
```
https://console.cloud.google.com/apis/library/people.googleapis.com?project=oceanpet-7055d
```

Các bước:
1. Click link trên → Trình duyệt mở Google Cloud Console
2. Tìm nút **"ENABLE"** hoặc **"BẬT"**
3. Click vào nó
4. Đợi khoảng 10-20 giây
5. ✅ Xong API 2

---

## 🔵 **API 3: Google Cloud APIs (BẮT BUỘC!)**

Mở link này:
```
https://console.cloud.google.com/apis/library/cloudapis.googleapis.com?project=oceanpet-7055d
```

Các bước:
1. Click link trên → Trình duyệt mở Google Cloud Console
2. Tìm nút **"ENABLE"** hoặc **"BẬT"**
3. Click vào nó
4. Đợi khoảng 10-20 giây
5. ✅ Xong API 3

---

## ⏱️ SAU KHI ENABLE XONG

### Bước 1: Đợi
- ⏳ Đợi **1-2 phút** để Google Cloud xử lý
- 🔄 Trong thời gian chờ, bạn có thể làm việc khác

### Bước 2: Hot Reload App
Trong terminal đang chạy app, nhấn phím:
```
r
```
(hot reload) hoặc
```
R
```
(hot restart)

### Bước 3: Test Google Sign-In
1. Mở app trên emulator
2. Click vào nút **"Đăng nhập bằng Google"**
3. Chọn tài khoản Gmail
4. Xem log trong terminal

---

## 📋 CHECKLIST

- [ ] ✅ Enable Identity Toolkit API (link 1)
- [ ] ✅ Enable People API (link 2)
- [ ] ✅ Enable Google Cloud APIs (link 3)
- [ ] ✅ Đợi 1-2 phút
- [ ] ✅ Hot reload app (nhấn `r` trong terminal)
- [ ] ✅ Test Google Sign-In
- [ ] ✅ Xem log để verify

---

## ✅ KỲ VỌNG - LOG THÀNH CÔNG

Khi bạn bấm "Đăng nhập bằng Google", log sẽ hiện:

```
🔵 [Google Sign-In] Bắt đầu đăng nhập...
🔵 [Google Sign-In] Đã sign out tài khoản cũ
🔵 [Google Sign-In] Đang mở dialog chọn tài khoản...
🔵 [Google Sign-In] Kết quả: your-email@gmail.com
🔵 [Google Sign-In] Đang lấy authentication...
✅ [Google Sign-In] Firebase authentication thành công!
✅ [Google Sign-In] Hoàn tất!
```

Và app sẽ **chuyển sang Welcome Screen** ✅

---

## ❌ NẾU VẪN LỖI

Nếu vẫn thấy:
```
❌ [Google Sign-In] Exception: PlatformException(network_error, ApiException: 7)
```

Có thể là:
1. ⏳ APIs chưa active hoàn toàn (đợi thêm 1-2 phút)
2. 🔄 App chưa hot reload (nhấn `r`)
3. 🔍 Google Project sai (check `project=oceanpet-7055d` trong link)

---

## 💡 TIPS

- **Link tất cả 3 APIs đều có `oceanpet-7055d`** - Đây là Google Cloud Project ID của bạn
- **Nếu Google yêu cầu thanh toán**: Không, Google cho phép free API calls cho những mức usage thấp
- **Nếu API đã enable**: Link sẽ hiện nút **"MANAGE"** thay vì **"ENABLE"**

---

## 🎯 TÓNG TẮT

| Bước | Công việc | Status |
|---|---|---|
| 1 | Enable Identity Toolkit API | ⏳ Cần làm |
| 2 | Enable People API | ⏳ Cần làm |
| 3 | Enable Google Cloud APIs | ⏳ Cần làm |
| 4 | Đợi 1-2 phút | ⏳ Cần làm |
| 5 | Hot reload app | ⏳ Cần làm |
| 6 | Test Google Sign-In | ⏳ Cần làm |

---

**Ready? Bắt đầu từ bước 1 nào! 🚀**

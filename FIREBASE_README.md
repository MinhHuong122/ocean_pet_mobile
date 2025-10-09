# 🔐 Firebase Google Sign-In Integration

Tài liệu tích hợp Firebase Authentication với Google Sign-In cho Ocean Pet app.

## 📋 Tổng quan

Project này đã được cập nhật để sử dụng **Firebase Authentication** thay vì backend API truyền thống cho chức năng đăng nhập Google. Điều này mang lại nhiều lợi ích:

- ✅ **Bảo mật cao hơn** - Firebase xử lý authentication tokens
- ✅ **Dễ mở rộng** - Có thể thêm nhiều providers khác (Apple, Twitter, etc.)
- ✅ **Miễn phí** - Firebase Authentication có quota miễn phí lớn
- ✅ **Không cần backend** - Firebase xử lý authentication logic

## 🚀 Quick Start

### 1. Đọc tài liệu theo thứ tự

1. **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** ← **BẮT ĐẦU Ở ĐÂY**
   - Checklist từng bước chi tiết
   - Đánh dấu mỗi bước hoàn thành
   - Troubleshooting tips

2. **[FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)**
   - Hướng dẫn chi tiết đầy đủ
   - Screenshots và ví dụ
   - Xử lý lỗi thường gặp

3. **[FIREBASE_QUICKSTART.md](FIREBASE_QUICKSTART.md)**
   - Tóm tắt các bước cần làm
   - Commands cần chạy
   - Lưu ý quan trọng

### 2. Các bước cơ bản

```powershell
# 1. Lấy SHA-1 certificate
cd android
./gradlew signingReport

# 2. Tạo Firebase project và download google-services.json
# (Xem SETUP_CHECKLIST.md để biết chi tiết)

# 3. Copy google-services.json vào android/app/

# 4. Cập nhật build.gradle files
# (Xem FIREBASE_SETUP_GUIDE.md)

# 5. Build và chạy
flutter clean
flutter pub get
flutter run
```

## 📚 Tài liệu đầy đủ

### Hướng dẫn Setup
| Tài liệu | Mục đích | Khi nào sử dụng |
|----------|----------|-----------------|
| **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** | Checklist từng bước | Khi bắt đầu setup |
| **[FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)** | Hướng dẫn chi tiết | Khi cần hiểu rõ từng bước |
| **[FIREBASE_QUICKSTART.md](FIREBASE_QUICKSTART.md)** | Reference nhanh | Khi cần tra cứu nhanh |

### Tài liệu Technical
| Tài liệu | Mục đích | Khi nào sử dụng |
|----------|----------|-----------------|
| **[GOOGLE_SIGNIN_FLOW.md](GOOGLE_SIGNIN_FLOW.md)** | Luồng đăng nhập | Khi cần hiểu code |
| **[ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)** | Sơ đồ kiến trúc | Khi cần overview hệ thống |
| **[FIREBASE_INTEGRATION_SUMMARY.md](FIREBASE_INTEGRATION_SUMMARY.md)** | Tóm tắt changes | Khi cần biết đã thay đổi gì |

## 🔧 Những gì đã thay đổi

### Code Changes
- ✅ `lib/main.dart` - Added Firebase initialization
- ✅ `lib/services/AuthService.dart` - Integrated Firebase Auth
- ✅ `pubspec.yaml` - Added Firebase dependencies

### Files Added
```
android/app/google-services.json  ← CẦN THÊM BỞI BẠN
SETUP_CHECKLIST.md
FIREBASE_SETUP_GUIDE.md
FIREBASE_QUICKSTART.md
GOOGLE_SIGNIN_FLOW.md
ARCHITECTURE_DIAGRAM.md
FIREBASE_INTEGRATION_SUMMARY.md
```

### Dependencies Added
```yaml
firebase_core: ^2.32.0
firebase_auth: ^4.20.0
google_sign_in: ^6.2.2  # Already existed
```

## ⚠️ Quan trọng

**App sẽ KHÔNG chạy được cho đến khi bạn:**

1. ✅ Tạo Firebase project
2. ✅ Bật Google Sign-In trong Firebase Console
3. ✅ Thêm SHA-1 certificate vào Firebase
4. ✅ Download và copy `google-services.json` vào `android/app/`
5. ✅ Cập nhật `build.gradle` files

👉 **Xem [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) để biết chi tiết**

## 🧪 Testing

### Manual Testing
1. Chạy app: `flutter run`
2. Nhấn "TIẾP TỤC VỚI GOOGLE"
3. Chọn tài khoản Google
4. Verify đăng nhập thành công
5. Check Firebase Console → Authentication → Users

### Debug Mode
```powershell
flutter run -v  # Verbose logging
```

## 🐛 Common Issues

### Issue: "Default FirebaseApp is not initialized"
**Solution:** 
- Kiểm tra `google-services.json` có trong `android/app/`
- Kiểm tra `apply plugin: 'com.google.gms.google-services'` trong `build.gradle`

### Issue: "PlatformException(sign_in_failed)"
**Solution:**
- Kiểm tra SHA-1 trong Firebase Console
- Download lại `google-services.json`

### Issue: Build errors
**Solution:**
```powershell
flutter clean
flutter pub get
flutter run
```

👉 **Xem thêm trong [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md#xử-lý-lỗi-thường-gặp)**

## 📊 Architecture

```
User → LoginScreen → AuthService → Firebase Auth → Google OAuth
                         ↓
                 SharedPreferences (local storage)
```

👉 **Xem [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) để biết chi tiết**

## 🎯 Next Steps

### Immediate (Required)
1. [ ] Complete Firebase setup (see SETUP_CHECKLIST.md)
2. [ ] Test Google Sign-In functionality
3. [ ] Verify user creation in Firebase Console

### Future Enhancements
- [ ] Add Apple Sign-In
- [ ] Add email/password authentication with Firebase
- [ ] Implement password reset
- [ ] Add email verification
- [ ] Set up Firebase Analytics
- [ ] Add Crashlytics

## 📞 Support

Nếu gặp vấn đề:

1. **Kiểm tra documentation:**
   - [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) - Checklist
   - [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) - Chi tiết

2. **Check logs:**
   ```powershell
   flutter run -v
   ```

3. **Verify configuration:**
   - SHA-1 certificate đã add vào Firebase
   - `google-services.json` đúng vị trí
   - Package name khớp với Firebase

## 🔗 Links

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)

## 📝 Notes

- SHA-1 certificate khác nhau cho debug và release builds
- Google Sign-In cần Google Play Services trên Android
- Test trên real device nếu emulator có vấn đề
- Keep `google-services.json` updated khi thay đổi config

## ✅ Success Criteria

App hoạt động đúng khi:
- ✅ User có thể nhấn "TIẾP TỤC VỚI GOOGLE"
- ✅ Google Sign-In dialog xuất hiện
- ✅ Đăng nhập thành công không lỗi
- ✅ User được chuyển đến WelcomeScreen
- ✅ User xuất hiện trong Firebase Console

---

**Ready to start?** → Go to [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)

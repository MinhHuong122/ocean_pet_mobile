# ✅ LOGIC HIỂN THỊ CHOOSE_PET_SCREEN CHO USER LẦN ĐẦU

## 📋 YÊU CẦU
Chỉ hiển thị màn hình chọn pet (`choose_pet_screen`) cho những tài khoản đăng nhập lần đầu (chưa có thông tin pet trong Firestore).

---

## 🔧 CÁC THAY ĐỔI ĐÃ THỰC HIỆN

### 1️⃣ **FirebaseService.dart** - Thêm hàm kiểm tra pet

```dart
/// Kiểm tra xem user đã có pet chưa
static Future<bool> userHasPets() async {
  try {
    final userId = currentUserId;
    if (userId == null) return false;

    final snapshot = await _firestore
        .collection('pets')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  } catch (e) {
    print('Error checking if user has pets: $e');
    return false;
  }
}
```

**Mục đích**: Kiểm tra nhanh xem user đã có ít nhất 1 pet trong database chưa.

---

### 2️⃣ **welcome_screen.dart** - Logic điều hướng thông minh

#### Thay đổi:
- Import thêm `FirebaseService` và `HomeScreen`
- Thêm biến `_hasPets` để tracking trạng thái
- Hàm `_checkUserStatus()` kiểm tra pet và tự động điều hướng

#### Luồng hoạt động:

```
User đăng nhập thành công
    ↓
Chuyển sang WelcomeScreen
    ↓
_checkUserStatus() được gọi
    ↓
┌──────────────────────────┬──────────────────────────┐
│  Đã có pet (hasPets=true) │ Chưa có pet (hasPets=false) │
└──────────────────────────┴──────────────────────────┘
         ↓                              ↓
Hiện "ĐANG TẢI..."          Hiện nút "BẮT ĐẦU"
         ↓                              ↓
Tự động chuyển sang         User click "BẮT ĐẦU"
HomeScreen sau 2s                      ↓
                            Chuyển sang ChoosePetScreen
```

#### Code:

```dart
Future<void> _checkUserStatus() async {
  try {
    // Kiểm tra xem user đã có pet chưa
    final hasPets = await FirebaseService.userHasPets();
    
    // Lấy thông tin user
    final userInfo = await AuthService.getUserInfo();
    
    setState(() {
      _hasPets = hasPets;
      if (userInfo['success'] == true && userInfo['user'] != null) {
        _userName = userInfo['user']['name'] ?? 'Bạn';
      } else {
        _userName = 'Bạn';
      }
      _isLoading = false;
    });

    // Nếu user đã có pet, tự động chuyển sang HomeScreen
    if (hasPets && mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    }
  } catch (e) {
    print('Error checking user status: $e');
    setState(() {
      _userName = 'Bạn';
      _isLoading = false;
      _hasPets = false;
    });
  }
}
```

---

### 3️⃣ **choose_pet_screen.dart** - Lưu vào Firestore

#### Thay đổi:
- Xóa dependency `shared_preferences`
- Thêm import `FirebaseService`
- Hàm `_saveSelectedPets()` lưu vào Firestore thay vì SharedPreferences
- Thêm loading indicator khi đang lưu

#### Code:

```dart
Future<void> _saveSelectedPets() async {
  setState(() {
    _isSaving = true;
  });

  try {
    // Lưu các pet đã chọn vào Firestore
    for (final index in selectedIndexes) {
      final petType = pets[index]['title'] as String;
      await FirebaseService.addPet(
        name: 'Thú cưng $petType',
        type: petType,
        gender: 'unknown',
      );
    }
    print('✅ Đã lưu ${selectedIndexes.length} pet vào Firestore');
  } catch (e) {
    print('❌ Lỗi khi lưu pets: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
```

---

### 4️⃣ **login_screen.dart** - Cập nhật điều hướng

Sau khi login thành công, luôn chuyển về `WelcomeScreen`. Logic kiểm tra pet sẽ được xử lý ở đó.

```dart
if (result['success']) {
  if (mounted) {
    // Luôn chuyển về WelcomeScreen, logic kiểm tra pet sẽ ở đó
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }
}
```

---

## 🎯 LUỒNG HOẠT ĐỘNG TỔNG THỂ

### **Trường hợp 1: User đăng nhập lần đầu (chưa có pet)**

```
1. User nhập email/password → Click "Đăng nhập"
2. AuthService.login() → Success
3. Navigator → WelcomeScreen
4. _checkUserStatus()
   → FirebaseService.userHasPets() → false
5. Hiển thị nút "BẮT ĐẦU"
6. User click "BẮT ĐẦU"
7. Navigator → ChoosePetScreen
8. User chọn pet → Click "Xác nhận"
9. _saveSelectedPets() → Lưu vào Firestore
10. Navigator → HomeScreen
```

### **Trường hợp 2: User đã có pet (đăng nhập lại)**

```
1. User nhập email/password → Click "Đăng nhập"
2. AuthService.login() → Success
3. Navigator → WelcomeScreen
4. _checkUserStatus()
   → FirebaseService.userHasPets() → true
5. Hiển thị "ĐANG TẢI..."
6. Tự động chuyển sang HomeScreen (sau 2s)
```

### **Trường hợp 3: User đăng ký mới**

```
1. User điền form → Click "Đăng ký"
2. AuthService.register() → Success
3. Navigator → LoginScreen (với thông báo kiểm tra email)
4. User xác thực email → Quay lại đăng nhập
5. → Theo luồng "Trường hợp 1"
```

---

## 📊 DATABASE STRUCTURE

### Collection: `pets`

```javascript
{
  "user_id": "uid_của_user",
  "name": "Thú cưng Mèo",  // Tên mặc định
  "type": "Mèo",            // Loại pet đã chọn
  "gender": "unknown",       // Giới tính
  "breed": null,
  "age": null,
  "weight": null,
  "avatar_url": null,
  "notes": null,
  "created_at": Timestamp,
  "updated_at": Timestamp
}
```

---

## ✅ KẾT QUẢ

✔️ User lần đầu → Bắt buộc chọn pet  
✔️ User đã có pet → Tự động vào HomeScreen  
✔️ Dữ liệu lưu trong Firestore (không dùng SharedPreferences)  
✔️ Loading state rõ ràng  
✔️ Error handling đầy đủ  

---

## 🧪 CÁCH TEST

### Test 1: Đăng ký tài khoản mới
```
1. Đăng ký email mới
2. Đăng nhập
3. Phải thấy màn hình "Chọn thú cưng"
4. Chọn pet → Xác nhận
5. Chuyển sang HomeScreen
```

### Test 2: Đăng nhập tài khoản đã có pet
```
1. Đăng nhập tài khoản đã chọn pet
2. Thấy WelcomeScreen hiện "ĐANG TẢI..."
3. Tự động chuyển HomeScreen
```

### Test 3: Kiểm tra database
```
1. Mở Firebase Console
2. Vào Firestore → Collection "pets"
3. Xem pets của user vừa tạo
4. Kiểm tra các field: user_id, name, type, created_at
```

---

## 🔍 DEBUGGING

Nếu có lỗi, kiểm tra logs:

```dart
print('✅ Đã lưu ${selectedIndexes.length} pet vào Firestore');
print('❌ Lỗi khi lưu pets: $e');
print('Error checking user status: $e');
```

---

## 📝 GHI CHÚ

- ChoosePetScreen có thể được mở lại từ Settings nếu user muốn thêm pet
- Có thể mở rộng: Thêm màn hình chỉnh sửa thông tin chi tiết pet sau khi chọn
- Hiện tại pet được tạo với tên mặc định "Thú cưng [Loại]"

# ✅ MÀN HÌNH TẠO HỒ SƠ CHI TIẾT THÚ CƯNG

## 📋 TÍNH NĂNG

Sau khi user chọn loại thú cưng trong `ChoosePetScreen`, họ sẽ được chuyển sang `CreatePetProfileScreen` để nhập thông tin chi tiết cho **từng thú cưng** đã chọn.

---

## 🎯 LUỒNG HOẠT ĐỘNG

```
ChoosePetScreen
    ↓ (User chọn: Mèo, Chó, Cá)
Click "Tiếp theo"
    ↓
CreatePetProfileScreen
    ↓
Form 1/3: Thông tin Mèo
    → Nhập tên, giống, giới tính, ngày sinh, cân nặng, ghi chú
    → Click "Tiếp theo"
    ↓
Form 2/3: Thông tin Chó
    → Nhập tên, giống, giới tính, ngày sinh, cân nặng, ghi chú
    → Click "Tiếp theo"
    ↓
Form 3/3: Thông tin Cá
    → Nhập tên, giống, giới tính, ngày sinh, cân nặng, ghi chú
    → Click "Hoàn tất"
    ↓
Lưu tất cả vào Firestore
    ↓
Chuyển sang HomeScreen
```

---

## 📝 THÔNG TIN THU THẬP

### Các trường bắt buộc:
- ✅ **Tên thú cưng** (TextField) - Bắt buộc

### Các trường tùy chọn:
- 🔹 **Giống** (TextField) - Ví dụ: Husky, Corgi, Ba Tư...
- 🔹 **Giới tính** (3 lựa chọn):
  - 🔵 Đực (Male)
  - 🟡 Cái (Female)  
  - ⚪ Khác (Unknown)
- 🔹 **Ngày sinh** (DatePicker)
  - → Tự động tính **tuổi** khi lưu vào database
- 🔹 **Cân nặng** (TextField với số thập phân) - Đơn vị: kg
- 🔹 **Ghi chú** (TextArea) - Thông tin thêm

---

## 🎨 UI/UX FEATURES

### 1. **Progress Indicator**
- Thanh tiến trình ở trên cùng
- Hiển thị số lượng: "Thú cưng 1/3"
- Màu tím (#8B5CF6) cho phần đã hoàn thành

### 2. **Pet Icon Display**
- Icon tương ứng với loại thú cưng
- Nền tròn màu tím nhạt (#EDE9FE)
- Tiêu đề: "Thông tin [Loại thú cưng]"

### 3. **Form Validation**
- Tên thú cưng: Bắt buộc
- Cân nặng: Phải là số dương (nếu nhập)
- Ngày sinh: Không được sau hôm nay

### 4. **Gender Selection**
- 3 nút lựa chọn nằm ngang
- Nút được chọn: Nền tím, chữ trắng
- Nút chưa chọn: Nền xám, chữ xám

### 5. **Navigation**
- Nút "Tiếp theo" cho các form 1 → n-1
- Nút "Hoàn tất" cho form cuối cùng
- Nút "Back" ở AppBar (từ form 2 trở đi)
- PageView không cho phép swipe (chỉ dùng nút)

### 6. **Loading State**
- CircularProgressIndicator khi đang lưu
- Disable button khi đang xử lý

---

## 💾 DATABASE STRUCTURE

### Collection: `pets`

```javascript
{
  "user_id": "uid_của_user",
  "name": "Meo",              // Từ TextField
  "type": "Mèo",              // Từ ChoosePetScreen
  "breed": "Ba Tư",           // Từ TextField (optional)
  "age": 2,                   // Tính từ birthDate
  "weight": 5.5,              // Từ TextField (optional)
  "gender": "male",           // male/female/unknown
  "notes": "Rất ngoan",       // Từ TextArea (optional)
  "avatar_url": null,         // Sẽ thêm sau
  "created_at": Timestamp,
  "updated_at": Timestamp
}
```

---

## 🔧 FILES CREATED/MODIFIED

### ✅ Created:
1. **`lib/screens/create_pet_profile_screen.dart`**
   - Màn hình tạo hồ sơ chi tiết
   - PageView cho nhiều pets
   - Form validation
   - Date picker integration

### ✅ Modified:
1. **`pubspec.yaml`**
   - Thêm `intl: ^0.19.0` (cho date formatting)

2. **`lib/screens/choose_pet_screen.dart`**
   - Xóa logic lưu trực tiếp
   - Thêm hàm `_goToCreateProfile()`
   - Đổi nút từ "Xác nhận" → "Tiếp theo"
   - Navigator sang CreatePetProfileScreen

---

## 🎯 VALIDATION RULES

### 1. Tên thú cưng
```dart
if (value == null || value.trim().isEmpty) {
  return 'Vui lòng nhập tên thú cưng';
}
```

### 2. Cân nặng
```dart
if (value != null && value.trim().isNotEmpty) {
  final weight = double.tryParse(value.trim());
  if (weight == null || weight <= 0) {
    return 'Vui lòng nhập cân nặng hợp lệ';
  }
}
```

### 3. Tuổi (tự động tính)
```dart
int? age;
if (form.birthDate != null) {
  final now = DateTime.now();
  age = now.year - form.birthDate!.year;
  if (now.month < form.birthDate!.month ||
      (now.month == form.birthDate!.month && now.day < form.birthDate!.day)) {
    age--;
  }
}
```

---

## 🧪 TEST SCENARIOS

### Test 1: Chọn 1 thú cưng
```
1. ChoosePetScreen → Chọn "Mèo"
2. Click "Tiếp theo"
3. Thấy form "Thông tin Mèo" (1/1)
4. Nhập tên: "Meo"
5. Click "Hoàn tất"
6. Chuyển sang HomeScreen
7. Kiểm tra Firestore có 1 pet
```

### Test 2: Chọn nhiều thú cưng
```
1. ChoosePetScreen → Chọn "Mèo", "Chó", "Cá"
2. Click "Tiếp theo"
3. Form 1/3: Nhập thông tin Mèo → "Tiếp theo"
4. Form 2/3: Nhập thông tin Chó → "Tiếp theo"
5. Form 3/3: Nhập thông tin Cá → "Hoàn tất"
6. Chuyển sang HomeScreen
7. Kiểm tra Firestore có 3 pets
```

### Test 3: Validation
```
1. Form thú cưng → Bỏ trống tên
2. Click "Tiếp theo" → Thấy lỗi "Vui lòng nhập tên thú cưng"
3. Nhập cân nặng: "-5" → Lỗi "Vui lòng nhập cân nặng hợp lệ"
4. Nhập cân nặng: "abc" → Lỗi "Vui lòng nhập cân nặng hợp lệ"
```

### Test 4: Navigation
```
1. Form 1/3 → Click nút Back ở AppBar → Không có (đây là form đầu)
2. Form 2/3 → Click nút Back → Quay lại Form 1/3
3. Form 3/3 → Click nút Back → Quay lại Form 2/3
```

### Test 5: Date Picker
```
1. Click vào field "Ngày sinh"
2. Chọn ngày: 15/06/2022
3. Thấy hiển thị: "15/06/2022"
4. Click "Hoàn tất"
5. Kiểm tra Firestore: age = 3 (tính từ 2022 → 2025)
```

---

## 🎨 DESIGN ELEMENTS

### Colors:
- **Primary**: `#8B5CF6` (Tím)
- **Background**: `#FFFFFF` (Trắng)
- **Light Purple**: `#EDE9FE` (Nền icon)
- **Grey**: `Colors.grey[200]` (Nền unselected)
- **Text**: `Colors.black` / `Colors.grey[600]`

### Border Radius:
- Input fields: `12px`
- Buttons: `16px` hoặc `30px`
- Progress bar: `2px`

### Icons:
- Tên: `Icons.pets`
- Giống: `Icons.category`
- Giới tính: `Icons.male` / `Icons.female` / `Icons.help_outline`
- Ngày sinh: `Icons.cake`
- Cân nặng: `Icons.monitor_weight`
- Ghi chú: `Icons.note`

---

## ⚡ PERFORMANCE

- **PageView Physics**: `NeverScrollableScrollPhysics()` → Chỉ dùng nút
- **Form Keys**: Mỗi pet có riêng FormKey
- **Controllers**: Tự động dispose khi widget unmount
- **Validation**: Chỉ validate form hiện tại khi bấm "Tiếp theo"

---

## 🔄 NEXT STEPS (Optional Enhancements)

1. **Upload ảnh đại diện** khi tạo pet
2. **Thêm field "Màu lông"** (Color picker)
3. **Microchip ID** (cho chó/mèo)
4. **Breed suggestions** (Autocomplete từ danh sách giống phổ biến)
5. **Health records preview** (Thêm vaccination ngay khi tạo)
6. **Skip option** (Cho phép bỏ qua một số pet)

---

## ✅ HOÀN THÀNH

✔️ PageView với progress indicator  
✔️ Form validation đầy đủ  
✔️ Date picker tích hợp  
✔️ Tự động tính tuổi từ ngày sinh  
✔️ Gender selection UI đẹp  
✔️ Navigation flow mượt mà  
✔️ Loading states rõ ràng  
✔️ Lưu vào Firestore  
✔️ Error handling  

🎉 **Sẵn sàng để test!**

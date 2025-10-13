# Tính năng Nhật ký Chi tiết - Hướng dẫn Sử dụng

## Tổng quan
Đã hoàn thiện trang chi tiết nhật ký với đầy đủ các tính năng quản lý và tùy chỉnh, kèm theo drawer (taskbar) và trang thùng rác.

---

## 🎨 Tính năng Trang Chi tiết Nhật ký

### 1. **Đổi Tag/Danh mục**
- Nhấn vào menu 3 chấm (⋮) ở góc phải trên
- Chọn "Đổi tag"
- Chọn danh mục mới: Ăn uống, Sức khỏe, Vui chơi, Tắm rửa

### 2. **Chỉnh sửa Nội dung**
- **Bấm đúp vào tiêu đề** → Mở dialog chỉnh sửa tiêu đề
- **Bấm đúp vào mô tả** → Mở dialog chỉnh sửa mô tả
- Thay đổi sẽ được lưu tự động

### 3. **Thêm Hình ảnh**
- Nhấn menu 3 chấm (⋮) → Chọn "Thêm hình"
- Chọn ảnh từ thư viện
- Hình ảnh sẽ hiển thị dưới mô tả (grid 100x100px)

### 4. **Đổi Màu Nền**
- Nhấn menu 3 chấm (⋮) → Chọn "Đổi màu nền"
- Chọn từ 6 màu preset:
  - Trắng (mặc định)
  - Vàng nhạt
  - Hồng nhạt
  - Xanh dương nhạt
  - Tím nhạt
  - Xanh lá nhạt

### 5. **Đặt Mật khẩu**
- Nhấn menu 3 chấm (⋮) → Chọn "Đặt mật khẩu"
- Nhập mật khẩu
- Icon khóa 🔒 sẽ xuất hiện bên cạnh danh mục

### 6. **Thêm vào Thư mục**
- Nhấn menu 3 chấm (⋮) → Chọn "Thêm vào thư mục"
- Chọn thư mục có sẵn:
  - Gia đình
  - Công việc
  - Du lịch
  - Cá nhân
- Badge thư mục sẽ hiển thị bên cạnh danh mục

### 7. **Xóa vào Thùng rác**
- Nhấn menu 3 chấm (⋮) → Chọn "Xóa"
- Xác nhận xóa
- Entry sẽ chuyển vào thùng rác và lưu trong **30 ngày**

---

## 📂 Drawer (Taskbar Trái)

### Mở Drawer
- Nhấn nút menu 3 gạch (☰) ở góc trái trên
- Drawer mở ra chiếm **1/3 màn hình** bên trái

### Chức năng trong Drawer

#### 1. **Tạo thư mục mới**
- Icon: 📁 (Create new folder)
- Nhấn → Mở dialog nhập tên thư mục
- Thư mục mới sẽ xuất hiện trong danh sách bên dưới

#### 2. **Thùng rác**
- Icon: 🗑️ (Delete outline)
- Badge đỏ hiển thị số lượng entry đã xóa
- Nhấn → Chuyển sang trang Thùng rác

#### 3. **Danh sách Thư mục**
- Hiển thị tất cả thư mục đã tạo
- Nhấn vào thư mục → Lọc entries theo thư mục (TODO)

---

## 🗑️ Trang Thùng rác

### Hiển thị
- Danh sách tất cả entries đã xóa
- Mỗi entry hiển thị:
  - Icon và màu danh mục
  - Tiêu đề và mô tả
  - **"Xóa sau X ngày"** (đếm ngược 30 ngày)

### Chức năng

#### 1. **Khôi phục**
- Nhấn menu 3 chấm (⋮) → Chọn "Khôi phục"
- Entry sẽ quay lại trang Nhật ký chính

#### 2. **Xóa vĩnh viễn**
- Nhấn menu 3 chấm (⋮) → Chọn "Xóa vĩnh viễn"
- Entry sẽ bị xóa vĩnh viễn, **không thể khôi phục**

---

## 📦 Package đã thêm

```yaml
image_picker: ^1.0.7  # Chọn ảnh từ thư viện/camera
```

### Import trong Code
```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';
```

---

## 🔧 Cấu trúc File

```
lib/screens/
  ├── diary_screen.dart      # Trang chính + Drawer
  └── trash_screen.dart      # Trang thùng rác
```

### State Management
- `diaryEntries`: Danh sách entries hiện tại
- `trashedEntries`: Danh sách entries đã xóa
- `folders`: Danh sách thư mục

---

## 🎯 Luồng Sử dụng

### Kịch bản 1: Thêm và tùy chỉnh entry
1. Nhấn nút ➕ (floating action button)
2. Điền tiêu đề, mô tả, chọn danh mục
3. Nhấn vào card entry → Vào trang chi tiết
4. Bấm đúp tiêu đề/mô tả để sửa
5. Menu 3 chấm → Thêm hình, đổi màu nền
6. Menu 3 chấm → Đặt mật khẩu, thêm vào thư mục

### Kịch bản 2: Quản lý thư mục
1. Mở drawer (menu 3 gạch)
2. Nhấn "Tạo thư mục mới"
3. Nhập tên thư mục (VD: "Sức khỏe Mochi")
4. Thư mục xuất hiện trong danh sách
5. Vào trang chi tiết entry → Thêm vào thư mục vừa tạo

### Kịch bản 3: Xóa và khôi phục
1. Vào trang chi tiết entry
2. Menu 3 chấm → Xóa
3. Entry chuyển vào thùng rác
4. Mở drawer → Nhấn "Thùng rác"
5. Chọn entry → Menu 3 chấm
6. Khôi phục hoặc Xóa vĩnh viễn

---

## ✅ Checklist Hoàn thành

- [x] Đổi tag/danh mục
- [x] Bấm đúp để edit tiêu đề
- [x] Bấm đúp để edit mô tả
- [x] Thêm hình ảnh (image picker)
- [x] Đổi màu nền (6 màu preset)
- [x] Đặt mật khẩu cho entry
- [x] Thêm vào thư mục
- [x] Xóa vào thùng rác (30 ngày)
- [x] Drawer chiếm 1/3 màn hình
- [x] Tạo thư mục mới
- [x] Danh sách thư mục trong drawer
- [x] Trang thùng rác
- [x] Khôi phục từ thùng rác
- [x] Xóa vĩnh viễn

---

## 🚀 Chạy ứng dụng

```bash
cd d:\dhv_assignments\DoAnChuyenNganh\ocean_pet
flutter pub get
flutter run
```

---

## 📝 Ghi chú

- **Mật khẩu**: Hiện tại chỉ lưu string, chưa có mã hóa
- **Thùng rác**: Tự động xóa sau 30 ngày (TODO: cần background task)
- **Lọc theo thư mục**: Chưa implement, có thể thêm sau
- **Upload ảnh**: Hiện chỉ lưu local path, chưa upload lên server

---

**Hoàn thành bởi**: GitHub Copilot  
**Ngày**: 13/10/2025

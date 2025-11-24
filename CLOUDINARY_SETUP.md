# 🖼️ Cloudinary Setup Guide - Ocean Pet Dating

## Bước 1: Tạo tài khoản Cloudinary

1. Truy cập [https://cloudinary.com/](https://cloudinary.com/)
2. Đăng ký tài khoản miễn phí
3. Xác nhận email

## Bước 2: Lấy Cloudinary Credentials

1. Vào **Dashboard** → copy **Cloud Name**
   - Ví dụ: `dxyzabc123`

2. Vào **Settings** → **Upload** → tìm **Upload Presets**
   - Tạo preset mới hoặc dùng preset có sẵn
   - **Unsigned presets** (không cần API Key - an toàn hơn)

3. Copy **Preset Name**
   - Ví dụ: `ocean_pet_unsigned`

## Bước 3: Cập nhật DatingService.dart

Mở `lib/services/DatingService.dart` → tìm dòng ~892:

```dart
// ❌ TRƯỚC (placeholder)
const String cloudName = 'YOUR_CLOUD_NAME';
const String uploadPreset = 'ocean_pet_unsigned';

// ✅ SAU (thay bằng giá trị thực)
const String cloudName = 'YOUR_CLOUD_NAME'; // Thay 'YOUR_CLOUD_NAME'
const String uploadPreset = 'YOUR_PRESET_NAME'; // Thay 'YOUR_PRESET_NAME'
```

### Ví dụ:
```dart
const String cloudName = 'dxyzabc123';
const String uploadPreset = 'ocean_pet_unsigned';
```

## Bước 4: Cấu hình Upload Preset (nếu tạo mới)

**Cloudinary Dashboard → Settings → Upload → Add upload preset**

Cấu hình:
```
✅ Mode: Unsigned (quan trọng - không cần API secret)
✅ Folder: /ocean_pet/dating (tùy chọn)
✅ Format: Auto
✅ Quality: Auto
✅ Eager transformations: 
   - Create thumbnail: yes
   - w_200, h_200, c_fill (cho video thumbnails)
```

## Bước 5: Test Upload

1. Chạy app: `flutter run`
2. Vào Dating → Chat → Chọn ảnh/video
3. Kiểm tra logs: nếu thấy "Cloudinary upload error" → cấu hình lại

## 🔐 Security Notes

- ✅ Dùng **Unsigned Upload Presets** (không cần API Secret)
- ✅ Giới hạn folder upload: `/ocean_pet/dating`
- ✅ Cloud Name không bí mật (hiển thị trong code)
- ❌ Không bao giờ commit API Secret

## 📊 Quản lý Media

**Cloudinary Media Library:**
- Vào Dashboard → Media Library
- Xem tất cả ảnh/video đã upload
- Xóa file cũ để tiết kiệm quota

## 💰 Pricing

- **Free Plan**: 25 GB/tháng
- **Video uploads**: 5 GB/tháng (free)
- **Recommended**: Dùng image optimizations tự động

## 🚀 Optimization Tips

### Auto thumbnail cho video:
```dart
// Cloudinary sẽ tự tạo thumbnail với eager transformations
final videoData = await DatingService.uploadVideoToCloudinary(
  filePath: video.path,
  folder: 'ocean_pet/dating/messages',
);
// Returns: videoUrl, thumbnailUrl, duration
```

### Tối ưu ảnh khi hiển thị:
```dart
// Thêm ?w_400,c_limit (tự động compress)
Image.network(
  imageUrl + '?w=400,c_limit',
  fit: BoxFit.cover,
)
```

## ❓ Troubleshooting

### ❌ "Cloudinary upload error: 400"
- **Nguyên nhân**: Cloud Name hoặc Preset sai
- **Fix**: Kiểm tra lại Dashboard

### ❌ "Cloudinary upload error: 401"
- **Nguyên nhân**: API Key sai (nếu dùng signed)
- **Fix**: Dùng Unsigned Preset

### ❌ Video upload timeout
- **Nguyên nhân**: File quá lớn hoặc network chậm
- **Fix**: Compress video trước upload

## 📚 Tài liệu

- [Cloudinary Flutter](https://cloudinary.com/documentation/flutter_integration)
- [Upload API Docs](https://cloudinary.com/documentation/image_upload_api_reference)
- [Video Upload Guide](https://cloudinary.com/documentation/video_upload_api_reference)

## 🎯 Next Steps

1. ✅ Setup Cloudinary account
2. ✅ Cấu hình DatingService
3. ✅ Test upload ảnh/video
4. ✅ Deploy app

---

**Version**: 1.0  
**Last Updated**: Nov 24, 2025

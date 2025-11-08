/// Cloudinary Configuration
/// 
/// HƯỚNG DẪN SETUP:
/// 
/// 1. Đăng nhập Cloudinary Console: https://cloudinary.com/console
/// 2. Lấy CLOUD_NAME (hiển thị ở góc trên trái)
/// 3. Tạo Upload Preset:
///    - Vào Settings ⚙️ → Upload → Upload presets
///    - Click "Add upload preset"
///    - Preset name: ocean_pet_preset
///    - Signing Mode: Unsigned
///    - Click Save
/// 4. Cập nhật các giá trị dưới đây

class CloudinaryConfig {
  // TODO: Thay đổi các giá trị sau khi setup Cloudinary
  
  /// Cloud Name từ Cloudinary Dashboard
  /// Vị trí: Dashboard → Account Details → Cloud name
  static const String cloudName = 'ocean_pet'; // ✅ Cloud name đã cấu hình
  
  /// Upload Preset (phải là Unsigned preset)
  /// Vị trí: Settings → Upload → Upload presets
  static const String uploadPreset = 'ocean_pet_preset'; // ⚠️ Cần tạo preset này trong Cloudinary Console
  
  /// API Key (optional - chỉ cần cho signed uploads)
  static const String apiKey = '733125922882981';
  
  /// API Secret (optional - KHÔNG nên để trong code production)
  /// Chỉ dùng cho server-side operations
  static const String apiSecret = '733125922882981';
  
  // Folders organization
  static const String petsFolder = 'pets';
  static const String diaryFolder = 'diary';
  static const String profileFolder = 'profile';
  static const String healthFolder = 'health';
  
  /// Validate configuration
  static bool isConfigured() {
    return cloudName.isNotEmpty && cloudName != 'YOUR_CLOUD_NAME';
  }
  
  /// Get error message if not configured
  static String getConfigError() {
    if (cloudName.isEmpty || cloudName == 'YOUR_CLOUD_NAME') {
      return '⚠️ Chưa cấu hình Cloud Name. Vui lòng cập nhật CloudinaryConfig.cloudName';
    }
    return '';
  }
  
  /// Get setup instructions
  static String getSetupInstructions() {
    return '''
📸 Cloudinary Setup - Bước tiếp theo:

1. Truy cập: https://cloudinary.com/console
2. Đăng nhập với account ocean_pet
3. Vào Settings ⚙️ → Upload → Upload presets
4. Click "Add upload preset"
5. Cấu hình:
   - Preset name: ocean_pet_preset
   - Signing Mode: Unsigned ✅
   - Click Save

Sau khi tạo xong, app sẽ sẵn sàng upload ảnh!
    ''';
  }
}

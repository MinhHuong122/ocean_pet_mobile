import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'CloudinaryConfig.dart';

/// Service để upload và quản lý ảnh với Cloudinary
/// Thay thế Firebase Storage
class CloudinaryService {
  static CloudinaryPublic? _cloudinary;

  /// Initialize Cloudinary instance
  static CloudinaryPublic _getCloudinary() {
    // Validate configuration
    if (!CloudinaryConfig.isConfigured()) {
      throw Exception(CloudinaryConfig.getConfigError());
    }
    
    _cloudinary ??= CloudinaryPublic(
      CloudinaryConfig.cloudName, 
      CloudinaryConfig.uploadPreset, 
      cache: false,
    );
    return _cloudinary!;
  }

  /// Upload single image to Cloudinary
  /// 
  /// Parameters:
  /// - [imageFile]: File ảnh cần upload
  /// - [folder]: Thư mục lưu trữ trên Cloudinary (vd: 'pets', 'diary', 'profile')
  /// - [fileName]: Tên file tùy chỉnh (optional)
  /// 
  /// Returns: URL của ảnh đã upload
  static Future<String> uploadImage(
    File imageFile,
    String folder, {
    String? fileName,
  }) async {
    try {
      final cloudinary = _getCloudinary();

      // Upload file to Cloudinary
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Return secure URL
      return response.secureUrl;
    } catch (e) {
      throw Exception('Lỗi upload ảnh lên Cloudinary: $e');
    }
  }

  /// Upload multiple images to Cloudinary
  /// 
  /// Parameters:
  /// - [imageFiles]: Danh sách file ảnh cần upload
  /// - [folder]: Thư mục lưu trữ trên Cloudinary
  /// 
  /// Returns: List các URL của ảnh đã upload
  static Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String folder,
  ) async {
    try {
      List<String> imageUrls = [];

      for (var imageFile in imageFiles) {
        String url = await uploadImage(imageFile, folder);
        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Lỗi upload nhiều ảnh: $e');
    }
  }

  /// Delete image from Cloudinary
  /// 
  /// Note: Cần sử dụng Cloudinary Admin API để delete
  /// Hiện tại cloudinary_public package không hỗ trợ delete
  /// Bạn cần implement bằng HTTP request trực tiếp hoặc dùng package cloudinary_api
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract public_id from URL
      // Example URL: https://res.cloudinary.com/demo/image/upload/v1234567890/pets/image.jpg
      // Public ID: pets/image
      
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length < 4) {
        throw Exception('Invalid Cloudinary URL');
      }
      
      // Get public_id (everything after "upload/vXXX/")
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex + 2 >= pathSegments.length) {
        throw Exception('Cannot extract public_id from URL');
      }
      
      // Skip version (vXXX) and get the rest
      final publicIdParts = pathSegments.sublist(uploadIndex + 2);
      final publicId = publicIdParts.join('/').replaceAll(RegExp(r'\.[^.]+$'), ''); // Remove extension
      
      print('TODO: Delete image with public_id: $publicId');
      print('Note: cloudinary_public không hỗ trợ delete. Cần dùng Cloudinary Admin API');
      
      // TODO: Implement delete using HTTP request with API Key and Secret
      // See: https://cloudinary.com/documentation/admin_api#delete_resources
      
    } catch (e) {
      throw Exception('Lỗi xóa ảnh trên Cloudinary: $e');
    }
  }

  /// Upload image for Pet
  /// Folder: pets/{userId}
  static Future<String> uploadPetImage(File imageFile, String userId) async {
    return await uploadImage(imageFile, 'pets/$userId');
  }

  /// Upload image for Diary
  /// Folder: diary/{userId}
  static Future<String> uploadDiaryImage(File imageFile, String userId) async {
    return await uploadImage(imageFile, 'diary/$userId');
  }

  /// Upload image for Profile Avatar
  /// Folder: profile/{userId}
  static Future<String> uploadProfileImage(File imageFile, String userId) async {
    return await uploadImage(imageFile, 'profile/$userId');
  }

  /// Upload image for Health Record
  /// Folder: health/{userId}
  static Future<String> uploadHealthRecordImage(File imageFile, String userId) async {
    return await uploadImage(imageFile, 'health/$userId');
  }

  /// Get optimized image URL with transformations
  /// 
  /// Example: Get thumbnail version (200x200)
  static String getOptimizedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? quality,
  }) {
    // Parse URL and inject transformations
    // Example: https://res.cloudinary.com/demo/image/upload/v1234/pets/image.jpg
    // Becomes: https://res.cloudinary.com/demo/image/upload/w_200,h_200,c_fill/v1234/pets/image.jpg
    
    try {
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments.toList();
      
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return originalUrl;
      
      // Build transformation string
      List<String> transformations = [];
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      if (quality != null) transformations.add('q_$quality');
      
      if (transformations.isEmpty) return originalUrl;
      
      // Insert transformations after "upload"
      pathSegments.insert(uploadIndex + 1, transformations.join(','));
      
      // Rebuild URL
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        pathSegments: pathSegments,
      ).toString();
    } catch (e) {
      return originalUrl;
    }
  }
}

// lib/services/ai_disease_service.dart
// AI Disease Detection Service (placeholder for Roboflow integration)
import 'dart:io';
import 'package:image/image.dart' as img;

class AIDiseaseService {
  /// Placeholder for AI model prediction
  /// In production: use tflite_flutter + Roboflow model
  static Future<DiseaseDetectionResult> detectDisease(
    File imageFile, {
    double confidenceThreshold = 0.6,
  }) async {
    try {
      // Read image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return DiseaseDetectionResult(
          detected: false,
          disease: null,
          confidence: 0,
          message: 'Không thể đọc file ảnh',
          recommendations: [],
        );
      }

      // TODO: Integrate with Roboflow API or tflite_flutter model
      // For now: return mock results
      return _getMockDetectionResult();
    } catch (e) {
      return DiseaseDetectionResult(
        detected: false,
        disease: null,
        confidence: 0,
        message: 'Lỗi xử lý ảnh: $e',
        recommendations: [],
      );
    }
  }

  /// Mock detection result for testing
  static DiseaseDetectionResult _getMockDetectionResult() {
    return DiseaseDetectionResult(
      detected: false,
      disease: null,
      confidence: 0,
      message: 'Chức năng nhận diện bệnh đang trong giai đoạn phát triển',
      recommendations: [
        'Vui lòng tải ảnh rõ ràng',
        'Đảm bảo ánh sáng đủ',
        'Chụp toàn bộ vùng bị ảnh hưởng',
      ],
    );
  }

  /// Get disease recommendations
  static List<String> getDiseaseRecommendations(String disease) {
    final recommendations = {
      'mange': [
        'Liên hệ bác sĩ thú y ngay',
        'Tắm bằng nước ấm và dầu gội chuyên biệt',
        'Cho uống vitamin tăng cường miễn dịch',
        'Khử trùng giường và đồ chơi',
      ],
      'ringworm': [
        'Cách ly thú cưng khỏi động vật khác',
        'Dùng kem chống nấm theo hướng dẫn',
        'Tắm với dầu gội chuyên biệt hàng 2 ngày',
        'Làm sạch môi trường thường xuyên',
      ],
      'allergy': [
        'Tìm nguyên nhân gây dị ứng',
        'Tắm thường xuyên với nước lạnh',
        'Thay đổi thức ăn nếu cần',
        'Sử dụng thuốc chống dị ứng khi cần thiết',
      ],
      'ear_infection': [
        'Vệ sinh tai thường xuyên',
        'Sử dụng dung dịch rửa tai',
        'Tránh để nước vào tai khi tắm',
        'Theo dõi dấu hiệu khác',
      ],
    };

    return recommendations[disease.toLowerCase()] ??
        [
          'Liên hệ bác sĩ thú y để được tư vấn chi tiết',
          'Giữ thú cưng ấm áp và thoải mái',
          'Theo dõi diễn tiến bệnh',
        ];
  }
}

class DiseaseDetectionResult {
  final bool detected;
  final String? disease;
  final double confidence;
  final String message;
  final List<String> recommendations;

  DiseaseDetectionResult({
    required this.detected,
    required this.disease,
    required this.confidence,
    required this.message,
    required this.recommendations,
  });
}

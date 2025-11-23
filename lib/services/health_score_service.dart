// lib/services/health_score_service.dart
import 'dart:math';

class HealthScoreService {
  /// Tính Health Score (0-100) dựa trên thông tin sức khỏe
  static int calculateHealthScore({
    required double weight,
    required double idealWeight,
    required int vaccinationCount,
    required bool teethHealthy,
    required String skinCondition, // 'excellent', 'good', 'fair', 'poor'
    required String coatCondition, // 'excellent', 'good', 'fair', 'poor'
    required int medicalHistoryCount,
    required int allergyCount,
    required bool isActive,
  }) {
    int score = 100;

    // 1. Cân nặng (25 điểm)
    final weightDiff = (weight - idealWeight).abs();
    final weightDeviation = (weightDiff / idealWeight) * 100;
    if (weightDeviation > 20) {
      score -= 25; // Quá nặng/nhẹ
    } else if (weightDeviation > 10) {
      score -= 15;
    } else if (weightDeviation > 5) {
      score -= 8;
    } else {
      score -= 0; // Cân nặng lý tưởng
    }

    // 2. Tiêm chủng (20 điểm)
    if (vaccinationCount >= 4) {
      score -= 0; // Đầy đủ tiêm chủng
    } else if (vaccinationCount >= 2) {
      score -= 5;
    } else if (vaccinationCount > 0) {
      score -= 12;
    } else {
      score -= 20; // Chưa tiêm chủng
    }

    // 3. Sức khỏe răng (15 điểm)
    if (!teethHealthy) {
      score -= 15; // Vấn đề với răng
    } else {
      score -= 0; // Răng khỏe mạnh
    }

    // 4. Tình trạng da (15 điểm)
    switch (skinCondition.toLowerCase()) {
      case 'excellent':
        score -= 0;
        break;
      case 'good':
        score -= 3;
        break;
      case 'fair':
        score -= 8;
        break;
      case 'poor':
        score -= 15;
        break;
      default:
        score -= 5;
    }

    // 5. Tình trạng lông (15 điểm)
    switch (coatCondition.toLowerCase()) {
      case 'excellent':
        score -= 0;
        break;
      case 'good':
        score -= 3;
        break;
      case 'fair':
        score -= 8;
        break;
      case 'poor':
        score -= 15;
        break;
      default:
        score -= 5;
    }

    // 6. Lịch sử bệnh lý (-5 điểm mỗi bệnh)
    score -= min(medicalHistoryCount * 5, 20);

    // 7. Dị ứng (-3 điểm mỗi dị ứng)
    score -= min(allergyCount * 3, 15);

    // 8. Hoạt động (+10 điểm nếu hoạt động)
    if (isActive) {
      score += 10;
    }

    // Đảm bảo score nằm trong khoảng 0-100
    return max(0, min(100, score));
  }

  /// Lấy mô tả và màu sắc dựa trên Health Score
  static Map<String, dynamic> getHealthScoreInfo(int score) {
    if (score >= 90) {
      return {
        'level': 'Tuyệt vời',
        'color': 0xFF4CAF50, // Green
        'description': 'Thú cưng của bạn có sức khỏe tuyệt vời!',
        'icon': '✨',
      };
    } else if (score >= 75) {
      return {
        'level': 'Tốt',
        'color': 0xFF8BC34A, // Light Green
        'description': 'Sức khỏe tốt, hãy tiếp tục duy trì.',
        'icon': '😊',
      };
    } else if (score >= 60) {
      return {
        'level': 'Trung bình',
        'color': 0xFFFFC107, // Amber
        'description': 'Cần cải thiện một số khía cạnh sức khỏe.',
        'icon': '😐',
      };
    } else if (score >= 40) {
      return {
        'level': 'Yếu',
        'color': 0xFFFF9800, // Orange
        'description': 'Cần chú ý đến sức khỏe của thú cưng.',
        'icon': '😟',
      };
    } else {
      return {
        'level': 'Cảnh báo',
        'color': 0xFFF44336, // Red
        'description': 'Tình trạng sức khỏe đáng lo ngại, liên hệ bác sĩ.',
        'icon': '⚠️',
      };
    }
  }

  /// Tạo recommendations dựa trên Health Score (ít nhất 3 lời khuyên)
  static List<String> getRecommendations({
    required double weight,
    required double idealWeight,
    required int vaccinationCount,
    required bool teethHealthy,
    required String skinCondition,
    required String coatCondition,
    required int medicalHistoryCount,
    required int allergyCount,
    required bool isActive,
  }) {
    List<String> recommendations = [];

    // Kiểm tra cân nặng
    final weightDiff = (weight - idealWeight).abs();
    final weightDeviation = (weightDiff / idealWeight) * 100;
    if (weightDeviation > 10) {
      if (weight > idealWeight) {
        recommendations.add('Cần giảm cân: Tăng vận động và kiểm soát lượng thức ăn');
      } else {
        recommendations.add('Cần tăng cân: Cải thiện chất lượng thức ăn và bổ sung dinh dưỡng');
      }
    }

    // Kiểm tra tiêm chủng
    if (vaccinationCount < 4) {
      recommendations.add('Hoàn thành lịch tiêm chủng đầy đủ');
    }

    // Kiểm tra sức khỏe răng
    if (!teethHealthy) {
      recommendations.add('Tăng vệ sinh răng: Đánh răng thường xuyên và kiểm tra với bác sĩ');
    }

    // Kiểm tra tình trạng da
    if (skinCondition.toLowerCase() == 'poor' ||
        skinCondition.toLowerCase() == 'fair') {
      recommendations.add(
          'Kiểm tra và chữa trị vấn đề da với bác sĩ thú y');
    }

    // Kiểm tra lông
    if (coatCondition.toLowerCase() == 'poor' ||
        coatCondition.toLowerCase() == 'fair') {
      recommendations.add(
          'Cải thiện chất lượng lông: Tăng Omega-3 và dưỡng ẩm');
    }

    // Kiểm tra hoạt động
    if (!isActive) {
      recommendations.add('Tăng thời gian vận động: Ít nhất 30 phút mỗi ngày');
    }

    // Kiểm tra dị ứng
    if (allergyCount > 0) {
      recommendations.add('Tránh các allergen đã phát hiện');
    }

    // Kiểm tra lịch sử bệnh lý
    if (medicalHistoryCount > 2) {
      recommendations.add('Kiểm tra sức khỏe định kỳ mỗi 3-6 tháng');
    }

    // Đảm bảo ít nhất 3 lời khuyên
    if (recommendations.length < 3) {
      // Thêm lời khuyên chung
      recommendations.add('Duy trì chế độ ăn uống cân bằng và đủ dinh dưỡng');
      
      if (recommendations.length < 3) {
        recommendations.add('Thăm bác sĩ thú y định kỳ 6 tháng/lần để kiểm tra sức khỏe');
      }
      
      if (recommendations.length < 3) {
        recommendations.add('Cung cấp nước sạch và tươi mát cho thú cưng mỗi ngày');
      }
    }

    return recommendations;
  }
}

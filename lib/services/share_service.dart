// lib/services/share_service.dart
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ShareService {
  /// Share PDF qua WhatsApp
  static Future<void> shareViaWhatsApp({
    required String phoneNumber,
    required String message,
    File? pdfFile,
  }) async {
    try {
      String whatsappUrl;

      if (Platform.isAndroid) {
        // Android: sử dụng intent schema
        whatsappUrl = 'whatsapp://send?phone=$phoneNumber&text=$message';
      } else if (Platform.isIOS) {
        // iOS: sử dụng URL scheme
        whatsappUrl =
            'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
      } else {
        throw 'Platform không được hỗ trợ';
      }

      // Nếu có file PDF, sử dụng Share API
      if (pdfFile != null) {
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: message,
        );
      } else {
        // Nếu không có file, mở WhatsApp trực tiếp
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl));
        } else {
          throw 'Không thể mở WhatsApp';
        }
      }
    } catch (e) {
      print('Lỗi chia sẻ qua WhatsApp: $e');
      rethrow;
    }
  }

  /// Share PDF qua Zalo
  static Future<void> shareViaZalo({
    required String message,
    File? pdfFile,
  }) async {
    try {
      if (pdfFile != null) {
        // Share file với Zalo
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: message,
          subject: 'Hồ sơ y tế thú cưng từ Ocean Pet',
        );
      } else {
        // Share text trực tiếp
        await Share.share(message);
      }
    } catch (e) {
      print('Lỗi chia sẻ qua Zalo: $e');
      rethrow;
    }
  }

  /// Share PDF qua Email
  static Future<void> shareViaEmail({
    required String recipientEmail,
    required String subject,
    required String body,
    File? pdfFile,
  }) async {
    try {
      if (pdfFile != null) {
        await Share.shareXFiles(
          [XFile(pdfFile.path)],
          text: '$subject\n\n$body',
        );
      } else {
        final emailUrl = 'mailto:$recipientEmail?subject=$subject&body=$body';
        if (await canLaunchUrl(Uri.parse(emailUrl))) {
          await launchUrl(Uri.parse(emailUrl));
        } else {
          throw 'Không thể mở email';
        }
      }
    } catch (e) {
      print('Lỗi chia sẻ qua Email: $e');
      rethrow;
    }
  }

  /// Share với tuỳ chọn (chọn app để chia sẻ)
  static Future<void> shareWithOptions({
    required String message,
    required String subject,
    File? file,
  }) async {
    try {
      if (file != null) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
          subject: subject,
        );
      } else {
        await Share.share(
          message,
          subject: subject,
        );
      }
    } catch (e) {
      print('Lỗi chia sẻ: $e');
      rethrow;
    }
  }

  /// Tạo message template cho bác sĩ
  static String createDoctorMessage({
    required String petName,
    required String ownerName,
    required int healthScore,
    required String concerns,
  }) {
    return '''
Xin chào bác sĩ,

Tôi là $ownerName, chủ sở hữu của $petName. 

Tôi đang sử dụng ứng dụng Ocean Pet để quản lý sức khỏe thú cưng. Hiện tại, điểm sức khỏe của $petName là $healthScore/100.

Vấn đề cần tư vấn: $concerns

Tôi đã đính kèm hồ sơ y tế đầy đủ. Bạn có thể xem chi tiết trong file PDF kèm theo.

Cảm ơn bác sĩ!
    '''.trim();
  }
}

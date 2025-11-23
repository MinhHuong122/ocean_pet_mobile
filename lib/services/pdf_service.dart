// lib/services/pdf_service.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr/qr.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PDFService {
  /// Tạo PDF hồ sơ y tế đẹp với logo, mã QR
  static Future<File> generateMedicalRecordPDF({
    required String petName,
    required String petBreed,
    required String ownerName,
    required String ownerPhone,
    required List<Map<String, dynamic>> medicalHistories,
    required List<Map<String, dynamic>> allergies,
    required List<Map<String, dynamic>> medications,
    required int healthScore,
  }) async {
    final pdf = pw.Document();

    // Tạo mã QR
    final qrCode = QrCode(3, QrErrorCorrectLevel.L);
    qrCode.addData('Pet: $petName | Owner: $ownerName | Phone: $ownerPhone');
    final qrImage = QrImage(qrCode);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          // Header
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF8B5CF6),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'OCEAN PET',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      'Hồ Sơ Y Tế Thú Cưng',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  width: 80,
                  height: 80,
                  child: pw.Image(
                    pw.MemoryImage(
                      _encodeQrImage(qrImage),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Thông tin thú cưng
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromInt(0xFF8B5CF6)),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'THÔNG TIN THÚ CƯNG',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF8B5CF6),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Tên thú cưng:',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          petName,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Giống loại:',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          petBreed,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Thông tin chủ sở hữu
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromInt(0xFF8B5CF6)),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'THÔNG TIN CHỦ SỞ HỮU',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF8B5CF6),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Họ tên:',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          ownerName,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Điện thoại:',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          ownerPhone,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Health Score
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF3F4F6),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Điểm Sức Khỏe',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '$healthScore/100',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  width: 100,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    color: _getHealthScoreColor(healthScore),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    _getHealthScoreLevel(healthScore),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Lịch sử bệnh lý
          if (medicalHistories.isNotEmpty) ...[
            pw.Text(
              'LỊCH SỬ BỆNH LÝ',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF8B5CF6),
              ),
            ),
            pw.SizedBox(height: 8),
            ...medicalHistories.map((history) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE5E7EB)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      history['condition'] ?? 'N/A',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Ngày: ${history['date'] ?? 'N/A'} | Bác sĩ: ${history['doctor'] ?? 'N/A'}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            )),
            pw.SizedBox(height: 12),
          ],

          // Dị ứng
          if (allergies.isNotEmpty) ...[
            pw.Text(
              'DỊ ỨNG',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF8B5CF6),
              ),
            ),
            pw.SizedBox(height: 8),
            ...allergies.map((allergy) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE5E7EB)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      allergy['allergen'] ?? 'N/A',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Mức độ: ${allergy['severity'] ?? 'N/A'} | Triệu chứng: ${allergy['symptoms'] ?? 'N/A'}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            )),
            pw.SizedBox(height: 12),
          ],

          // Thuốc đang sử dụng
          if (medications.isNotEmpty) ...[
            pw.Text(
              'THUỐC ĐANG SỬ DỤNG',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF8B5CF6),
              ),
            ),
            pw.SizedBox(height: 8),
            ...medications.map((med) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE5E7EB)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      med['name'] ?? 'N/A',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Liều lượng: ${med['dosage'] ?? 'N/A'} | Tần suất: ${med['frequency'] ?? 'N/A'}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            )),
          ],

          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Tài liệu này được tạo bởi Ocean Pet - Ứng dụng quản lý sức khỏe thú cưng',
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Ngày tạo: ${DateTime.now().toString().split('.')[0]}',
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    // Lưu file
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/medical_record_$petName.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Mã hóa QR image thành bytes
  static Uint8List _encodeQrImage(QrImage qrImage) {
    const int imageSize = 200;
    final list = Int32List(imageSize * imageSize);
    for (int x = 0; x < imageSize; x++) {
      for (int y = 0; y < imageSize; y++) {
        list[y * imageSize + x] =
            qrImage.isDark(y, x) ? 0xFF000000 : 0xFFFFFFFF;
      }
    }
    return list.buffer.asUint8List();
  }

  /// Lấy màu dựa trên Health Score
  static PdfColor _getHealthScoreColor(int score) {
    if (score >= 90) {
      return PdfColor.fromInt(0xFF4CAF50); // Green
    } else if (score >= 75) {
      return PdfColor.fromInt(0xFF8BC34A); // Light Green
    } else if (score >= 60) {
      return PdfColor.fromInt(0xFFFFC107); // Amber
    } else if (score >= 40) {
      return PdfColor.fromInt(0xFFFF9800); // Orange
    } else {
      return PdfColor.fromInt(0xFFF44336); // Red
    }
  }

  /// Lấy mức độ sức khỏe
  static String _getHealthScoreLevel(int score) {
    if (score >= 90) return 'Tuyệt vời';
    if (score >= 75) return 'Tốt';
    if (score >= 60) return 'Trung bình';
    if (score >= 40) return 'Yếu';
    return 'Cảnh báo';
  }
}

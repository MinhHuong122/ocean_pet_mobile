// lib/widgets/ai_disease_detector.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_disease_service.dart';

class AIDiseaseDetector extends StatefulWidget {
  const AIDiseaseDetector({Key? key}) : super(key: key);

  @override
  State<AIDiseaseDetector> createState() => _AIDiseaseDetectorState();
}

class _AIDiseaseDetectorState extends State<AIDiseaseDetector> {
  bool isLoading = false;
  DiseaseDetectionResult? result;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      setState(() => isLoading = true);

      final result = await AIDiseaseService.detectDisease(
        File(image.path),
      );

      setState(() {
        this.result = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDocTypeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.blue[600], size: 14),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.afacad(
                fontSize: 12,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân Tích Tài Liệu Y Tế',
                  style: GoogleFonts.afacad(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tải ảnh tài liệu y tế (kết quả xét nghiệm, chẩn đoán, v.v.) để nhận được giải thích dễ hiểu và lời khuyên chăm sóc',
                  style: GoogleFonts.afacad(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Information Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Loại tài liệu được hỗ trợ:',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDocTypeItem('Kết quả xét nghiệm máu, nước tiểu'),
                        _buildDocTypeItem('Ảnh X-quang, siêu âm'),
                        _buildDocTypeItem('Đơn thuốc, hóa đơn khám'),
                        _buildDocTypeItem('Giấy chứng nhận tiêm chủng'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Image picker buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      'Chụp Ảnh',
                      style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.image),
                    label: Text(
                      'Chọn Từ Thư Viện',
                      style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5CF6),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang phân tích ảnh...',
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Result
          if (result != null && !isLoading) ...[
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.blue[300]!,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Header
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.blue[700],
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kết Quả Phân Tích',
                                  style: GoogleFonts.afacad(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                if (result!.disease != null)
                                  Text(
                                    result!.disease!,
                                    style: GoogleFonts.afacad(
                                      fontSize: 13,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Explanation Section
                      SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giải Thích:',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              result!.message,
                              style: GoogleFonts.afacad(
                                fontSize: 13,
                                color: Colors.blue[800],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recommendations Section
                      if (result!.recommendations.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Colors.green[700],
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Lời Khuyên Chăm Sóc',
                                    style: GoogleFonts.afacad(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                children: result!.recommendations
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.green[600],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${entry.key + 1}',
                                                  style: GoogleFonts.afacad(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                entry.value,
                                                style: GoogleFonts.afacad(
                                                  fontSize: 12,
                                                  color: Colors.green[800],
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Doctor consultation button
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sẽ kết nối bạn với bác sĩ thú y',
                                  style: GoogleFonts.afacad(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(Icons.phone),
                          label: Text(
                            'Liên Hệ Bác Sĩ Thú Y',
                            style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          SizedBox(height: 40),
        ],
      ),
    );
  }
}

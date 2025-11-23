// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  String? _detectionResult;
  bool _isDetecting = false;
  final ImagePicker _imagePicker = ImagePicker();

  // Mock breed detection data
  final Map<String, List<String>> breedDatabase = {
    'Chó': [
      'Chó Phú Quốc',
      'Chó Pitbull',
      'Chó Husky',
      'Chó Corgi',
      'Chó Golden Retriever',
      'Chó Poodle',
      'Chó Beagle',
      'Chó Shiba Inu',
      'Chó Pug',
      'Chó Becgie Đức',
    ],
    'Mèo': [
      'Mèo Ba Tư',
      'Mèo Anh lông ngắn',
      'Mèo Siamese',
      'Mèo Bengal',
      'Mèo Maine Coon',
      'Mèo Ragdoll',
      'Mèo Sphynx',
      'Mèo Munchkin',
      'Mèo Russian Blue',
      'Mèo Tabby',
    ],
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _detectionResult = null;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Lỗi chọn ảnh: $e');
    }
  }

  Future<void> _detectBreed() async {
    if (_selectedImage == null) {
      _showSnackBar('Vui lòng chọn ảnh trước');
      return;
    }

    setState(() => _isDetecting = true);

    try {
      // Simulate AI detection delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock detection - in real app, would use tflite_flutter or API
      final isPet = _simulateAIDetection();

      if (isPet) {
        final result = _generateMockDetection();
        setState(() => _detectionResult = result);
        _showDetectionResult();
      } else {
        setState(() =>
            _detectionResult =
                'Không phát hiện chó/mèo trong ảnh. Vui lòng thử ảnh khác.');
        _showDetectionResult();
      }
    } catch (e) {
      _showSnackBar('Lỗi nhận diện: $e');
    } finally {
      setState(() => _isDetecting = false);
    }
  }

  bool _simulateAIDetection() {
    // Random detection simulation
    return DateTime.now().millisecond % 2 == 0;
  }

  String _generateMockDetection() {
    final isDog = DateTime.now().millisecond % 2 == 0;
    final petType = isDog ? 'Chó' : 'Mèo';
    final breeds = breedDatabase[petType]!;
    final breed = breeds[DateTime.now().millisecond % breeds.length];
    final confidence = 85 + (DateTime.now().millisecond % 15);

    return 'Loài: $petType\nGiống: $breed\nĐộ chính xác: $confidence%';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetectionResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Kết quả nhận diện',
          style: GoogleFonts.afacad(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            _detectionResult ?? 'Không có kết quả',
            style: GoogleFonts.afacad(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.afacad(
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Camera - Nhận diện',
          style: GoogleFonts.afacad(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image preview or placeholder
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chọn ảnh để nhận diện',
                          style: GoogleFonts.afacad(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),

            // Image selection buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Thư viện'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E97FD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detect button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDetecting ? null : _detectBreed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  disabledBackgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isDetecting
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Nhận diện giống chó/mèo',
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mẹo sử dụng:',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Chụp ảnh với ánh sáng tốt\n• Đầu chó/mèo rõ ràng trong ảnh\n• Tránh ảnh mờ hoặc bị cắt\n• Thử nhiều góc nhìn khác nhau',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/nutrition_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/FirebaseService.dart';

class NutritionScreen extends StatefulWidget {
  final Map<String, dynamic>? petData;

  const NutritionScreen({
    super.key,
    this.petData,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedPetId;
  String _selectedPetType = 'Chó';
  List<Map<String, dynamic>> _petsList = [];
  String? _healthStatus;
  String? _recommendation;
  bool _isLoadingAI = false;
  bool _isLoadingPets = false;

  // Gemini API
  static const String _geminiApiKey = 'AIzaSyAOkwaRgulW9Vu-8rHADj6Ugeb6qcf1BQ8';
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  final Map<String, Map<String, Map<String, dynamic>>> _healthStandards = {
    'Chó': {
      'Con': {'minWeight': 2.0, 'maxWeight': 10.0, 'minHeight': 15.0, 'maxHeight': 30.0},
      'Trưởng thành': {'minWeight': 10.0, 'maxWeight': 40.0, 'minHeight': 30.0, 'maxHeight': 60.0},
      'Già': {'minWeight': 8.0, 'maxWeight': 35.0, 'minHeight': 25.0, 'maxHeight': 55.0},
    },
    'Mèo': {
      'Con': {'minWeight': 0.5, 'maxWeight': 3.0, 'minHeight': 10.0, 'maxHeight': 20.0},
      'Trưởng thành': {'minWeight': 3.0, 'maxWeight': 7.0, 'minHeight': 20.0, 'maxHeight': 30.0},
      'Già': {'minWeight': 2.5, 'maxWeight': 6.0, 'minHeight': 18.0, 'maxHeight': 28.0},
    },
    'Chim': {
      'Con': {'minWeight': 0.02, 'maxWeight': 0.1, 'minHeight': 5.0, 'maxHeight': 15.0},
      'Trưởng thành': {'minWeight': 0.1, 'maxWeight': 0.5, 'minHeight': 15.0, 'maxHeight': 30.0},
      'Già': {'minWeight': 0.08, 'maxWeight': 0.4, 'minHeight': 13.0, 'maxHeight': 28.0},
    },
  };

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    try {
      setState(() => _isLoadingPets = true);
      
      final userId = FirebaseService.currentUserId;
      if (userId != null) {
        final petsStream = FirebaseService.getUserPets();
        final petsList = await petsStream.first;
        
        setState(() {
          _petsList = petsList;
          _isLoadingPets = false;
        });
      }
    } catch (e) {
      print('Error loading pets from Firebase: $e');
      setState(() => _isLoadingPets = false);
    }
  }

  void _onPetSelected(Map<String, dynamic> pet) {
    setState(() {
      _selectedPetId = pet['id'];
      _selectedPetType = pet['type'] ?? 'Chó';
      
      final weight = pet['weight'];
      final height = pet['height'];
      final age = pet['age'];
      
      if (weight != null) {
        _weightController.text = weight.toString();
      }
      if (height != null) {
        _heightController.text = height.toString();
      }
      if (age != null) {
        _ageController.text = age.toString();
      }
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _checkHealth() {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng nhập đầy đủ thông tin',
            style: GoogleFonts.afacad(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng nhập số hợp lệ',
            style: GoogleFonts.afacad(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get age category from input
    String ageCategory = _ageController.text.contains('Con') || _ageController.text.contains('con') ? 'Con'
        : _ageController.text.contains('Già') || _ageController.text.contains('già') ? 'Già'
        : 'Trưởng thành';

    final standard = _healthStandards[_selectedPetType]![ageCategory]!;
    final minWeight = (standard['minWeight'] as num).toDouble();
    final maxWeight = (standard['maxWeight'] as num).toDouble();
    final minHeight = (standard['minHeight'] as num).toDouble();
    final maxHeight = (standard['maxHeight'] as num).toDouble();

    String status;

    // Check weight and height
    if (weight < minWeight) {
      status = 'Thiếu cân';
    } else if (weight > maxWeight) {
      status = 'Thừa cân';
    } else if (height < minHeight || height > maxHeight) {
      status = 'Chiều cao bất thường';
    } else {
      status = 'Khỏe mạnh';
    }

    setState(() {
      _healthStatus = status;
      _isLoadingAI = true;
    });

    // Gọi Gemini để phân tích chi tiết
    _callGeminiForNutrition(
      petType: _selectedPetType,
      age: _ageController.text,
      weight: weight,
      height: height,
      status: status,
      minWeight: minWeight,
      maxWeight: maxWeight,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  Future<void> _callGeminiForNutrition({
    required String petType,
    required String age,
    required double weight,
    required double height,
    required String status,
    required double minWeight,
    required double maxWeight,
    required double minHeight,
    required double maxHeight,
  }) async {
    try {
      // Tính BMI (đơn giản hóa cho động vật)
      double bmi = weight / ((height / 100) * (height / 100));

      final prompt = '''
Bạn là bác sĩ thú y chuyên môn cao. Hãy phân tích tình trạng sức khỏe và đưa ra lời khuyên dinh dưỡng chi tiết cho thú cưng.

Thông tin thú cưng:
- Loài: $petType
- Độ tuổi: $age
- Cân nặng hiện tại: ${weight}kg
- Chiều cao: ${height}cm
- Chỉ số BMI (tham khảo): ${bmi.toStringAsFixed(2)}

Tiêu chuẩn cân nặng cho loài này ở độ tuổi này:
- Cân nặng lý tưởng: ${minWeight}kg - ${maxWeight}kg
- Chiều cao lý tưởng: ${minHeight}cm - ${maxHeight}cm

Tình trạng hiện tại: $status

Dựa trên các thông tin trên, vui lòng:
1. Đánh giá tình trạng sức khỏe chi tiết
2. Phân tích nguyên nhân nếu có vấn đề
3. Đưa ra lời khuyên cụ thể về:
   - Loại thức ăn nên cho ăn
   - Khẩu phần ăn hàng ngày (số bữa, lượng)
   - Cách bổ sung dinh dưỡng
   - Hoạt động thể chất cần thiết
   - Khoảng thời gian để kiểm tra lại
4. Danh sách các triệu chứng cần lưu ý

Hãy trả lời chi tiết, dễ hiểu, bằng tiếng Việt, với format dễ đọc.
''';

      final response = await http.post(
        Uri.parse(_geminiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _geminiApiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendation = data['candidates'][0]['content']['parts'][0]['text'] ?? 
            'Không thể lấy khuyến cáo. Vui lòng liên hệ hỗ trợ.';

        if (mounted) {
          setState(() {
            _recommendation = recommendation;
            _isLoadingAI = false;
          });
        }
      } else {
        _setFallbackRecommendation(status);
      }
    } catch (e) {
      print('Error calling Gemini: $e');
      _setFallbackRecommendation(status);
    }
  }

  void _setFallbackRecommendation(String status) {
    String recommendation;

    switch (status) {
      case 'Thiếu cân':
        recommendation = '''
Tình trạng: Thiếu cân
Nguyên nhân có thể: Dinh dưỡng không đủ, bệnh tật, hoặc chế độ ăn không phù hợp

Khuyến cáo dinh dưỡng:
1. Loại thức ăn:
   - Thức ăn giàu protein (30-40%)
   - Hàm lượng chất béo cao hơn bình thường
   - Carbohydrate chất lượng cao
   - Bổ sung vitamin và khoáng chất

2. Khẩu phần hàng ngày:
   - Chia thành 3-4 bữa nhỏ thay vì 1-2 bữa lớn
   - Mỗi bữa ăn khoảng 15-20 phút
   - Tăng từ từ lượng thức ăn

3. Cách bổ sung:
   - Dầu cá (Omega-3)
   - Bột xương
   - Men tiêu hóa
   - Trứng luộc (2-3 lần/tuần)

4. Lưu ý quan trọng:
   - Kiểm tra sức khỏe tổng quát
   - Đến thăm bác sĩ thú y nếu không cải thiện sau 2 tuần
   - Theo dõi cân nặng hàng tuần
        ''';
        break;

      case 'Thừa cân':
        recommendation = '''
Tình trạng: Thừa cân
Nguyên nhân: Ăn quá nhiều, thiếu hoạt động, hoặc các vấn đề chuyển hóa

Khuyến cáo dinh dưỡng:
1. Loại thức ăn:
   - Thức ăn giảm calo (75-80% thức ăn thường)
   - Hàm lượng chất xơ cao
   - Giàu protein (để giữ cơ bắp)
   - Hạn chế chất béo

2. Khẩu phần hàng ngày:
   - Giảm 20-30% lượng thức ăn hiện tại
   - Chia thành 2-3 bữa
   - Mỗi bữa cách nhau 6-8 tiếng
   - Tránh ăn vặt, xin đồ ăn

3. Hoạt động thể chất:
   - Tập luyện 30-45 phút mỗi ngày
   - Chơi đùa, chạy bộ, bơi lội
   - Tăng từ từ cường độ hoạt động

4. Lưu ý quan trọng:
   - KHÔNG cô đặc quá nhanh (nguy hiểm)
   - Kiểm tra cân nặng hàng tuần
   - Liên hệ bác sĩ nếu không giảm trong 4 tuần
   - Tránh thức ăn con người hoàn toàn
        ''';
        break;

      case 'Chiều cao bất thường':
        recommendation = '''
Tình trạng: Chiều cao bất thường so với chuẩn
Nguyên nhân có thể: Chủng loại khác nhau, di truyền, hoặc vấn đề phát triển

Khuyến cáo dinh dưỡng:
1. Loại thức ăn:
   - Thức ăn phát triển toàn diện
   - Giàu canxi và phosphor
   - Vitamin D đầy đủ
   - Protein cao

2. Khẩu phần hàng ngày:
   - Tuân theo khuyến cáo của bác sĩ
   - Bổ sung calci: 1-2% khẩu phần
   - Vitamin D hàng ngày

3. Bổ sung chuyên biệt:
   - Bột xương
   - Dầu cá (Omega-3)
   - Vitamin tổng hợp

4. Lưu ý quan trọng:
   - Thăm khám bác sĩ ngay
   - Chụp X-quang kiểm tra
   - Theo dõi sự phát triển hàng tháng
   - Loại trừ bệnh tật
        ''';
        break;

      default: // Khỏe mạnh
        recommendation = '''
Tình trạng: Khỏe mạnh 🎉
Chỉ số: Cân nặng, chiều cao, tình trạng dinh dưỡng đều bình thường

Khuyến cáo dinh dưỡng:
1. Loại thức ăn:
   - Thức ăn chất lượng cao với dinh dưỡng cân đối
   - Protein: 25-30%
   - Chất béo: 10-15%
   - Carbohydrate: 40-50%

2. Khẩu phần hàng ngày:
   - Tuân theo hướng dẫn trên bao thức ăn
   - Chia thành 1-2 bữa (tùy độ tuổi)
   - Nước sạch sẵn cả ngày

3. Để duy trì sức khỏe:
   - Tập luyện đều đặn: 30-60 phút/ngày
   - Thỏa mãn nhu cầu tâm lý
   - Vệ sinh môi trường sống tốt

4. Kiểm tra định kỳ:
   - Khám sức khỏe 6 tháng/lần
   - Tiêm phòng đầy đủ
   - Làm sạch răng, kiểm tra tai, mắt
   - Cân nặng hàng 3 tháng

Chúc mừng! Bạn đang chăm sóc thú cưng rất tốt! 💚
        ''';
    }

    if (mounted) {
      setState(() {
        _recommendation = recommendation;
        _isLoadingAI = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kế hoạch dinh dưỡng',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E97FD), Color(0xFF5C6BC0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đánh giá sức khỏe',
                          style: GoogleFonts.afacad(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nhập thông tin để kiểm tra',
                          style: GoogleFonts.afacad(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pet Selection Dropdown
            Text(
              'Chọn thú cưng',
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingPets)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF8E97FD).withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedPetId,
                hint: Text(
                  'Chọn thú cưng từ danh sách',
                  style: GoogleFonts.afacad(color: Colors.grey),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _petsList.map((pet) {
                  return DropdownMenuItem<String>(
                    value: pet['id'],
                    child: Text(
                      '${pet['name']} (${pet['type']})',
                      style: GoogleFonts.afacad(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final selectedPet = _petsList.firstWhere((pet) => pet['id'] == value);
                    _onPetSelected(selectedPet);
                  }
                },
              ),
            const SizedBox(height: 20),

            // Age Input
            Text(
              'Độ tuổi (tuần/tháng/năm)',
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ageController,
              style: GoogleFonts.afacad(),
              decoration: InputDecoration(
                hintText: 'VD: 2 tháng, 1 năm',
                hintStyle: GoogleFonts.afacad(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Height Input
            Text(
              'Chiều cao (cm)',
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.afacad(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Nhập chiều cao',
                hintStyle: GoogleFonts.afacad(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.height, color: Color(0xFF8E97FD)),
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Weight Input
            Text(
              'Cân nặng (kg)',
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.afacad(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Nhập cân nặng',
                hintStyle: GoogleFonts.afacad(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.monitor_weight, color: Color(0xFF8E97FD)),
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Check Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingAI ? null : _checkHealth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E97FD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoadingAI
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Kiểm tra sức khỏe',
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Result
            if (_healthStatus != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tình trạng: $_healthStatus',
                            style: GoogleFonts.afacad(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingAI)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF8E97FD),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Đang phân tích dữ liệu với AI...',
                                style: GoogleFonts.afacad(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_recommendation != null)
                      SingleChildScrollView(
                        child: Text(
                          _recommendation!,
                          style: GoogleFonts.afacad(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                            height: 1.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_healthStatus) {
      case 'Khỏe mạnh':
        return const Color(0xFF66BB6A);
      case 'Thiếu cân':
      case 'Thừa cân':
        return const Color(0xFF8E97FD);
      default:
        return const Color(0xFFEF5350);
    }
  }

  IconData _getStatusIcon() {
    switch (_healthStatus) {
      case 'Khỏe mạnh':
        return Icons.check_circle;
      case 'Thiếu cân':
      case 'Thừa cân':
        return Icons.warning;
      default:
        return Icons.error;
    }
  }
}

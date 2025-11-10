// lib/screens/nutrition_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _selectedPetType = 'Chó';
  String _selectedAge = 'Con';
  String? _healthStatus;
  String? _recommendation;

  final Map<String, Map<String, Map<String, dynamic>>> _healthStandards = {
    'Chó': {
      'Con': {'minWeight': 2, 'maxWeight': 10, 'minHeight': 15, 'maxHeight': 30},
      'Trưởng thành': {'minWeight': 10, 'maxWeight': 40, 'minHeight': 30, 'maxHeight': 60},
      'Già': {'minWeight': 8, 'maxWeight': 35, 'minHeight': 25, 'maxHeight': 55},
    },
    'Mèo': {
      'Con': {'minWeight': 0.5, 'maxWeight': 3, 'minHeight': 10, 'maxHeight': 20},
      'Trưởng thành': {'minWeight': 3, 'maxWeight': 7, 'minHeight': 20, 'maxHeight': 30},
      'Già': {'minWeight': 2.5, 'maxWeight': 6, 'minHeight': 18, 'maxHeight': 28},
    },
    'Chim': {
      'Con': {'minWeight': 0.02, 'maxWeight': 0.1, 'minHeight': 5, 'maxHeight': 15},
      'Trưởng thành': {'minWeight': 0.1, 'maxWeight': 0.5, 'minHeight': 15, 'maxHeight': 30},
      'Già': {'minWeight': 0.08, 'maxWeight': 0.4, 'minHeight': 13, 'maxHeight': 28},
    },
  };

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _checkHealth() {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
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

    final standard = _healthStandards[_selectedPetType]![_selectedAge]!;
    final minWeight = standard['minWeight'] as double;
    final maxWeight = standard['maxWeight'] as double;
    final minHeight = standard['minHeight'] as double;
    final maxHeight = standard['maxHeight'] as double;

    String status;
    String recommendation;

    // Check weight
    if (weight < minWeight) {
      status = 'Thiếu cân';
      recommendation = '• Tăng khẩu phần ăn\n'
          '• Bổ sung thức ăn giàu dinh dưỡng\n'
          '• Kiểm tra sức khỏe với bác sĩ thú y\n'
          '• Cho ăn nhiều bữa trong ngày';
    } else if (weight > maxWeight) {
      status = 'Thừa cân';
      recommendation = '• Giảm khẩu phần ăn\n'
          '• Tăng cường vận động\n'
          '• Hạn chế đồ ăn vặt\n'
          '• Tham khảo chế độ ăn kiêng với bác sĩ';
    } else if (height < minHeight || height > maxHeight) {
      status = 'Chiều cao bất thường';
      recommendation = '• Kiểm tra sức khỏe tổng quát\n'
          '• Bổ sung canxi và vitamin D\n'
          '• Đảm bảo dinh dưỡng cân đối\n'
          '• Theo dõi sự phát triển định kỳ';
    } else {
      status = 'Khỏe mạnh';
      recommendation = '• Duy trì chế độ ăn hiện tại\n'
          '• Tập thể dục đều đặn\n'
          '• Khám sức khỏe định kỳ 6 tháng/lần\n'
          '• Tiêm phòng đầy đủ';
    }

    setState(() {
      _healthStatus = status;
      _recommendation = recommendation;
    });
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
                  colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
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

            // Pet Type Selection
            Text(
              'Loại thú cưng',
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTypeChip('Chó', Icons.pets),
                const SizedBox(width: 12),
                _buildTypeChip('Mèo', Icons.pets),
                const SizedBox(width: 12),
                _buildTypeChip('Chim', Icons.flutter_dash),
              ],
            ),
            const SizedBox(height: 20),

            // Age Selection
            Text(
              'Độ tuổi',
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAgeChip('Con'),
                const SizedBox(width: 12),
                _buildAgeChip('Trưởng thành'),
                const SizedBox(width: 12),
                _buildAgeChip('Già'),
              ],
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
                prefixIcon: const Icon(Icons.height, color: Color(0xFFFFB74D)),
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
                prefixIcon: const Icon(Icons.monitor_weight, color: Color(0xFFFFB74D)),
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
                onPressed: _checkHealth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
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
                    Text(
                      'Khuyến nghị:',
                      style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recommendation!,
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
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

  Widget _buildTypeChip(String type, IconData icon) {
    final isSelected = _selectedPetType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPetType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFB74D) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: GoogleFonts.afacad(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeChip(String age) {
    final isSelected = _selectedAge == age;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedAge = age),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8E97FD) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            age,
            textAlign: TextAlign.center,
            style: GoogleFonts.afacad(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
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
        return const Color(0xFFFFB74D);
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

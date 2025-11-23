// lib/widget/health_analysis_form.dart - Google Form Style Health Analysis
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthAnalysisForm extends StatefulWidget {
  final String petName;
  final String petBreed;
  final double petWeight;
  final double idealWeight;
  final String petAge;
  final int medicalHistoryCount;
  final int allergyCount;
  final List<Map<String, dynamic>> availablePets;
  final Function(String petId) onPetSelected;
  final Function({
    required double weight,
    required double idealWeight,
    required String skinCondition,
    required String coatCondition,
    required bool teethHealthy,
    required bool isActive,
    required String dietQuality,
    required String exerciseFrequency,
    required String lastVaccineDate,
    required String notes,
  }) onAnalyze;

  const HealthAnalysisForm({
    super.key,
    required this.petName,
    required this.petBreed,
    required this.petWeight,
    required this.idealWeight,
    required this.petAge,
    required this.medicalHistoryCount,
    required this.allergyCount,
    required this.availablePets,
    required this.onPetSelected,
    required this.onAnalyze,
  });

  @override
  State<HealthAnalysisForm> createState() => _HealthAnalysisFormState();
}

class _HealthAnalysisFormState extends State<HealthAnalysisForm> {
  late TextEditingController _weightController;
  late TextEditingController _idealWeightController;
  late TextEditingController _lastVaccineDateController;
  late TextEditingController _notesController;

  String _skinCondition = 'good';
  String _coatCondition = 'good';
  bool _teethHealthy = true;
  bool _isActive = true;
  String _dietQuality = 'balanced';
  String _exerciseFrequency = 'daily';

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.petWeight.toString());
    _idealWeightController = TextEditingController(text: widget.idealWeight.toString());
    _lastVaccineDateController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _idealWeightController.dispose();
    _lastVaccineDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _lastVaccineDateController.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Title
            Text(
              'Phân tích sức khỏe ${widget.petName}',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vui lòng điền đầy đủ thông tin để AI phân tích sức khỏe của thú cưng',
              style: GoogleFonts.afacad(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Pet Info Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, color: Color(0xFF8B5CF6), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.petName,
                          style: GoogleFonts.afacad(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${widget.petBreed} - ${widget.petAge}',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pet Selection from Firebase
            if (widget.availablePets.isNotEmpty)
              _buildPetSelector(),

            const SizedBox(height: 24),

            // Weight Section
            _buildFormSection(
              title: 'Cân nặng',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Cân nặng hiện tại (kg)',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Cân nặng lý tưởng (kg)',
                        controller: _idealWeightController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildWeightStatus(),
              ],
            ),

            const SizedBox(height: 20),

            // Skin & Coat Section
            _buildFormSection(
              title: 'Da và lông',
              children: [
                _buildDropdown(
                  label: 'Tình trạng da',
                  value: _skinCondition,
                  items: const ['excellent', 'good', 'fair', 'poor'],
                  labels: const ['Tuyệt vời', 'Tốt', 'Bình thường', 'Kém'],
                  onChanged: (val) => setState(() => _skinCondition = val),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'Tình trạng lông',
                  value: _coatCondition,
                  items: const ['excellent', 'good', 'fair', 'poor'],
                  labels: const ['Tuyệt vời', 'Tốt', 'Bình thường', 'Kém'],
                  onChanged: (val) => setState(() => _coatCondition = val),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Teeth & Activity Section
            _buildFormSection(
              title: 'Sức khỏe và hoạt động',
              children: [
                _buildCheckbox(
                  label: 'Răng khỏe mạnh',
                  value: _teethHealthy,
                  onChanged: (val) => setState(() => _teethHealthy = val ?? true),
                ),
                const SizedBox(height: 12),
                _buildCheckbox(
                  label: 'Hoạt động năng động',
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val ?? true),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Diet & Exercise Section
            _buildFormSection(
              title: 'Chế độ ăn và tập luyện',
              children: [
                _buildDropdown(
                  label: 'Chất lượng chế độ ăn',
                  value: _dietQuality,
                  items: const ['premium', 'balanced', 'basic', 'poor'],
                  labels: const ['Cao cấp', 'Cân bằng', 'Cơ bản', 'Kém'],
                  onChanged: (val) => setState(() => _dietQuality = val),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'Tần suất tập luyện',
                  value: _exerciseFrequency,
                  items: const ['high', 'daily', 'moderate', 'low'],
                  labels: const ['Cao (>2h/ngày)', 'Hàng ngày (1-2h)', 'Vừa phải (30-60p)', 'Thấp (<30p)'],
                  onChanged: (val) => setState(() => _exerciseFrequency = val),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Vaccination & Notes Section
            _buildFormSection(
              title: 'Lịch sử và ghi chú',
              children: [
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _lastVaccineDateController.text.isEmpty
                                ? 'Ngày tiêm chủng gần nhất'
                                : _lastVaccineDateController.text,
                            style: GoogleFonts.afacad(
                              fontSize: 13,
                              color: _lastVaccineDateController.text.isEmpty
                                  ? Colors.grey[500]
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Ghi chú thêm (tùy chọn)',
                  controller: _notesController,
                  maxLines: 3,
                  hint: 'Ví dụ: Vừa điều trị xong, đã phẫu thuật, v.v...',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.smart_toy, color: Colors.white),
                label: Text(
                  'Phân tích sức khỏe bằng AI',
                  style: GoogleFonts.afacad(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.afacad(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.afacad(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: GoogleFonts.afacad(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required List<String> labels,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox.shrink(),
            value: value,
            items: List.generate(items.length, (index) {
              return DropdownMenuItem<String>(
                value: items[index],
                child: Text(
                  labels[index],
                  style: GoogleFonts.afacad(fontSize: 13),
                ),
              );
            }),
            onChanged: (val) => onChanged(val ?? value),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF8B5CF6),
          ),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.afacad(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn thú cưng khác để phân tích',
          style: GoogleFonts.afacad(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.availablePets.map<Widget>((pet) {
              return GestureDetector(
                onTap: () => widget.onPetSelected(pet['id']),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF8B5CF6),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF8B5CF6).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pets,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pet['name'] ?? 'Unknown',
                            style: GoogleFonts.afacad(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet['breed'] ?? 'Unknown',
                        style: GoogleFonts.afacad(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightStatus() {
    try {
      final current = double.parse(_weightController.text);
      final ideal = double.parse(_idealWeightController.text);
      final difference = current - ideal;
      final percentDiff = ((difference / ideal) * 100).abs();

      String status;
      Color statusColor;

      if (percentDiff < 5) {
        status = 'Cân nặng lý tưởng ✓';
        statusColor = Colors.green;
      } else if (difference > 0) {
        status = 'Hơi béo (${percentDiff.toStringAsFixed(1)}%)';
        statusColor = Colors.orange;
      } else {
        status = 'Hơi gầy (${percentDiff.toStringAsFixed(1)}%)';
        statusColor = Colors.blue;
      }

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Text(
          status,
          style: GoogleFonts.afacad(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  void _submitForm() {
    try {
      final weight = double.parse(_weightController.text);
      final idealWeight = double.parse(_idealWeightController.text);

      widget.onAnalyze(
        weight: weight,
        idealWeight: idealWeight,
        skinCondition: _skinCondition,
        coatCondition: _coatCondition,
        teethHealthy: _teethHealthy,
        isActive: _isActive,
        dietQuality: _dietQuality,
        exerciseFrequency: _exerciseFrequency,
        lastVaccineDate: _lastVaccineDateController.text,
        notes: _notesController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng kiểm tra lại dữ liệu', style: GoogleFonts.afacad()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

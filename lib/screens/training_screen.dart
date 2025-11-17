// lib/screens/training_screen.dart - Medical History & Record Management
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int selectedTab = 0; // 0: Bệnh lý, 1: Dị ứng, 2: Thuốc, 3: Tệp đính kèm

  final List<String> tabs = ['Bệnh lý', 'Dị ứng', 'Thuốc', 'Tệp đính kèm'];

  // Medical History Data
  List<Map<String, dynamic>> medicalHistories = [
    {
      'id': '1',
      'condition': 'Bệnh ngoài da',
      'date': '15/09/2025',
      'doctor': 'BS. Nguyễn Văn A',
      'description': 'Viêm da hình thành do nấm',
      'notes': 'Dùng kem chống nấm 2 lần/ngày',
      'status': 'Đang điều trị',
    },
    {
      'id': '2',
      'condition': 'Nhiễm giun ruột',
      'date': '10/08/2025',
      'doctor': 'BS. Trần Thị B',
      'description': 'Phát hiện qua xét nghiệm',
      'notes': 'Sử dụng thuốc tẩy giun hàng 3 tháng',
      'status': 'Đã điều trị',
    },
  ];

  // Allergies Data
  List<Map<String, dynamic>> allergies = [
    {
      'id': '1',
      'allergen': 'Phấn hoa',
      'severity': 'Nhẹ',
      'symptoms': 'Hắt hơi, ngứa mắt',
      'reactions': 'Kích ứng da, viêm mắt',
      'date': '01/08/2025',
    },
    {
      'id': '2',
      'allergen': 'Thức ăn (Cá)',
      'severity': 'Trung bình',
      'symptoms': 'Ngứa, nôn',
      'reactions': 'Các lỗ chân lông phồng to',
      'date': '20/07/2025',
    },
  ];

  // Medications Data
  List<Map<String, dynamic>> medications = [
    {
      'id': '1',
      'name': 'Kem chống nấm Malaseb',
      'dosage': '1 lần/ngày',
      'frequency': 'Hàng ngày',
      'startDate': '15/09/2025',
      'endDate': '15/10/2025',
      'reason': 'Điều trị viêm da',
      'prescribedBy': 'BS. Nguyễn Văn A',
    },
    {
      'id': '2',
      'name': 'Vitamin A, D, E',
      'dosage': '1 viên/ngày',
      'frequency': 'Hàng ngày',
      'startDate': '01/09/2025',
      'endDate': null,
      'reason': 'Bổ sung dinh dưỡng',
      'prescribedBy': 'BS. Trần Thị B',
    },
  ];

  // Medical Files Data
  List<Map<String, dynamic>> medicalFiles = [
    {
      'id': '1',
      'name': 'Hóa đơn khám ngày 15/09/2025',
      'type': 'Hóa đơn khám',
      'date': '15/09/2025',
      'fileSize': '2.4 MB',
      'uploadDate': '15/09/2025',
    },
    {
      'id': '2',
      'name': 'Kết quả xét nghiệm máu',
      'type': 'Xét nghiệm',
      'date': '10/08/2025',
      'fileSize': '1.8 MB',
      'uploadDate': '10/08/2025',
    },
    {
      'id': '3',
      'name': 'Giấy tiêm chủng 2025',
      'type': 'Giấy tiêm chủng',
      'date': '20/06/2025',
      'fileSize': '0.9 MB',
      'uploadDate': '20/06/2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hồ sơ y tế',
          style: GoogleFonts.afacad(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedTab == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF8B5CF6)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: GoogleFonts.afacad(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8),

            // Content based on selected tab
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    children: [
                      if (selectedTab == 0) _buildMedicalHistory(),
                      if (selectedTab == 1) _buildAllergies(),
                      if (selectedTab == 2) _buildMedications(),
                      if (selectedTab == 3) _buildMedicalFiles(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== BỆNH LÝ (Medical History) =====
  Widget _buildMedicalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử bệnh lý',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _addMedicalHistory,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (medicalHistories.isEmpty)
          _buildEmptyState('Chưa có bệnh lý ghi nhận')
        else
          ...medicalHistories.map((history) => _buildMedicalHistoryCard(history)),
      ],
    );
  }

  Widget _buildMedicalHistoryCard(Map<String, dynamic> history) {
    final statusColor = history['status'] == 'Đang điều trị'
        ? Color(0xFFFF9800)
        : Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () => _showMedicalHistoryDetail(history),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history['condition'],
                        style: GoogleFonts.afacad(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        history['date'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    history['status'],
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  history['doctor'],
                  style: GoogleFonts.afacad(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              history['description'],
              style: GoogleFonts.afacad(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ===== DỊ ỨNG (Allergies) =====
  Widget _buildAllergies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dị ứng của thú cưng',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _addAllergy,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (allergies.isEmpty)
          _buildEmptyState('Chưa ghi nhận dị ứng nào')
        else
          ...allergies.map((allergy) => _buildAllergyCard(allergy)),
      ],
    );
  }

  Widget _buildAllergyCard(Map<String, dynamic> allergy) {
    final severityColor = allergy['severity'] == 'Nhẹ'
        ? Color(0xFF4CAF50)
        : allergy['severity'] == 'Trung bình'
            ? Color(0xFFFF9800)
            : Color(0xFFF44336);

    return GestureDetector(
      onTap: () => _showAllergyDetail(allergy),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allergy['allergen'],
                        style: GoogleFonts.afacad(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        allergy['date'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    allergy['severity'],
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Triệu chứng: ${allergy['symptoms']}',
              style: GoogleFonts.afacad(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Phản ứng: ${allergy['reactions']}',
              style: GoogleFonts.afacad(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== THUỐC (Medications) =====
  Widget _buildMedications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thuốc đang sử dụng',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _addMedication,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (medications.isEmpty)
          _buildEmptyState('Chưa ghi nhận thuốc nào')
        else
          ...medications.map((med) => _buildMedicationCard(med)),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> med) {
    // Convert date format from DD/MM/YYYY to DateTime for comparison
    DateTime? endDate;
    if (med['endDate'] != null) {
      try {
        // Try parsing as YYYY-MM-DD first
        endDate = DateTime.parse(med['endDate'].toString());
      } catch (e) {
        // If fails, it might be DD/MM/YYYY format
        endDate = null;
      }
    }

    final isActive = endDate == null || endDate.isAfter(DateTime.now());

    return GestureDetector(
      onTap: () => _showMedicationDetail(med),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med['name'],
                        style: GoogleFonts.afacad(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        med['dosage'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Color(0xFF4CAF50).withOpacity(0.2)
                        : Color(0xFFBDBDBD).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? 'Đang dùng' : 'Đã kết thúc',
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Color(0xFF4CAF50) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tần suất',
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      med['frequency'],
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lý do',
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      med['reason'],
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  med['prescribedBy'],
                  style: GoogleFonts.afacad(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== TỆP ĐÍNH KÈM (Medical Files) =====
  Widget _buildMedicalFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tệp y tế',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _uploadMedicalFile,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.upload_file, color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (medicalFiles.isEmpty)
          _buildEmptyState('Chưa có tệp y tế nào')
        else
          ...medicalFiles.map((file) => _buildMedicalFileCard(file)),
      ],
    );
  }

  Widget _buildMedicalFileCard(Map<String, dynamic> file) {
    final fileIcon = file['type'].contains('Hóa đơn')
        ? Icons.receipt
        : file['type'].contains('Xét nghiệm')
            ? Icons.assignment
            : Icons.card_travel;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF8B5CF6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              fileIcon,
              color: Color(0xFF8B5CF6),
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'],
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      file['type'],
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '•',
                      style: GoogleFonts.afacad(color: Colors.grey[600]),
                    ),
                    SizedBox(width: 8),
                    Text(
                      file['fileSize'],
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Tải lên: ${file['uploadDate']}',
                  style: GoogleFonts.afacad(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.download, color: Color(0xFF8B5CF6), size: 20),
        ],
      ),
    );
  }

  // ===== HELPER WIDGETS =====
  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.afacad(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== ACTION DIALOGS =====
  void _addMedicalHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thêm bệnh lý mới', style: GoogleFonts.afacad()),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  void _addAllergy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thêm dị ứng mới', style: GoogleFonts.afacad()),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  void _addMedication() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thêm thuốc mới', style: GoogleFonts.afacad()),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  void _uploadMedicalFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tải lên tệp y tế', style: GoogleFonts.afacad()),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  void _showMedicalHistoryDetail(Map<String, dynamic> history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history['condition'],
                  style: GoogleFonts.afacad(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow('Ngày khám', history['date']),
                _buildDetailRow('Bác sĩ', history['doctor']),
                _buildDetailRow('Mô tả', history['description']),
                _buildDetailRow('Ghi chú', history['notes']),
                _buildDetailRow('Trạng thái', history['status']),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllergyDetail(Map<String, dynamic> allergy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allergy['allergen'],
                  style: GoogleFonts.afacad(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow('Mức độ', allergy['severity']),
                _buildDetailRow('Triệu chứng', allergy['symptoms']),
                _buildDetailRow('Phản ứng', allergy['reactions']),
                _buildDetailRow('Ngày phát hiện', allergy['date']),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMedicationDetail(Map<String, dynamic> med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'],
                  style: GoogleFonts.afacad(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow('Liều lượng', med['dosage']),
                _buildDetailRow('Tần suất', med['frequency']),
                _buildDetailRow('Lý do', med['reason']),
                _buildDetailRow('Bắt đầu', med['startDate']),
                if (med['endDate'] != null)
                  _buildDetailRow('Kết thúc', med['endDate']),
                _buildDetailRow('Được kê đơn bởi', med['prescribedBy']),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.afacad(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

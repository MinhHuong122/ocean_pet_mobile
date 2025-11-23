// lib/screens/training_screen.dart - Medical History & Record Management
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/health_score_service.dart';
import '../services/medical_record_service.dart';
import '../widget/health_analysis_form.dart';
import '../widget/ai_disease_detector.dart';
import '../widget/medical_record_detail_modal.dart';
import '../widget/medical_record_form.dart';
import '../widget/medical_file_picker.dart';

class TrainingScreen extends StatefulWidget {
  final String? initialPetId;

  const TrainingScreen({
    super.key,
    this.initialPetId,
  });

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int selectedTab = 0; // 0: Sức khỏe, 1: Bệnh lý, 2: Dị ứng, 3: Thuốc, 4: Tệp đính kèm, 5: Phân tích tài liệu

  final List<String> tabs = ['Sức khỏe', 'Bệnh lý', 'Dị ứng', 'Thuốc', 'Tệp đính kèm', 'Phân Tích'];

  // Pet selection
  String? selectedPetId;
  List<Map<String, dynamic>> availablePets = [];
  
  String petName = 'Buddy';
  String petBreed = 'Poodle';
  double petWeight = 8.5;
  double idealWeight = 9.0;
  String petAge = '3 tuổi';
  String ownerName = 'Nguyễn Văn A';
  String ownerPhone = '+84912345678';
  String petId = 'pet_001';

  // Medical History Data
  List<Map<String, dynamic>> medicalHistories = [];
  List<Map<String, dynamic>> allergies = [];
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> medicalFiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialPetId != null) {
      selectedPetId = widget.initialPetId;
    }
    _loadAvailablePets();
    _loadMedicalData();
  }

  // Load available pets from Firebase (filtered by current user)
  Future<void> _loadAvailablePets() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final petsSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      setState(() {
        availablePets = petsSnapshot.docs
            .map((doc) => {
              'id': doc.id,
              'name': doc['name'] ?? 'Unknown Pet',
              'breed': doc['breed'] ?? 'Unknown',
              'age': _formatAge(doc['age']),
            })
            .toList();
        
        if (availablePets.isNotEmpty && selectedPetId == null) {
          selectedPetId = availablePets[0]['id'];
          _updateSelectedPet();
        }
      });
    } catch (e) {
      print('Error loading pets: $e');
    }
  }

  // Update selected pet info
  void _updateSelectedPet() {
    if (selectedPetId == null) return;
    
    final pet = availablePets.firstWhere(
      (p) => p['id'] == selectedPetId,
      orElse: () => {},
    );
    
    if (pet.isNotEmpty) {
      setState(() {
        petName = pet['name'] ?? 'Unknown';
        petBreed = pet['breed'] ?? 'Unknown';
        petAge = pet['age'] ?? 'Unknown';
        petId = selectedPetId ?? '';
      });
      _loadMedicalData();
    }
  }

  // Format age from months to years/months
  String _formatAge(dynamic age) {
    if (age is! int) {
      return (age ?? 'Unknown').toString();
    }
    
    if (age < 12) {
      return '$age tháng';
    } else {
      int years = age ~/ 12;
      int months = age % 12;
      if (months == 0) {
        return '$years năm';
      } else {
        return '$years năm $months tháng';
      }
    }
  }

  // Load medical data from Firebase for selected pet
  Future<void> _loadMedicalData() async {
    if (selectedPetId == null) return;
    
    try {
      final recordSnapshot = await MedicalRecordService.getMedicalRecord(selectedPetId!);
      
      if (recordSnapshot != null) {
        setState(() {
          // Load consultations (medical history)
          medicalHistories = recordSnapshot.consultations
              .map((c) => {
                'id': c.id,
                'condition': c.diagnosis ?? 'Unknown',
                'date': c.consultationDate.toString().split(' ')[0],
                'doctor': c.vetName,
                'description': c.symptoms ?? '',
                'notes': c.treatment ?? '',
                'status': c.isDischarged ? 'Đã điều trị' : 'Đang điều trị',
              })
              .toList();

          // Load other data when model is extended
          allergies = [];
          medications = [];
          
          // Load files (medical files)
          medicalFiles = [];
        });
      }
    } catch (e) {
      print('Error loading medical data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF22223B)),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          'Hồ sơ y tế',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
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

            // Content based on selected tab
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    children: [
                      if (selectedTab == 0) _buildHealthScoreTab(),
                      if (selectedTab == 1) _buildMedicalHistory(),
                      if (selectedTab == 2) _buildAllergies(),
                      if (selectedTab == 3) _buildMedications(),
                      if (selectedTab == 4) _buildMedicalFiles(),
                      if (selectedTab == 5) _buildAIScanTab(),
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

  // ===== HEALTH SCORE TAB =====
  Widget _buildHealthScoreTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Pet Selector for Health Tab
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân tích sức khỏe $petName',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng điền đầy đủ thông tin để AI phân tích sức khỏe của thú cưng',
                  style: GoogleFonts.afacad(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                // Pet Selection Card (Tap to change)
                if (availablePets.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Show pet selection dialog
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Chọn thú cưng để phân tích',
                                  style: GoogleFonts.afacad(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: availablePets.length,
                                  itemBuilder: (context, index) {
                                    final pet = availablePets[index];
                                    final isSelected = pet['id'] == selectedPetId;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedPetId = pet['id'];
                                        });
                                        _updateSelectedPet();
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
                                            width: isSelected ? 2 : 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          color: isSelected ? const Color(0xFF8B5CF6).withValues(alpha: 0.1) : Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.pets,
                                              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[500],
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    pet['name'] ?? 'Unknown',
                                                    style: GoogleFonts.afacad(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${pet['breed'] ?? 'Unknown'} - ${pet['age'] ?? 'Unknown'}',
                                                    style: GoogleFonts.afacad(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: const Color(0xFF8B5CF6),
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF8B5CF6),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Color(0xFF8B5CF6),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  petName,
                                  style: GoogleFonts.afacad(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$petBreed - $petAge',
                                  style: GoogleFonts.afacad(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Health Analysis Form (Google Form Style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: HealthAnalysisForm(
              petName: petName,
              petBreed: petBreed,
              petWeight: petWeight,
              idealWeight: idealWeight,
              petAge: petAge,
              medicalHistoryCount: medicalHistories.length,
              allergyCount: allergies.length,
              availablePets: availablePets,
              onPetSelected: _onPetSelectedForHealth,
              onAnalyze: _analyzeHealthWithAI,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // AI Health Analysis
  void _onPetSelectedForHealth(String petId) {
    setState(() {
      selectedPetId = petId;
    });
    _updateSelectedPet();
    // Form will rebuild with new pet data
  }

  Future<void> _analyzeHealthWithAI({
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
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Đang phân tích sức khỏe...', style: GoogleFonts.afacad()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            const SizedBox(height: 16),
            Text(
              'AI đang phân tích dữ liệu sức khỏe của ${petName}',
              style: GoogleFonts.afacad(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 2));

    final healthScore = HealthScoreService.calculateHealthScore(
      weight: weight,
      idealWeight: idealWeight,
      vaccinationCount: medicalHistories.length,
      teethHealthy: teethHealthy,
      skinCondition: skinCondition,
      coatCondition: coatCondition,
      medicalHistoryCount: medicalHistories.length,
      allergyCount: allergies.length,
      isActive: isActive,
    );

    final recommendations = HealthScoreService.getRecommendations(
      weight: weight,
      idealWeight: idealWeight,
      vaccinationCount: medicalHistories.length,
      teethHealthy: teethHealthy,
      skinCondition: skinCondition,
      coatCondition: coatCondition,
      medicalHistoryCount: medicalHistories.length,
      allergyCount: allergies.length,
      isActive: isActive,
    );

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kết quả phân tích sức khỏe', style: GoogleFonts.afacad()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF8B5CF6)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Điểm sức khỏe',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$healthScore',
                          style: GoogleFonts.afacad(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        Text(
                          '/100',
                          style: GoogleFonts.afacad(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lời khuyên từ AI:',
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}. ',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.afacad(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: GoogleFonts.afacad(color: Color(0xFF8B5CF6))),
          ),
        ],
      ),
    );
  }

  // ===== AI SCAN TAB =====
  Widget _buildAIScanTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phân Tích Tài Liệu Y Tế',
                style: GoogleFonts.afacad(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tải ảnh tài liệu và nhận giải thích cùng lời khuyên chăm sóc',
                style: GoogleFonts.afacad(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // AI Disease Detector
        Container(
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
          child: AIDiseaseDetector(),
        ),
      ],
    );
  }

  // ===== MEDICAL HISTORY =====
  Widget _buildMedicalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with higher padding
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch sử bệnh lý',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lịch sử khám bệnh và điều trị',
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _addMedicalHistory,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add, color: Color(0xFF8B5CF6), size: 20),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
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

  // ===== ALLERGIES =====
  Widget _buildAllergies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with higher padding
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dị ứng',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dị ứng của ${petName}',
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _addAllergy,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add, color: Color(0xFF8B5CF6), size: 20),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
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

  // ===== MEDICATIONS =====
  Widget _buildMedications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with higher padding
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thuốc',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thuốc đang sử dụng',
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _addMedication,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add, color: Color(0xFF8B5CF6), size: 20),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        if (medications.isEmpty)
          _buildEmptyState('Chưa ghi nhận thuốc nào')
        else
          ...medications.map((med) => _buildMedicationCard(med)),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> med) {
    DateTime? endDate;
    if (med['endDate'] != null) {
      try {
        endDate = DateTime.parse(med['endDate'].toString());
      } catch (e) {
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

  // ===== MEDICAL FILES =====
  Widget _buildMedicalFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with higher padding
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tệp y tế',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tệp đính kèm và hồ sơ',
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _uploadMedicalFile,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.upload_file, color: Color(0xFF8B5CF6), size: 20),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
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
          GestureDetector(
            onTap: () => _downloadFile(file),
            child: Icon(Icons.download, color: Color(0xFF8B5CF6), size: 20),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteFile(file['id']),
            child: Icon(Icons.delete, color: Colors.red[400], size: 20),
          ),
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

  // ===== ACTION METHODS =====
  void _addMedicalHistory() {
    _showMedicalHistoryForm();
  }

  void _addAllergy() {
    _showAllergyForm();
  }

  void _addMedication() {
    _showMedicationForm();
  }

  void _uploadMedicalFile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicalFilePicker(
        onFilesSelected: (files) {
          // Files have been selected
        },
        onUploadComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tệp đã được tải lên thành công',
                style: GoogleFonts.afacad(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          _loadMedicalData();
        },
      ),
    );
  }

  void _downloadFile(Map<String, dynamic> file) {
    // TODO: Implement file download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tải xuống: ${file['name']}', style: GoogleFonts.afacad()),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteFile(String fileId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa tệp', style: GoogleFonts.afacad()),
        content: Text('Bạn có chắc muốn xóa tệp này?', style: GoogleFonts.afacad()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad()),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                medicalFiles.removeWhere((f) => f['id'] == fileId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Xóa tệp thành công!', style: GoogleFonts.afacad()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Xóa', style: GoogleFonts.afacad(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ===== FORM DIALOGS =====
  void _showMedicalHistoryForm({Map<String, dynamic>? history}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: MedicalRecordForm(
            title: history != null ? 'Chỉnh sửa bệnh lý' : 'Thêm bệnh lý mới',
            submitButtonText: history != null ? 'Cập nhật' : 'Thêm',
            includePetSelection: true,
            initialPetId: selectedPetId,
            fields: [
              MedicalFormField(
                name: 'condition',
                label: 'Tên bệnh lý',
                type: FormFieldType.text,
                hint: 'Ví dụ: Viêm da',
                initialValue: history?['condition'],
                required: true,
              ),
              MedicalFormField(
                name: 'date',
                label: 'Ngày khám',
                type: FormFieldType.date,
                initialValue: history?['date'],
                required: true,
              ),
              MedicalFormField(
                name: 'doctor',
                label: 'Bác sĩ khám',
                type: FormFieldType.text,
                hint: 'Ví dụ: BS. Nguyễn Văn A',
                initialValue: history?['doctor'],
                required: true,
              ),
              MedicalFormField(
                name: 'description',
                label: 'Mô tả chi tiết',
                type: FormFieldType.textarea,
                hint: 'Mô tả tình trạng và chẩn đoán',
                initialValue: history?['description'],
                required: false,
                maxLines: 3,
              ),
              MedicalFormField(
                name: 'notes',
                label: 'Ghi chú',
                type: FormFieldType.textarea,
                hint: 'Ghi chú thêm về điều trị',
                initialValue: history?['notes'],
                required: false,
                maxLines: 3,
              ),
              MedicalFormField(
                name: 'status',
                label: 'Trạng thái',
                type: FormFieldType.dropdown,
                initialValue: history?['status'] ?? 'Đang điều trị',
                options: ['Đang điều trị', 'Đã điều trị', 'Theo dõi'],
                required: true,
              ),
            ],
            onFormData: (data) {
              setState(() {
                if (history != null) {
                  final index = medicalHistories.indexWhere((h) => h['id'] == history['id']);
                  if (index >= 0) {
                    medicalHistories[index].addAll(data);
                  }
                } else {
                  data['id'] = DateTime.now().toString();
                  medicalHistories.add(data);
                }
              });
            },
            onSubmit: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    history != null ? 'Cập nhật bệnh lý thành công!' : 'Thêm bệnh lý mới thành công!',
                    style: GoogleFonts.afacad(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAllergyForm({Map<String, dynamic>? allergy}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: MedicalRecordForm(
            title: allergy != null ? 'Chỉnh sửa dị ứng' : 'Thêm dị ứng mới',
            submitButtonText: allergy != null ? 'Cập nhật' : 'Thêm',
            includePetSelection: true,
            initialPetId: selectedPetId,
            fields: [
              MedicalFormField(
                name: 'allergen',
                label: 'Chất gây dị ứng',
                type: FormFieldType.text,
                hint: 'Ví dụ: Phấn hoa',
                initialValue: allergy?['allergen'],
                required: true,
              ),
              MedicalFormField(
                name: 'severity',
                label: 'Mức độ',
                type: FormFieldType.dropdown,
                initialValue: allergy?['severity'] ?? 'Nhẹ',
                options: ['Nhẹ', 'Trung bình', 'Nặng'],
                required: true,
              ),
              MedicalFormField(
                name: 'symptoms',
                label: 'Triệu chứng',
                type: FormFieldType.textarea,
                hint: 'Mô tả triệu chứng khi tiếp xúc',
                initialValue: allergy?['symptoms'],
                required: false,
                maxLines: 2,
              ),
              MedicalFormField(
                name: 'reactions',
                label: 'Phản ứng',
                type: FormFieldType.textarea,
                hint: 'Mô tả phản ứng của thú cưng',
                initialValue: allergy?['reactions'],
                required: false,
                maxLines: 2,
              ),
              MedicalFormField(
                name: 'date',
                label: 'Ngày phát hiện',
                type: FormFieldType.date,
                initialValue: allergy?['date'],
                required: true,
              ),
            ],
            onFormData: (data) {
              setState(() {
                if (allergy != null) {
                  final index = allergies.indexWhere((a) => a['id'] == allergy['id']);
                  if (index >= 0) {
                    allergies[index].addAll(data);
                  }
                } else {
                  data['id'] = DateTime.now().toString();
                  allergies.add(data);
                }
              });
            },
            onSubmit: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    allergy != null ? 'Cập nhật dị ứng thành công!' : 'Thêm dị ứng mới thành công!',
                    style: GoogleFonts.afacad(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMedicationForm({Map<String, dynamic>? medication}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: MedicalRecordForm(
            title: medication != null ? 'Chỉnh sửa thuốc' : 'Thêm thuốc mới',
            submitButtonText: medication != null ? 'Cập nhật' : 'Thêm',
            includePetSelection: true,
            initialPetId: selectedPetId,
            fields: [
              MedicalFormField(
                name: 'name',
                label: 'Tên thuốc',
                type: FormFieldType.text,
                hint: 'Ví dụ: Kem chống nấm Malaseb',
                initialValue: medication?['name'],
                required: true,
              ),
              MedicalFormField(
                name: 'dosage',
                label: 'Liều lượng',
                type: FormFieldType.text,
                hint: 'Ví dụ: 1 lần/ngày',
                initialValue: medication?['dosage'],
                required: true,
              ),
              MedicalFormField(
                name: 'frequency',
                label: 'Tần suất',
                type: FormFieldType.dropdown,
                initialValue: medication?['frequency'] ?? 'Hàng ngày',
                options: ['Hàng ngày', 'Hàng tuần', 'Hàng tháng', 'Khi cần'],
                required: true,
              ),
              MedicalFormField(
                name: 'reason',
                label: 'Lý do sử dụng',
                type: FormFieldType.text,
                hint: 'Ví dụ: Điều trị viêm da',
                initialValue: medication?['reason'],
                required: true,
              ),
              MedicalFormField(
                name: 'startDate',
                label: 'Ngày bắt đầu',
                type: FormFieldType.date,
                initialValue: medication?['startDate'],
                required: true,
              ),
              MedicalFormField(
                name: 'endDate',
                label: 'Ngày kết thúc (tùy chọn)',
                type: FormFieldType.date,
                initialValue: medication?['endDate'],
                required: false,
              ),
              MedicalFormField(
                name: 'prescribedBy',
                label: 'Được kê đơn bởi',
                type: FormFieldType.text,
                hint: 'Ví dụ: BS. Nguyễn Văn A',
                initialValue: medication?['prescribedBy'],
                required: true,
              ),
            ],
            onFormData: (data) {
              setState(() {
                if (medication != null) {
                  final index = medications.indexWhere((m) => m['id'] == medication['id']);
                  if (index >= 0) {
                    medications[index].addAll(data);
                  }
                } else {
                  data['id'] = DateTime.now().toString();
                  medications.add(data);
                }
              });
            },
            onSubmit: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    medication != null ? 'Cập nhật thuốc thành công!' : 'Thêm thuốc mới thành công!',
                    style: GoogleFonts.afacad(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMedicalHistoryDetail(Map<String, dynamic> history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicalRecordDetailModal(
        title: history['condition'],
        data: history,
        onEdit: () {
          Navigator.pop(context);
          _showMedicalHistoryForm(history: history);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteMedicalHistory(history['id']);
        },
        fields: [
          DetailField(label: 'Ngày khám', value: history['date']),
          DetailField(label: 'Bác sĩ', value: history['doctor']),
          DetailField(label: 'Mô tả', value: history['description']),
          DetailField(label: 'Ghi chú', value: history['notes']),
          DetailField(label: 'Trạng thái', value: history['status']),
        ],
      ),
    );
  }

  void _showAllergyDetail(Map<String, dynamic> allergy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicalRecordDetailModal(
        title: allergy['allergen'],
        data: allergy,
        onEdit: () {
          Navigator.pop(context);
          _showAllergyForm(allergy: allergy);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteAllergy(allergy['id']);
        },
        fields: [
          DetailField(label: 'Mức độ', value: allergy['severity']),
          DetailField(label: 'Triệu chứng', value: allergy['symptoms']),
          DetailField(label: 'Phản ứng', value: allergy['reactions']),
          DetailField(label: 'Ngày phát hiện', value: allergy['date']),
        ],
      ),
    );
  }

  void _showMedicationDetail(Map<String, dynamic> med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicalRecordDetailModal(
        title: med['name'],
        data: med,
        onEdit: () {
          Navigator.pop(context);
          _showMedicationForm(medication: med);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteMedication(med['id']);
        },
        fields: [
          DetailField(label: 'Liều lượng', value: med['dosage']),
          DetailField(label: 'Tần suất', value: med['frequency']),
          DetailField(label: 'Lý do', value: med['reason']),
          DetailField(label: 'Bắt đầu', value: med['startDate']),
          if (med['endDate'] != null)
            DetailField(label: 'Kết thúc', value: med['endDate']),
          DetailField(label: 'Được kê đơn bởi', value: med['prescribedBy']),
        ],
      ),
    );
  }

  void _deleteMedicalHistory(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa', style: GoogleFonts.afacad()),
        content: Text('Bạn có chắc muốn xóa bệnh lý này?', style: GoogleFonts.afacad()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Color(0xFF8B5CF6))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                medicalHistories.removeWhere((h) => h['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Xóa bệnh lý thành công!', style: GoogleFonts.afacad()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Xóa', style: GoogleFonts.afacad(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteAllergy(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa', style: GoogleFonts.afacad()),
        content: Text('Bạn có chắc muốn xóa dị ứng này?', style: GoogleFonts.afacad()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Color(0xFF8B5CF6))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                allergies.removeWhere((a) => a['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Xóa dị ứng thành công!', style: GoogleFonts.afacad()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Xóa', style: GoogleFonts.afacad(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteMedication(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa', style: GoogleFonts.afacad()),
        content: Text('Bạn có chắc muốn xóa thuốc này?', style: GoogleFonts.afacad()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Color(0xFF8B5CF6))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                medications.removeWhere((m) => m['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Xóa thuốc thành công!', style: GoogleFonts.afacad()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Xóa', style: GoogleFonts.afacad(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

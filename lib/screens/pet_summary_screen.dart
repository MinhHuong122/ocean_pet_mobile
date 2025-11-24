// lib/screens/pet_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/medical_record_service.dart';
import './training_screen.dart';
import './diary_screen.dart';
import './care_screen.dart';

class PetSummaryScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final String petBreed;
  final int? ageMonths;
  final String? profileImageUrl;

  const PetSummaryScreen({
    Key? key,
    required this.petId,
    required this.petName,
    required this.petBreed,
    this.ageMonths,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  State<PetSummaryScreen> createState() => _PetSummaryScreenState();
}

class _PetSummaryScreenState extends State<PetSummaryScreen> {
  int selectedTab = 0;
  final List<String> tabs = ['Tổng Hợp', 'Nhật Ký', 'Lịch Hẹn', 'Hồ Sơ Y Tế'];

  Map<String, dynamic> petData = {};
  List<Map<String, dynamic>> medicalHistories = [];
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPetData();
    _loadMedicalData();
  }

  Future<void> _loadPetData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final petDoc = await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.petId)
          .get();

      if (petDoc.exists) {
        setState(() {
          petData = petDoc.data() ?? {};
        });
      }
    } catch (e) {
      print('Error loading pet data: $e');
    }
  }

  Future<void> _loadMedicalData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      // Load diary entries for this pet from Firestore
      final diarySnapshot = await FirebaseFirestore.instance
          .collection('diary_entries')
          .where('user_id', isEqualTo: user.uid)
          .where('pet_id', isEqualTo: widget.petId)
          .orderBy('entry_date', descending: true)
          .get();

      print('📝 Loaded ${diarySnapshot.docs.length} diary entries for pet ${widget.petId}');

      // Load medical records for this pet
      final recordSnapshot = await MedicalRecordService.getMedicalRecord(widget.petId);

      if (recordSnapshot != null) {
        setState(() {
          // Get medical histories from consultations
          medicalHistories = recordSnapshot.consultations
              .map((c) => {
                'id': c.id,
                'condition': c.diagnosis ?? 'Unknown',
                'date': c.consultationDate.toString().split(' ')[0],
                'doctor': c.vetName,
                'description': c.symptoms ?? '',
              })
              .toList();

          // Generate appointments (next 30 days)
          appointments = medicalHistories
              .where((m) {
                try {
                  final date = DateTime.parse(m['date']);
                  return date.isAfter(DateTime.now()) &&
                      date.isBefore(DateTime.now().add(const Duration(days: 30)));
                } catch (e) {
                  return false;
                }
              })
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading medical data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatAge(int? ageMonths) {
    if (ageMonths == null) return 'Chưa rõ';
    if (ageMonths < 12) {
      return '$ageMonths tháng';
    } else {
      int years = ageMonths ~/ 12;
      int months = ageMonths % 12;
      if (months == 0) return '$years năm';
      return '$years năm $months tháng';
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
          widget.petName,
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
            // Pet Info Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                ),
                child: Row(
                  children: [
                    // Pet Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: widget.profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.profileImageUrl == null
                          ? const Icon(Icons.pets, size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Pet Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.petName,
                            style: GoogleFonts.afacad(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.petBreed,
                            style: GoogleFonts.afacad(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tuổi: ${_formatAge(widget.ageMonths)}',
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
            ),

            // Tab Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SizedBox(
                height: 50,
                child: Center(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                tabs[index],
                                style: GoogleFonts.afacad(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey[700],
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
            ),

            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF8B5CF6),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Column(
                          children: [
                            if (selectedTab == 0) _buildOverviewTab(),
                            if (selectedTab == 1) _buildDiaryTab(),
                            if (selectedTab == 2) _buildAppointmentsTab(),
                            if (selectedTab == 3) _buildMedicalRecordsTab(),
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

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông Tin Cơ Bản',
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Loài:', widget.petBreed),
              _buildInfoRow('Tuổi:', _formatAge(widget.ageMonths)),
              _buildInfoRow('Cân nặng:', '${petData['weight'] ?? 'Chưa rõ'} kg'),
              if (petData['gender'] != null) ...[
                _buildInfoRow('Giới tính:', petData['gender'] == 'male' ? 'Đực' : 'Cái'),
              ],
              if (petData['birth_date'] != null) ...[
                _buildInfoRow('Ngày sinh:', petData['birth_date'].toDate().toString().split(' ')[0]),
              ],
              if (petData['height'] != null) ...[
                _buildInfoRow('Chiều cao:', '${petData['height']} cm'),
              ],
              if (petData['notes'] != null && petData['notes'].toString().isNotEmpty) ...[
                _buildInfoRow('Ghi chú:', petData['notes'].toString()),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thống Kê',
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Lịch Khám', medicalHistories.length.toString()),
                  _buildStatCard('Lịch Hẹn', appointments.length.toString()),
                  _buildStatCard('Dị Ứng', '0'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiaryTab() {
    return Column(
      children: medicalHistories.isEmpty
          ? [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiaryScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note_add, color: Colors.green[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thêm Nhật Ký',
                              style: GoogleFonts.afacad(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tạo nhật ký sức khỏe cho thú cưng của bạn',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.green[700]),
                    ],
                  ),
                ),
              ),
            ]
          : medicalHistories.map((history) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          history['condition'] ?? '',
                          style: GoogleFonts.afacad(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          history['date'] ?? '',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      history['description'] ?? '',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }

  Widget _buildAppointmentsTab() {
    return Column(
      children: appointments.isEmpty
          ? [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CareScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.orange[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đặt Lịch Hẹn',
                              style: GoogleFonts.afacad(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tạo lịch khám cho thú cưng của bạn',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.orange[700]),
                    ],
                  ),
                ),
              ),
            ]
          : appointments.map((apt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apt['condition'] ?? '',
                            style: GoogleFonts.afacad(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            apt['date'] ?? '',
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
              );
            }).toList(),
    );
  }

  Widget _buildMedicalRecordsTab() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainingScreen(
                  initialPetId: widget.petId,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_services, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hồ Sơ Y Tế Chi Tiết',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Xem tất cả thông tin y tế và lịch khám',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.blue[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.afacad(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.afacad(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

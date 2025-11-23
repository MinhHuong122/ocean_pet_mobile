// lib/screens/care_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/AppointmentService.dart';
import './custom_bottom_nav.dart';
import './appointment_detail_screen.dart';
import './nutrition_screen.dart';
import './training_screen.dart';

class CareScreen extends StatefulWidget {
  const CareScreen({super.key});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> {
  List<Map<String, dynamic>> appointments = [
    {
      'id': '1',
      'title': 'Khám sức khỏe định kỳ',
      'date': '20/09/2025',
      'time': '10:00 AM',
      'location': 'Phòng khám Pet Care',
      'icon': Icons.medical_services,
      'color': Color(0xFFEF5350),
    },
    {
      'id': '2',
      'title': 'Tiêm phòng dại ứng',
      'date': '25/09/2025',
      'time': '2:00 PM',
      'location': 'Phòng khám Pet Care',
      'icon': Icons.vaccines,
      'color': Color(0xFF66BB6A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFirebaseAppointments();
  }

  Future<void> _loadFirebaseAppointments() async {
    try {
      final firebaseAppointments = await AppointmentService.getAppointments();
      
      // Map Firebase data to UI format
      final mappedAppointments = <Map<String, dynamic>>[];
      
      for (var apt in firebaseAppointments) {
        try {
          // Parse appointment_date Timestamp to DateTime
          DateTime appointmentDateTime;
          if (apt['appointment_date'] is Timestamp) {
            appointmentDateTime = (apt['appointment_date'] as Timestamp).toDate();
          } else if (apt['appointment_date'] is DateTime) {
            appointmentDateTime = apt['appointment_date'] as DateTime;
          } else {
            appointmentDateTime = DateTime.now();
          }

          // Determine icon and color based on type
          IconData icon = Icons.medical_services;
          Color color = const Color(0xFFEF5350);
          
          switch (apt['type']?.toString().toLowerCase()) {
            case 'health_checkup':
            case 'khám sức khỏe':
              icon = Icons.medical_services;
              color = const Color(0xFFEF5350);
              break;
            case 'vaccination':
            case 'tiêm phòng':
              icon = Icons.vaccines;
              color = const Color(0xFF66BB6A);
              break;
            case 'bath_spa':
            case 'tắm & spa':
              icon = Icons.bathroom;
              color = const Color(0xFF64B5F6);
              break;
            case 'grooming':
              icon = Icons.content_cut;
              color = const Color(0xFFFFB74D);
              break;
            default:
              icon = Icons.event;
              color = const Color(0xFF8E97FD);
          }

          final appointment = {
            'id': (apt['id'] ?? '').toString(),
            'title': (apt['type'] ?? 'Lịch hẹn').toString(),
            'date': DateFormat('dd/MM/yyyy').format(appointmentDateTime),
            'time': DateFormat('h:mm a').format(appointmentDateTime),
            'location': (apt['location'] ?? 'Không xác định').toString(),
            'icon': icon,
            'color': color,
            'notes': (apt['notes'] ?? '').toString(),
            'petId': (apt['pet_id'] ?? '').toString(),
            'appointmentDate': appointmentDateTime,
          };
          
          mappedAppointments.add(appointment);
        } catch (e) {
          print('⚠️ [CareScreen] Error mapping appointment: $e');
          continue;
        }
      }

      setState(() {
        appointments = mappedAppointments;
      });
      print('✅ [CareScreen] Loaded ${appointments.length} appointments from Firebase');
    } catch (e) {
      print('❌ [CareScreen] Lỗi tải lịch hẹn: $e');
      // Keep default appointments if load fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Upcoming Appointments (moved to top)
                Text(
                  'Lịch hẹn sắp tới',
                  style: GoogleFonts.afacad(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 16),

                if (appointments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có lịch hẹn nào',
                            style: GoogleFonts.afacad(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...appointments.map((appointment) => GestureDetector(
                        onTap: () => _openAppointmentDetail(appointment),
                        child: _buildAppointmentCard(
                          appointment['title'],
                          '${appointment['date']} - ${appointment['time']}',
                          appointment['location'],
                          appointment['icon'],
                          appointment['color'],
                        ),
                      )),

                const SizedBox(height: 24),

                // Care Services
                Text(
                  'Dịch vụ chăm sóc',
                  style: GoogleFonts.afacad(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 16),

                // Service Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildServiceCard(
                      'Khám sức khỏe',
                      Icons.medical_services,
                      const Color(0xFFEF5350),
                      'Đặt lịch khám',
                      () => _showBookingDialog('Khám sức khỏe',
                          Icons.medical_services, const Color(0xFFEF5350)),
                    ),
                    _buildServiceCard(
                      'Tiêm phòng',
                      Icons.vaccines,
                      const Color(0xFF66BB6A),
                      'Lịch tiêm chủng',
                      () => _showBookingDialog('Tiêm phòng', Icons.vaccines,
                          const Color(0xFF66BB6A)),
                    ),
                    _buildServiceCard(
                      'Tắm & Spa',
                      Icons.bathroom,
                      const Color(0xFF64B5F6),
                      'Đặt lịch spa',
                      () => _showBookingDialog(
                          'Tắm & Spa', Icons.bathroom, const Color(0xFF64B5F6)),
                    ),
                    _buildServiceCard(
                      'Dinh dưỡng',
                      Icons.restaurant,
                      const Color(0xFFFFB74D),
                      'Kế hoạch ăn',
                      () => _showNutritionDialog(),
                    ),
                    _buildServiceCard(
                      'Hồ sơ y tế',
                      Icons.description,
                      const Color(0xFF8B5CF6),
                      'Lịch sử bệnh lý',
                      () => _showMedicalRecordsDialog(),
                    ),
                    _buildServiceCard(
                      'Khẩn cấp',
                      Icons.local_hospital,
                      const Color(0xFFFF5252),
                      'SOS 24/7',
                      () => _showEmergencyDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildServiceCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.afacad(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    String title,
    String dateTime,
    String location,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      dateTime,
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  void _openAppointmentDetail(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(
          appointment: appointment,
          onSave: (updatedAppointment) {
            setState(() {
              final index = appointments.indexWhere((a) => a['id'] == updatedAppointment['id']);
              if (index != -1) {
                appointments[index] = updatedAppointment;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Đã cập nhật lịch hẹn!',
                  style: GoogleFonts.afacad(),
                ),
                backgroundColor: const Color(0xFF66BB6A),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBookingDialog(String serviceName, IconData icon, Color color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(
          onSave: (appointment) {
            setState(() {
              appointments.add(appointment);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Đã đặt lịch thành công!',
                  style: GoogleFonts.afacad(),
                ),
                backgroundColor: const Color(0xFF66BB6A),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showNutritionDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NutritionScreen(),
      ),
    );
  }

  void _showMedicalRecordsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrainingScreen(),
      ),
    );
  }

  void _showEmergencyDialog() {
    final List<Map<String, String>> emergencyContacts = [
      {
        'title': 'Ngược đãi động vật',
        'phone': '911',
        'description': 'Báo cáo ngược đãi thú cưng',
        'icon': 'warning',
      },
      {
        'title': 'Thú cưng bị bệnh',
        'phone': '1900299982',
        'description': 'Tư vấn khẩn cấp 24/7',
        'icon': 'medical',
      },
      {
        'title': 'Phòng khám Pet Care',
        'phone': '0123456789',
        'description': 'Hotline khẩn cấp',
        'icon': 'hospital',
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Liên hệ khẩn cấp',
                    style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emergency Contacts
                  ...emergencyContacts.map((contact) {
                    IconData iconData = contact['icon'] == 'warning'
                        ? Icons.warning
                        : contact['icon'] == 'medical'
                            ? Icons.medical_services
                            : Icons.local_hospital;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconData, color: Colors.red),
                        ),
                        title: Text(
                          contact['title']!,
                          style: GoogleFonts.afacad(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact['phone']!,
                              style: GoogleFonts.afacad(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              contact['description']!,
                              style: GoogleFonts.afacad(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.phone, color: Colors.red),
                        onTap: () => _makePhoneCall(contact['phone']!),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  // Rescue Center Link
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF66BB6A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF66BB6A).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.pets, color: Color(0xFF66BB6A)),
                      ),
                      title: Text(
                        'Trạm cứu hộ chó mèo',
                        style: GoogleFonts.afacad(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Danh sách trạm cứu hộ',
                        style: GoogleFonts.afacad(fontSize: 12),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _openUrl(
                          'https://www.petmart.vn/tram-cuu-ho-cho-meo?srsltid=AfmBOopECBq1V0sdrFHl_bjok8Vz1QdLRBA-Nzi5f2KE-YFI2i0gYQKx#Tram_cuu_ho_cho_meo_Ha_Noi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng',
                  style: GoogleFonts.afacad(color: Color(0xFF8E97FD))),
            ),
          ],
        );
      },
    );
  }

  // Open URL in external browser
  Future<void> _openUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể mở liên kết',
                  style: GoogleFonts.afacad()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e', style: GoogleFonts.afacad()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri telUrl = Uri.parse('tel:$phoneNumber');
      if (!await launchUrl(telUrl)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể gọi điện',
                  style: GoogleFonts.afacad()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e', style: GoogleFonts.afacad()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}

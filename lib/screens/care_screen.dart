// lib/screens/care_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart';

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
                // ...existing code...

                // Pet Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8E97FD),
                        const Color(0xFF8E97FD).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.pets,
                          size: 40,
                          color: const Color(0xFF8E97FD),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mochi',
                              style: GoogleFonts.afacad(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Mèo Ba Tư • 2 tuổi',
                              style: GoogleFonts.afacad(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.favorite,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Sức khỏe tốt',
                                  style: GoogleFonts.afacad(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
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
                      'Huấn luyện',
                      Icons.school,
                      const Color(0xFFAB47BC),
                      'Khóa học',
                      () => _showTrainingDialog(),
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
                const SizedBox(height: 24),

                // Upcoming Appointments
                Text(
                  'Lịch hẹn sắp tới',
                  style: GoogleFonts.afacad(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 16),

                _buildAppointmentCard(
                  'Khám sức khỏe định kỳ',
                  '20/09/2025 - 10:00 AM',
                  'Phòng khám Pet Care',
                  Icons.medical_services,
                  const Color(0xFFEF5350),
                ),
                _buildAppointmentCard(
                  'Tiêm phòng dại ứng',
                  '25/09/2025 - 2:00 PM',
                  'Phòng khám Pet Care',
                  Icons.vaccines,
                  const Color(0xFF66BB6A),
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

  void _showBookingDialog(String serviceName, IconData icon, Color color) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final locationController =
        TextEditingController(text: 'Phòng khám Pet Care');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Text(
                    'Đặt lịch $serviceName',
                    style: GoogleFonts.afacad(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chọn ngày:',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: color),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: GoogleFonts.afacad(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Chọn giờ:',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: color),
                            const SizedBox(width: 12),
                            Text(
                              selectedTime.format(context),
                              style: GoogleFonts.afacad(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Địa điểm:',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.location_on, color: color),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy',
                      style: GoogleFonts.afacad(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      appointments.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': serviceName,
                        'date':
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        'time': selectedTime.format(context),
                        'location': locationController.text,
                        'icon': icon,
                        'color': color,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã đặt lịch $serviceName thành công!'),
                        backgroundColor: const Color(0xFF66BB6A),
                      ),
                    );
                  },
                  child: Text('Đặt lịch',
                      style: GoogleFonts.afacad(
                          color: color, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNutritionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.restaurant, color: Color(0xFFFFB74D)),
              const SizedBox(width: 12),
              Text('Kế hoạch dinh dưỡng',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chức năng kế hoạch dinh dưỡng đang được phát triển.',
                style: GoogleFonts.afacad(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Sẽ bao gồm:\n• Tư vấn thức ăn\n• Lịch cho ăn\n• Theo dõi cân nặng\n• Dinh dưỡng theo độ tuổi',
                style:
                    GoogleFonts.afacad(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
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

  void _showTrainingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.school, color: Color(0xFFAB47BC)),
              const SizedBox(width: 12),
              Text('Khóa học huấn luyện',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chức năng huấn luyện đang được phát triển.',
                style: GoogleFonts.afacad(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Sẽ bao gồm:\n• Huấn luyện cơ bản\n• Huấn luyện nâng cao\n• Video hướng dẫn\n• Lịch tập luyện',
                style:
                    GoogleFonts.afacad(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
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

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.local_hospital, color: Color(0xFFFF5252)),
              const SizedBox(width: 12),
              Text('Khẩn cấp 24/7',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đường dây nóng khẩn cấp:',
                style: GoogleFonts.afacad(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildEmergencyContact('Phòng khám Pet Care', '0123-456-789'),
              _buildEmergencyContact('Bác sĩ thú y 24/7', '0987-654-321'),
              _buildEmergencyContact('Cấp cứu thú cưng', '0911-222-333'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFF5252).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⚠️ Trong trường hợp khẩn cấp, vui lòng gọi ngay và đưa thú cưng đến phòng khám gần nhất!',
                  style: GoogleFonts.afacad(
                      fontSize: 13, color: Color(0xFFFF5252)),
                ),
              ),
            ],
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

  Widget _buildEmergencyContact(String name, String phone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              Text(phone, style: GoogleFonts.afacad(color: Colors.grey[600])),
            ],
          ),
          Icon(Icons.phone, color: Color(0xFF66BB6A)),
        ],
      ),
    );
  }
}

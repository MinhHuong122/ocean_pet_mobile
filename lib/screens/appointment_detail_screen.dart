// lib/screens/appointment_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/FirebaseService.dart';
import 'map_picker_screen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? appointment;
  final Function(Map<String, dynamic>) onSave;

  const AppointmentDetailScreen({
    super.key,
    this.appointment,
    required this.onSave,
  });

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _noteController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedPetId;
  String? _selectedPetName;
  
  List<Map<String, dynamic>> _availablePets = [];
  bool _isLoadingPets = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    _loadPetsFromFirebase();
    
    if (widget.appointment != null) {
      _titleController = TextEditingController(text: widget.appointment!['title']);
      _locationController = TextEditingController(text: widget.appointment!['location']);
      _noteController = TextEditingController(text: widget.appointment!['note'] ?? '');
      
      // Parse date from string "20/09/2025"
      if (widget.appointment!['date'] != null) {
        try {
          final parts = widget.appointment!['date'].split('/');
          _selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          _focusedDay = _selectedDate;
        } catch (e) {
          _selectedDate = DateTime.now();
        }
      }
      
      // Parse time from string "10:00 AM"
      if (widget.appointment!['time'] != null) {
        try {
          final timeStr = widget.appointment!['time'].toString();
          final format = DateFormat('h:mm a');
          final dateTime = format.parse(timeStr);
          _selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        } catch (e) {
          _selectedTime = TimeOfDay.now();
        }
      }
      
      _selectedPetId = widget.appointment!['petId'];
      _selectedPetName = widget.appointment!['petName'];
    } else {
      _titleController = TextEditingController();
      _locationController = TextEditingController(text: 'Phòng khám Pet Care');
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadPetsFromFirebase() async {
    setState(() => _isLoadingPets = true);
    
    try {
      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        setState(() => _isLoadingPets = false);
        return;
      }

      final pets = await FirebaseService.getPets();
      setState(() {
        _availablePets = pets;
        _isLoadingPets = false;
      });
    } catch (e) {
      print('Error loading pets: $e');
      setState(() => _isLoadingPets = false);
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
          icon: const Icon(Icons.close, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.appointment != null ? 'Chi tiết lịch hẹn' : 'Tạo lịch hẹn mới',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveAppointment,
            child: Text(
              'Lưu',
              style: GoogleFonts.afacad(
                color: const Color(0xFF8E97FD),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E97FD).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                locale: 'vi_VN',
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.afacad(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF8E97FD),
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF8E97FD),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF8E97FD),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF8E97FD).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: GoogleFonts.afacad(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  todayTextStyle: GoogleFonts.afacad(
                    color: const Color(0xFF22223B),
                    fontWeight: FontWeight.bold,
                  ),
                  defaultTextStyle: GoogleFonts.afacad(
                    color: const Color(0xFF22223B),
                  ),
                  weekendTextStyle: GoogleFonts.afacad(
                    color: const Color(0xFFEF5350),
                  ),
                ),
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  _buildSectionTitle('Tiêu đề', Icons.title),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'Ví dụ: Khám sức khỏe định kỳ',
                    icon: Icons.edit,
                  ),
                  const SizedBox(height: 20),

                  // Pet Selection
                  _buildSectionTitle('Chọn thú cưng', Icons.pets),
                  const SizedBox(height: 8),
                  _buildPetSelector(),
                  const SizedBox(height: 20),

                  // Time
                  _buildSectionTitle('Thời gian', Icons.access_time),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8E97FD).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFF8E97FD),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedTime.format(context),
                            style: GoogleFonts.afacad(
                              fontSize: 16,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _buildSectionTitle('Địa điểm', Icons.location_on),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'Nhập địa điểm',
                    icon: Icons.location_on,
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.map,
                        color: Color(0xFF8E97FD),
                      ),
                      onPressed: _openMapPicker,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Note
                  _buildSectionTitle('Ghi chú', Icons.note),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _noteController,
                    hint: 'Thêm ghi chú...',
                    icon: Icons.note,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8E97FD), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.afacad(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8E97FD).withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.afacad(
          fontSize: 16,
          color: const Color(0xFF22223B),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.afacad(
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF8E97FD), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPetSelector() {
    if (_isLoadingPets) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8E97FD).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E97FD)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Đang tải danh sách thú cưng...',
              style: GoogleFonts.afacad(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    if (_availablePets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8E97FD).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: Color(0xFF8E97FD)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Chưa có thú cưng nào. Vui lòng thêm thú cưng trước.',
                style: GoogleFonts.afacad(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8E97FD).withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedPetId,
          hint: Text(
            'Chọn thú cưng',
            style: GoogleFonts.afacad(color: Colors.grey[400]),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8E97FD)),
          style: GoogleFonts.afacad(
            fontSize: 16,
            color: const Color(0xFF22223B),
          ),
          items: _availablePets.map((pet) {
            return DropdownMenuItem<String>(
              value: pet['id'],
              child: Row(
                children: [
                  // Avatar thú cưng
                  if (pet['avatar_url'] != null)
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(pet['avatar_url']),
                    )
                  else
                    const Icon(Icons.pets, size: 20, color: Color(0xFF8E97FD)),
                  const SizedBox(width: 12),
                  Text('${pet['name']} (${pet['type']})'),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPetId = value;
              _selectedPetName = _availablePets
                  .firstWhere((pet) => pet['id'] == value)['name'];
            });
          },
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8E97FD),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _openMapPicker() async {
    try {
      final selectedAddress = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => MapPickerScreen(
            initialAddress: _locationController.text,
          ),
        ),
      );

      if (selectedAddress != null && selectedAddress.isNotEmpty) {
        setState(() {
          _locationController.text = selectedAddress;
        });
      }
    } catch (e) {
      print('Error opening map: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể mở bản đồ. Vui lòng nhập địa chỉ thủ công.',
              style: GoogleFonts.afacad(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _saveAppointment() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng nhập tiêu đề',
            style: GoogleFonts.afacad(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appointment = {
      'id': widget.appointment?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _titleController.text,
      'date': DateFormat('dd/MM/yyyy').format(_selectedDate),
      'time': _selectedTime.format(context),
      'location': _locationController.text,
      'note': _noteController.text,
      'icon': widget.appointment?['icon'] ?? Icons.medical_services,
      'color': widget.appointment?['color'] ?? const Color(0xFF8E97FD),
      'petId': _selectedPetId,
      'petName': _selectedPetName,
      'dateTime': DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ).toIso8601String(),
    };

    widget.onSave(appointment);
    Navigator.pop(context);
  }
}

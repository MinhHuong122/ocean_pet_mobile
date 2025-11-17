// lib/screens/appointment_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/FirebaseService.dart';

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
  
  // Recurring and Reminder variables
  bool _isRecurring = false;
  String _recurringCycle = 'monthly'; // monthly, quarterly, biannual, yearly
  String _reminderTime = '1day'; // 1day, 3days, 1week
  
  List<Map<String, dynamic>> _availablePets = [];
  bool _isLoadingPets = true;

  // Map picker variables
  static const String _geoapifyApiKey = '7c0100b7e4614f859ec61a564091807b';
  double _selectedLat = 10.762622;
  double _selectedLon = 106.660172;
  bool _isSearchingLocation = false;
  List<Map<String, dynamic>> _searchResults = [];

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
                  _buildLocationPicker(),
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
                  const SizedBox(height: 20),

                  // Recurring Section
                  _buildSectionTitle('Lặp lại sự kiện', Icons.repeat),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8E97FD).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bật lặp lại',
                              style: GoogleFonts.afacad(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF22223B),
                              ),
                            ),
                            Switch(
                              value: _isRecurring,
                              onChanged: (value) {
                                setState(() => _isRecurring = value);
                              },
                              activeColor: const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                        if (_isRecurring) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Chu kỳ lặp lại',
                            style: GoogleFonts.afacad(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _recurringCycle,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF8B5CF6)),
                                style: GoogleFonts.afacad(
                                  fontSize: 14,
                                  color: const Color(0xFF22223B),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'monthly',
                                    child: Text('Hàng tháng',
                                        style: GoogleFonts.afacad()),
                                  ),
                                  DropdownMenuItem(
                                    value: 'quarterly',
                                    child: Text('3 tháng 1 lần',
                                        style: GoogleFonts.afacad()),
                                  ),
                                  DropdownMenuItem(
                                    value: 'biannual',
                                    child: Text('6 tháng 1 lần',
                                        style: GoogleFonts.afacad()),
                                  ),
                                  DropdownMenuItem(
                                    value: 'yearly',
                                    child: Text('Hàng năm',
                                        style: GoogleFonts.afacad()),
                                  ),
                                ].toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _recurringCycle = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reminder Section
                  _buildSectionTitle('Nhắc nhở', Icons.notifications),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8E97FD).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thời gian nhắc trước',
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildReminderButton('1 ngày', '1day'),
                            _buildReminderButton('3 ngày', '3days'),
                            _buildReminderButton('1 tuần', '1week'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Color(0xFF8B5CF6), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bạn sẽ nhận được thông báo ${_reminderTimeText(_reminderTime)} trước lịch hẹn',
                                  style: GoogleFonts.afacad(
                                    fontSize: 12,
                                    color: const Color(0xFF22223B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  // Map picker methods
  Future<void> _searchLocationGeoapify(String query) async {
    if (query.isEmpty) return;

    if (mounted) setState(() => _isSearchingLocation = true);

    try {
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?text=${Uri.encodeComponent(query)}&apiKey=$_geoapifyApiKey'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: Không thể kết nối server');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['features'] != null && data['features'].isNotEmpty) {
          if (!mounted) return;
          
          setState(() {
            _searchResults = (data['features'] as List).map((f) {
              final p = f['properties'];
              return {
                'lat': p['lat'] ?? 10.762622,
                'lon': p['lon'] ?? 106.660172,
                'formatted': p['formatted'] ?? '',
                'name': p['name'] ?? '',
                'city': p['city'] ?? '',
              };
            }).toList();
          });
        } else {
          if (!mounted) return;
          setState(() {
            _searchResults = [];
          });
          _showLocationError('Không tìm thấy địa điểm');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error search: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
        _showLocationError('Lỗi tìm kiếm: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingLocation = false);
      }
    }
  }

  Future<void> _getCurrentLocationGPS() async {
    if (!mounted) return;
    setState(() => _isSearchingLocation = true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) _showLocationError('Bạn cần cấp quyền truy cập vị trí');
          if (mounted) setState(() => _isSearchingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showGPSPermissionDialog();
        if (mounted) setState(() => _isSearchingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('GPS timeout');
        },
      );

      if (!mounted) return;
      setState(() {
        _selectedLat = position.latitude;
        _selectedLon = position.longitude;
      });

      await _reverseGeocodeLocation(_selectedLat, _selectedLon);
    } catch (e) {
      print('Location Error: $e');
      if (mounted) {
        _showLocationError('Không thể lấy vị trí.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingLocation = false);
      }
    }
  }

  Future<void> _reverseGeocodeLocation(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=$lat&lon=$lon&apiKey=$_geoapifyApiKey'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['features'] != null && data['features'].isNotEmpty) {
          final props = data['features'][0]['properties'];
          
          if (!mounted) return;
          
          setState(() {
            _locationController.text = props['formatted'] ?? 
                              '${props['street'] ?? ''}, ${props['city'] ?? ''}';
            _searchResults.clear();
          });
        }
      }
    } catch (e) {
      print('Error reverse: $e');
      if (mounted) {
        _showLocationError('Không xác định được địa chỉ');
      }
    }
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    setState(() {
      _selectedLat = result['lat'];
      _selectedLon = result['lon'];
      _locationController.text = result['formatted'];
      _searchResults.clear();
    });
  }

  void _showLocationError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.afacad()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showGPSPermissionDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Cần quyền vị trí',
          style: GoogleFonts.afacad(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Text(
          'Vui lòng bật quyền vị trí trong Cài đặt.',
          style: GoogleFonts.afacad(color: const Color(0xFF22223B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            child: Text(
              'Mở Cài đặt',
              style: GoogleFonts.afacad(
                color: const Color(0xFF8E97FD),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      children: [
        // Location input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8E97FD).withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _locationController,
            style: GoogleFonts.afacad(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm địa điểm...',
              hintStyle: GoogleFonts.afacad(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.location_on, color: Color(0xFF8E97FD)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_locationController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _locationController.clear();
                        setState(() => _searchResults.clear());
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Color(0xFF8E97FD)),
                    onPressed: _getCurrentLocationGPS,
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onSubmitted: _searchLocationGeoapify,
            textInputAction: TextInputAction.search,
          ),
        ),
        const SizedBox(height: 12),
        
        // Search results or loading
        if (_isSearchingLocation)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E97FD)),
              ),
            ),
          ),
        
        if (_searchResults.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8E97FD).withOpacity(0.3),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, i) {
                final r = _searchResults[i];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF8E97FD), size: 18),
                  title: Text(
                    r['name'] ?? r['formatted'],
                    style: GoogleFonts.afacad(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    r['formatted'],
                    style: GoogleFonts.afacad(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectSearchResult(r),
                );
              },
            ),
          ),
        
        // Show coordinates if location selected
        if (_locationController.text.isNotEmpty && _searchResults.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8E97FD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF8E97FD), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tọa độ: ${_selectedLat.toStringAsFixed(4)}, ${_selectedLon.toStringAsFixed(4)}',
                    style: GoogleFonts.afacad(fontSize: 12, color: const Color(0xFF22223B)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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
      // New fields for recurring and reminder
      'isRecurring': _isRecurring,
      'recurringCycle': _recurringCycle,
      'reminderTime': _reminderTime,
    };

    widget.onSave(appointment);
    Navigator.pop(context);
  }

  Widget _buildReminderButton(String label, String value) {
    final isSelected = _reminderTime == value;
    return GestureDetector(
      onTap: () {
        setState(() => _reminderTime = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF22223B),
          ),
        ),
      ),
    );
  }

  String _reminderTimeText(String value) {
    switch (value) {
      case '1day':
        return '1 ngày';
      case '3days':
        return '3 ngày';
      case '1week':
        return '1 tuần';
      default:
        return '1 ngày';
    }
  }
}

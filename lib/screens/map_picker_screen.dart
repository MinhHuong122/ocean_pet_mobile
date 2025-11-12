// lib/screens/map_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  final String? initialAddress;

  const MapPickerScreen({super.key, this.initialAddress});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Geoapify API Key from image
  static const String _geoapifyApiKey = '7c0100b7e4614f859ec61a564091807b';
  
  double _selectedLat = 10.762622;
  double _selectedLon = 106.660172;
  String _selectedAddress = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Không gọi GPS ngay khi khởi động - chỉ khi user bấm nút
    if (widget.initialAddress != null) {
      _searchController.text = widget.initialAddress!;
      _searchLocation(widget.initialAddress!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) _showError('Bạn cần cấp quyền truy cập vị trí');
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Timeout 5 giây - nếu không lấy được thì dùng vị trí mặc định
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('GPS timeout - sử dụng vị trí mặc định');
        },
      );

      if (!mounted) return;
      setState(() {
        _selectedLat = position.latitude;
        _selectedLon = position.longitude;
      });

      await _reverseGeocode(_selectedLat, _selectedLon);
    } catch (e) {
      print('Location Error: $e');
      if (mounted) {
        _showError('Không thể lấy vị trí. Dùng vị trí mặc định.');
        await _reverseGeocode(_selectedLat, _selectedLon);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
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
            _selectedAddress = props['formatted'] ?? 
                              '${props['street'] ?? ''}, ${props['city'] ?? ''}';
            _searchController.text = _selectedAddress;
          });
        }
      }
    } catch (e) {
      print('Error reverse: $e');
      if (mounted) {
        setState(() {
          _selectedAddress = 'Không xác định được địa chỉ';
          _searchController.text = _selectedAddress;
        });
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    if (mounted) setState(() => _isLoading = true);

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
          _showError('Không tìm thấy địa điểm');
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
        _showError('Lỗi tìm kiếm: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectResult(Map<String, dynamic> result) {
    setState(() {
      _selectedLat = result['lat'];
      _selectedLon = result['lon'];
      _selectedAddress = result['formatted'];
      _searchController.text = _selectedAddress;
      _searchResults.clear();
    });
  }

  Future<void> _showPermissionDialog() async {
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.afacad()),
        backgroundColor: Colors.red,
      ),
    );
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
          'Chọn địa điểm',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedAddress),
            child: Text(
              'Xong',
              style: GoogleFonts.afacad(
                color: const Color(0xFF8E97FD),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8E97FD).withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.afacad(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm địa điểm...',
                  hintStyle: GoogleFonts.afacad(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8E97FD)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults.clear());
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xFF8E97FD)),
                        onPressed: _getCurrentLocation,
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: _searchLocation,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E97FD)),
              ),
            ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, i) {
                  final r = _searchResults[i];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFF8E97FD)),
                    title: Text(
                      r['name'] ?? r['formatted'],
                      style: GoogleFonts.afacad(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    subtitle: Text(
                      r['formatted'],
                      style: GoogleFonts.afacad(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectResult(r),
                  );
                },
              ),
            ),
          if (_selectedAddress.isNotEmpty && _searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E97FD).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 60,
                          color: Color(0xFF8E97FD),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Địa điểm đã chọn',
                        style: GoogleFonts.afacad(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
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
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF8E97FD), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedAddress,
                                style: GoogleFonts.afacad(
                                  fontSize: 14,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tọa độ: ${_selectedLat.toStringAsFixed(6)}, ${_selectedLon.toStringAsFixed(6)}',
                        style: GoogleFonts.afacad(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isLoading && _searchResults.isEmpty && _selectedAddress.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, size: 80, color: Colors.grey),
                      const SizedBox(height: 24),
                      Text(
                        'Tìm kiếm địa điểm',
                        style: GoogleFonts.afacad(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nhập tên đường, quận, thành phố',
                        style: GoogleFonts.afacad(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
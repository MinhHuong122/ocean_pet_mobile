// lib/screens/map_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPickerScreen extends StatefulWidget {
  final String? initialAddress;

  const MapPickerScreen({super.key, this.initialAddress});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(10.762622, 106.660172); // Sài Gòn
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _mapError = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (widget.initialAddress != null) {
      _searchController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      // Kiểm tra quyền truy cập vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Bạn cần cấp quyền truy cập vị trí');
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Mở cài đặt để user bật quyền
        _showPermissionDialog();
        setState(() => _isLoading = false);
        return;
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _selectedPosition = LatLng(position.latitude, position.longitude);
      
      // Di chuyển camera đến vị trí hiện tại
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition, 15),
      );

      // Lấy địa chỉ
      await _getAddressFromLatLng(_selectedPosition);
    } catch (e) {
      print('Error getting location: $e');
      _showError('Không thể lấy vị trí hiện tại. Sử dụng vị trí mặc định.');
      // Vẫn hiển thị bản đồ với vị trí mặc định
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition, 15),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showPermissionDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Cần quyền truy cập vị trí',
          style: GoogleFonts.afacad(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Text(
          'Ứng dụng cần quyền truy cập vị trí để hiển thị vị trí của bạn trên bản đồ. Vui lòng bật quyền trong Cài đặt.',
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

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = '${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
          _searchController.text = _selectedAddress;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        _selectedPosition = LatLng(location.latitude, location.longitude);
        
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedPosition, 15),
        );

        await _getAddressFromLatLng(_selectedPosition);
      }
    } catch (e) {
      print('Error searching location: $e');
      _showError('Không tìm thấy địa điểm');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.afacad()),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _selectedPosition,
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onTap: (position) async {
        setState(() {
          _selectedPosition = position;
        });
        await _getAddressFromLatLng(position);
      },
      markers: {
        Marker(
          markerId: const MarkerId('selected'),
          position: _selectedPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildFallbackUI() {
    return Container(
      color: const Color(0xFFF6F6F6),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 80,
                color: Color(0xFF8E97FD),
              ),
              const SizedBox(height: 24),
              Text(
                'Google Maps không khả dụng',
                style: GoogleFonts.afacad(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Vui lòng nhập địa chỉ thủ công bên dưới',
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () {
              Navigator.pop(context, _searchController.text.isEmpty ? _selectedAddress : _searchController.text);
            },
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
      body: Stack(
        children: [
          // Google Map hoặc fallback UI
          if (_mapError)
            _buildFallbackUI()
          else
            _buildGoogleMap(),

          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.afacad(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm địa điểm...',
                  hintStyle: GoogleFonts.afacad(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8E97FD)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: (_) => _searchLocation(),
              ),
            ),
          ),

          // Selected address card
          if (_selectedAddress.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF8E97FD),
                      size: 24,
                    ),
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
            ),

          // My location button
          Positioned(
            right: 16,
            bottom: _selectedAddress.isNotEmpty ? 100 : 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.my_location,
                color: Color(0xFF8E97FD),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E97FD)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

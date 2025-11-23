// lib/screens/lost_pet_screen.dart
// Tích hợp Firebase LostPetService và legacy support
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import '../services/LostPetService.dart';
import '../services/CloudinaryService.dart';

class LostPetScreen extends StatefulWidget {
  final bool useFirebase;

  const LostPetScreen({Key? key, this.useFirebase = false}) : super(key: key);

  @override
  State<LostPetScreen> createState() => _LostPetScreenState();
}

class _LostPetScreenState extends State<LostPetScreen> {
  int _selectedTab = 0; // 0: Browse, 1: My Posts
  List<Map<String, dynamic>> _lostPets = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadFirebaseData();
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  Future<void> _loadFirebaseData() async {
    try {
      print('📥 [LostPetScreen] Loading lost pets from Firebase...');
      
      final firebasePets = await LostPetService.getLostPets(status: 'active');
      print('✅ [LostPetScreen] Received ${firebasePets.length} pets from Firebase');
      
      // Map Firebase data to UI format
      final mappedPets = <Map<String, dynamic>>[];
      
      for (var pet in firebasePets) {
        try {
          // Parse lost_date Timestamp to DateTime
          DateTime lostDateTime;
          if (pet['lost_date'] is Timestamp) {
            lostDateTime = (pet['lost_date'] as Timestamp).toDate();
          } else if (pet['lost_date'] is DateTime) {
            lostDateTime = pet['lost_date'] as DateTime;
          } else {
            lostDateTime = DateTime.now();
          }

          // Map Firebase pet type to emoji
          String emoji = '🐱';
          final petType = (pet['pet_type'] ?? 'cat').toString().toLowerCase();
          if (petType.contains('dog') || petType.contains('chó')) {
            emoji = '🐕';
          } else if (petType.contains('cat') || petType.contains('mèo')) {
            emoji = '🐱';
          } else if (petType.contains('bird') || petType.contains('chim') || petType.contains('vẹt')) {
            emoji = '🐦';
          } else if (petType.contains('fish') || petType.contains('cá')) {
            emoji = '🐠';
          } else if (petType.contains('snake') || petType.contains('rắn')) {
            emoji = '🐍';
          } else if (petType.contains('turtle') || petType.contains('rùa')) {
            emoji = '🐢';
          } else if (petType.contains('pig') || petType.contains('heo')) {
            emoji = '🐷';
          } else if (petType.contains('rabbit') || petType.contains('thỏ')) {
            emoji = '🐰';
          } else if (petType.contains('hamster')) {
            emoji = '🐹';
          }

          final mappedPet = {
            'id': (pet['id'] ?? '').toString(),
            'name': (pet['pet_name'] ?? 'Unknown').toString(),
            'type': (pet['pet_type'] ?? 'Unknown').toString(),
            'location': (pet['lost_location'] ?? 'Unknown').toString(),
            'lat': pet['latitude'] ?? 10.7769,
            'lng': pet['longitude'] ?? 106.6955,
            'date': DateFormat('yyyy-MM-dd').format(lostDateTime),
            'description': (pet['distinguishing_features'] ?? '').toString(),
            'phone': (pet['phone_number'] ?? '').toString(),
            'image': pet['image_url'] ?? emoji, // Use Cloudinary URL if available
            'userId': (pet['user_id'] ?? '').toString(),
          };
          
          mappedPets.add(mappedPet);
          print('✅ [LostPetScreen] Processed: ${pet['pet_name']}');
        } catch (e) {
          print('⚠️ [LostPetScreen] Error mapping pet: $e');
          continue;
        }
      }

      setState(() {
        _lostPets = mappedPets;
      });
      print('📊 [LostPetScreen] Loaded ${_lostPets.length} lost pets');
    } catch (e) {
      print('❌ [LostPetScreen] Error loading Firebase data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get _myPosts {
    // Filter by current user ID
    return _lostPets.where((pet) => pet['userId'] == _currentUserId).toList();
  }

  List<Map<String, dynamic>> get _displayedPets {
    return _selectedTab == 0 ? _lostPets : _myPosts;
  }

  Future<void> _searchLocationGeoapify(String query, Function(List<Map<String, dynamic>>) onResults) async {
    if (query.isEmpty) return;

    try {
      const geoapifyApiKey = '7c0100b7e4614f859ec61a564091807b';
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?text=${Uri.encodeComponent(query)}&apiKey=$geoapifyApiKey'
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
          final results = (data['features'] as List).map((f) {
            final p = f['properties'];
            return {
              'lat': p['lat'] ?? 10.762622,
              'lon': p['lon'] ?? 106.660172,
              'formatted': p['formatted'] ?? '',
              'name': p['name'] ?? '',
              'city': p['city'] ?? '',
            };
          }).toList();
          onResults(results);
        } else {
          _showSnackBar('Không tìm thấy địa điểm');
          onResults([]);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error search: $e');
      _showSnackBar('Lỗi tìm kiếm: ${e.toString()}');
      onResults([]);
    }
  }

  Future<void> _getCurrentLocationGPS(Function(double, double) onLocation, Function(bool) onLoading) async {
    onLoading(true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Bạn cần cấp quyền truy cập vị trí');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Vui lòng bật quyền vị trí trong Cài đặt');
        await Geolocator.openLocationSettings();
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

      onLocation(position.latitude, position.longitude);
    } catch (e) {
      print('Location Error: $e');
      _showSnackBar('Không thể lấy vị trí.');
    } finally {
      onLoading(false);
    }
  }

  Future<void> _reverseGeocodeLocation(double lat, double lon, Function(String) onAddress) async {
    try {
      const geoapifyApiKey = '7c0100b7e4614f859ec61a564091807b';
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=$lat&lon=$lon&apiKey=$geoapifyApiKey'
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
          final address = props['formatted'] ?? '${props['street'] ?? ''}, ${props['city'] ?? ''}';
          onAddress(address);
        }
      }
    } catch (e) {
      print('Error reverse: $e');
      _showSnackBar('Không xác định được địa chỉ');
    }
  }

  void _showPostForm({Map<String, dynamic>? editingPost}) {
    final isEditing = editingPost != null;
    final formKey = GlobalKey<FormState>();
    
    // Use TextEditingControllers instead of late variables
    final nameController = TextEditingController(
      text: isEditing ? editingPost['name'] : '',
    );
    final locationController = TextEditingController(
      text: isEditing ? editingPost['location'] : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? editingPost['description'] : '',
    );
    final phoneController = TextEditingController(
      text: isEditing ? editingPost['phone'] : '',
    );
    
    String selectedType = isEditing ? editingPost['type'] : 'Chó';
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.8,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setState) {
            // Location picker state variables
            double selectedLat = isEditing ? (editingPost['lat'] ?? 10.7769) : 10.7769;
            double selectedLon = isEditing ? (editingPost['lng'] ?? 106.6955) : 106.6955;
            List<Map<String, dynamic>> searchResults = [];
            
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEditing ? 'Chỉnh sửa tin' : 'Đăng tin thất lạc',
                      style: GoogleFonts.afacad(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Image picker
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() {
                            selectedImage = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap để chọn hình ảnh',
                                    style: GoogleFonts.afacad(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Pet name
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên thú cưng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.pets),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Nhập tên thú cưng' : null,
                    ),
                    const SizedBox(height: 12),
                    // Pet type
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Loại thú cưng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Chó', child: Text('Chó')),
                        DropdownMenuItem(value: 'Mèo', child: Text('Mèo')),
                        DropdownMenuItem(value: 'Cá', child: Text('Cá')),
                        DropdownMenuItem(value: 'Rắn', child: Text('Rắn')),
                        DropdownMenuItem(value: 'Rùa', child: Text('Rùa')),
                        DropdownMenuItem(value: 'Heo', child: Text('Heo')),
                        DropdownMenuItem(value: 'Thỏ', child: Text('Thỏ')),
                        DropdownMenuItem(value: 'Vẹt', child: Text('Vẹt')),
                        DropdownMenuItem(value: 'Hamster', child: Text('Hamster')),
                        DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => selectedType = v);
                        }
                      },
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Chọn loại thú cưng' : null,
                    ),
                    const SizedBox(height: 12),
                    // Location Picker with search and GPS
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: locationController,
                        style: GoogleFonts.afacad(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm khu vực mất tích...',
                          hintStyle: GoogleFonts.afacad(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF8B5CF6)),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (locationController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    locationController.clear();
                                    setState(() => searchResults.clear());
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.my_location, color: Color(0xFF8B5CF6)),
                                onPressed: () => _getCurrentLocationGPS(
                                  (lat, lon) {
                                    setState(() {
                                      selectedLat = lat;
                                      selectedLon = lon;
                                    });
                                    _reverseGeocodeLocation(lat, lon, (address) {
                                      locationController.text = address;
                                    });
                                  },
                                  (isLoading) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onSubmitted: (query) => _searchLocationGeoapify(
                          query,
                          (results) => setState(() => searchResults = results),
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Search results or loading
                    // Note: Loading state can be tracked in parent if needed
                    if (searchResults.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: searchResults.length,
                          itemBuilder: (context, i) {
                            final r = searchResults[i];
                            return ListTile(
                              leading: const Icon(Icons.location_on, color: Color(0xFF8B5CF6), size: 18),
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
                              onTap: () => setState(() {
                                locationController.text = r['formatted'];
                                selectedLat = r['lat'];
                                selectedLon = r['lon'];
                                searchResults.clear();
                              }),
                            );
                          },
                        ),
                      ),
                    
                    // Show coordinates if location selected
                    if (locationController.text.isNotEmpty && searchResults.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF8B5CF6), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tọa độ: ${selectedLat.toStringAsFixed(4)}, ${selectedLon.toStringAsFixed(4)}',
                                style: GoogleFonts.afacad(fontSize: 12, color: const Color(0xFF22223B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Description
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả chi tiết',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Nhập mô tả chi tiết' : null,
                    ),
                    const SizedBox(height: 12),
                    // Phone
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Nhập số điện thoại' : null,
                    ),
                    const SizedBox(height: 20),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final name = nameController.text.trim();
                            final type = selectedType;
                            final location = locationController.text.trim();
                            final description = descriptionController.text.trim();
                            final phone = phoneController.text.trim();
                            
                            try {
                              if (isEditing) {
                                // Update in Firebase
                                print('📝 [LostPetScreen] Updating lost pet post: ${editingPost['id']}');
                                await LostPetService.updateLostPetPost(
                                  editingPost['id'],
                                  {
                                    'pet_name': name,
                                    'pet_type': type,
                                    'lost_location': location,
                                    'distinguishing_features': description,
                                    'phone_number': phone,
                                  },
                                );
                                print('✅ [LostPetScreen] Lost pet post updated successfully');
                              } else {
                                // Create new post in Firebase
                                print('📝 [LostPetScreen] Creating new lost pet post');
                                String imageUrl = '';
                                
                                // Upload image if selected
                                if (selectedImage != null) {
                                  try {
                                    print('📸 [LostPetScreen] Uploading image to Cloudinary...');
                                    imageUrl = await CloudinaryService.uploadImage(
                                      selectedImage!,
                                      'lost_pets',
                                      fileName: '${type}_${DateTime.now().millisecondsSinceEpoch}',
                                    );
                                    print('✅ [LostPetScreen] Image uploaded: $imageUrl');
                                  } catch (e) {
                                    print('⚠️ [LostPetScreen] Image upload failed: $e');
                                    // Continue without image
                                  }
                                }
                                
                                final postId = await LostPetService.createLostPetPost(
                                  petName: name,
                                  petType: type,
                                  breed: 'Unknown',
                                  color: 'Unknown',
                                  distinguishingFeatures: description,
                                  imageUrl: imageUrl,
                                  lostDate: DateTime.now(),
                                  lostLocation: location,
                                  latitude: selectedLat,
                                  longitude: selectedLon,
                                  phoneNumber: phone,
                                );
                                print('✅ [LostPetScreen] Lost pet post created: $postId');
                              }
                              if (mounted) {
                                Navigator.pop(context);
                                await _loadFirebaseData();
                                _showSnackBar(isEditing ? '✅ Cập nhật thành công' : '✅ Đăng tin thành công');
                              }
                            } catch (e) {
                              print('❌ [LostPetScreen] Error: $e');
                              _showSnackBar('❌ Lỗi: $e');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isEditing ? 'Cập nhật' : 'Đăng tin',
                          style: GoogleFonts.afacad(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            );
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _copyToClipboard(String text, {bool phoneOnly = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(phoneOnly ? 'Đã sao chép số điện thoại' : 'Đã sao chép thông tin'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Thất lạc',
          style: GoogleFonts.afacad(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0
                                ? const Color(0xFF8B5CF6)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Tất cả',
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 0
                                ? const Color(0xFF8B5CF6)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1
                                ? const Color(0xFF8B5CF6)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Tin của tôi',
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 1
                                ? const Color(0xFF8B5CF6)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Posts list
          Expanded(
            child: _displayedPets.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có tin nào',
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _displayedPets.length,
                    itemBuilder: (context, index) {
                      final pet = _displayedPets[index];
                      final isMyPost = pet['userId'] == 'current_user';

                      return GestureDetector(
                        onTap: () => _showPetDetail(pet),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    pet['image'],
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet['name'],
                                      style: GoogleFonts.afacad(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${pet['type']} • ${pet['location']}',
                                      style: GoogleFonts.afacad(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Mất: ${pet['date']}',
                                      style: GoogleFonts.afacad(
                                        fontSize: 11,
                                        color: Colors.red,
                                      ),
                                    ),
                                    if (isMyPost)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 28,
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _showPostForm(editingPost: pet),
                                                icon: const Icon(Icons.edit,
                                                    size: 14),
                                                label: const Text('Sửa',
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF8B5CF6),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            SizedBox(
                                              height: 28,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  setState(() =>
                                                      _lostPets.remove(pet));
                                                  _showSnackBar(
                                                      'Đã xóa tin');
                                                },
                                                icon: const Icon(Icons.delete,
                                                    size: 14),
                                                label: const Text('Xóa',
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
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
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showPostForm(),
              backgroundColor: const Color(0xFF8B5CF6),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Đăng tin',
                style: GoogleFonts.afacad(fontWeight: FontWeight.bold, color: Colors.white),
              ),            
              )
          : null,
    );
  }

  void _showPetDetail(Map<String, dynamic> pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Image
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      pet['image'],
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pet['name'],
                  style: GoogleFonts.afacad(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Loại:', pet['type']),
                _buildDetailRow('Khu vực:', pet['location']),
                _buildDetailRow('Ngày mất:', pet['date']),
                const SizedBox(height: 12),
                Text(
                  'Mô tả:',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pet['description'],
                  style: GoogleFonts.afacad(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                // Contact section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liên hệ: ${pet['phone']}',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(pet['phone'] + ' - ${pet['name']}'),
                              icon: const Icon(Icons.content_copy),
                              label: const Text('Sao chép toàn bộ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(pet['phone'], phoneOnly: true),
                              icon: const Icon(Icons.phone),
                              label: const Text('Chỉ SĐT'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.afacad(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

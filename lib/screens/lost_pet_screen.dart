// lib/screens/lost_pet_screen.dart
// Tích hợp Firebase LostPetService và legacy support
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Map<String, dynamic>> _lostPets = [
    {
      'id': '1',
      'name': 'Mèo vàng Mimi',
      'type': 'Mèo',
      'location': 'Quận 1, TP.HCM',
      'lat': 10.7769,
      'lng': 106.6955,
      'date': '2024-11-20',
      'description': 'Mèo vàng mắt xanh, rất hiền. Mất từ hôm qua.',
      'phone': '0901234567',
      'image': '🐱',
      'userId': 'user1',
    },
    {
      'id': '2',
      'name': 'Chó Pug Coco',
      'type': 'Chó',
      'location': 'Quận 3, TP.HCM',
      'lat': 10.7892,
      'lng': 106.7041,
      'date': '2024-11-19',
      'description': 'Chó Pug màu đen, đeo vòng cổ đỏ. Rất thân thiện.',
      'phone': '0912345678',
      'image': '🐕',
      'userId': 'user2',
    },
    {
      'id': '3',
      'name': 'Chó Husky Max',
      'type': 'Chó',
      'location': 'Quận 7, TP.HCM',
      'lat': 10.7313,
      'lng': 106.7201,
      'date': '2024-11-18',
      'description': 'Chó Husky trắng xám. Mất tại công viên Tao Đàn.',
      'phone': '0923456789',
      'image': '🐕‍🦺',
      'userId': 'user3',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.useFirebase) {
      _loadFirebaseData();
    }
  }

  Future<void> _loadFirebaseData() async {
    try {
      final pets = await LostPetService.getLostPets();
      setState(() {
        _lostPets = pets;
      });
    } catch (e) {
      print('Lỗi tải dữ liệu: $e');
      _showSnackBar('Lỗi tải dữ liệu: $e');
    }
  }

  List<Map<String, dynamic>> get _myPosts {
    // Simulate user's own posts
    return _lostPets.where((pet) => pet['userId'] == 'current_user').toList();
  }

  List<Map<String, dynamic>> get _displayedPets {
    return _selectedTab == 0 ? _lostPets : _myPosts;
  }

  void _showPostForm({Map<String, dynamic>? editingPost}) {
    final isEditing = editingPost != null;
    final formKey = GlobalKey<FormState>();
    late String name, type, location, description, phone;

    if (isEditing) {
      name = editingPost['name'];
      type = editingPost['type'];
      location = editingPost['location'];
      description = editingPost['description'];
      phone = editingPost['phone'];
    }

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
        builder: (context, scrollController) => Padding(
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
                  // Pet name
                  TextFormField(
                    initialValue: isEditing ? editingPost['name'] : null,
                    decoration: InputDecoration(
                      labelText: 'Tên thú cưng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.pets),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Nhập tên thú cưng' : null,
                    onSaved: (v) => name = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  // Pet type
                  DropdownButtonFormField<String>(
                    value: isEditing ? editingPost['type'] : null,
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
                      DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                    ],
                    onChanged: (v) => type = v ?? '',
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Chọn loại thú cưng' : null,
                  ),
                  const SizedBox(height: 12),
                  // Location
                  TextFormField(
                    initialValue: isEditing ? editingPost['location'] : null,
                    decoration: InputDecoration(
                      labelText: 'Khu vực mất tích',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Nhập khu vực mất tích' : null,
                    onSaved: (v) => location = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  // Description
                  TextFormField(
                    initialValue:
                        isEditing ? editingPost['description'] : null,
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
                    onSaved: (v) => description = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  // Phone
                  TextFormField(
                    initialValue: isEditing ? editingPost['phone'] : null,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Nhập số điện thoại' : null,
                    onSaved: (v) => phone = v ?? '',
                  ),
                  const SizedBox(height: 20),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          
                          if (widget.useFirebase) {
                            try {
                              if (isEditing) {
                                // Update in Firebase
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
                              } else {
                                // Create new post in Firebase
                                await LostPetService.createLostPetPost(
                                  petName: name,
                                  petType: type,
                                  breed: 'Unknown',
                                  color: 'Unknown',
                                  distinguishingFeatures: description,
                                  imageUrl: '',
                                  lostDate: DateTime.now(),
                                  lostLocation: location,
                                  latitude: 10.7769,
                                  longitude: 106.6955,
                                  phoneNumber: phone,
                                );
                              }
                              if (mounted) {
                                Navigator.pop(context);
                                await _loadFirebaseData();
                                _showSnackBar(isEditing ? 'Cập nhật thành công' : 'Đăng tin thành công');
                              }
                            } catch (e) {
                              _showSnackBar('Lỗi: $e');
                            }
                          } else {
                            // Legacy mode - update local list
                            if (isEditing) {
                              editingPost['name'] = name;
                              editingPost['type'] = type;
                              editingPost['location'] = location;
                              editingPost['description'] = description;
                              editingPost['phone'] = phone;
                            } else {
                              _lostPets.add({
                                'id': DateTime.now().toString(),
                                'name': name,
                                'type': type,
                                'location': location,
                                'description': description,
                                'phone': phone,
                                'date': DateTime.now().toString(),
                                'image': type == 'Chó' ? '🐕' : '🐱',
                                'userId': 'current_user',
                                'lat': 10.7769,
                                'lng': 106.6955,
                              });
                            }
                            setState(() {});
                            Navigator.pop(context);
                            _showSnackBar(isEditing ? 'Cập nhật thành công' : 'Đăng tin thành công');
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
          ),
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
              icon: const Icon(Icons.add),
              label: Text(
                'Đăng tin',
                style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
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

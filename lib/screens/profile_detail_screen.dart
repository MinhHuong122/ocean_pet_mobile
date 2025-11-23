// lib/screens/profile_detail_screen.dart
// Firebase + Legacy Support
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/UserProfileService.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? avatarUrl;
  final Function(String, String, String?)? onUpdate;
  final bool useFirebase;

  const ProfileDetailScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.avatarUrl,
    this.onUpdate,
    this.useFirebase = false,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  String? localAvatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userName);
    phoneController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        localAvatarPath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E97FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông tin cá nhân',
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF8E97FD),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: localAvatarPath != null
                            ? FileImage(File(localAvatarPath!))
                            : (widget.avatarUrl != null &&
                                    widget.avatarUrl!.isNotEmpty
                                ? NetworkImage(widget.avatarUrl!)
                                : null) as ImageProvider?,
                        child: localAvatarPath == null &&
                                (widget.avatarUrl == null ||
                                    widget.avatarUrl!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Color(0xFF8E97FD),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 24,
                              color: Color(0xFF8E97FD),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chỉnh sửa ảnh đại diện',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: nameController,
                    label: 'Họ và tên',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  // Email field - display only (not editable)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.email, color: Color(0xFF8E97FD)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.userEmail ?? 'Chưa có email',
                                style: GoogleFonts.afacad(
                                  fontSize: 16,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: phoneController,
                    label: 'Số điện thoại',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: addressController,
                    label: 'Địa chỉ',
                    icon: Icons.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Vui lòng nhập họ tên'),
                              backgroundColor: Color(0xFFEF5350),
                            ),
                          );
                          return;
                        }

                        // Save to Firebase if enabled
                        if (widget.useFirebase) {
                          try {
                            print('🔄 [ProfileDetail] Saving to Firebase...');
                            print('  Name: ${nameController.text.trim()}');
                            print('  Phone: ${phoneController.text.trim()}');
                            print('  Address: ${addressController.text.trim()}');
                            
                            await UserProfileService.updateUserProfile(
                              name: nameController.text.trim(),
                              phoneNumber: phoneController.text.trim(),
                              address: addressController.text.trim(),
                            );
                            
                            print('✅ [ProfileDetail] Successfully saved to Firebase');
                            
                            if (mounted) {
                              // Call onUpdate callback to update parent screen
                              widget.onUpdate?.call(
                                nameController.text.trim(),
                                widget.userEmail ?? '',
                                localAvatarPath ?? widget.avatarUrl,
                              );
                              
                              Navigator.pop(context, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã cập nhật thông tin'),
                                  backgroundColor: Color(0xFF66BB6A),
                                ),
                              );
                            }
                          } catch (e) {
                            print('❌ [ProfileDetail] Error saving to Firebase: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: $e'),
                                  backgroundColor: Color(0xFFEF5350),
                                ),
                              );
                            }
                          }
                        } else {
                          // Legacy mode
                          widget.onUpdate?.call(
                            nameController.text.trim(),
                            widget.userEmail ?? '',
                            localAvatarPath ?? widget.avatarUrl,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã cập nhật thông tin'),
                              backgroundColor: Color(0xFF66BB6A),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E97FD),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Lưu thay đổi',
                        style: GoogleFonts.afacad(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.afacad(fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF8E97FD)),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF8E97FD),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

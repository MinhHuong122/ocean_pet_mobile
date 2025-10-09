// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Chủ của Mochi';
  String userEmail = 'mochi@oceanpet.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Cá Nhân',
                        style: GoogleFonts.aclonica(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Image.asset(
                        'lib/res/drawables/setting/LOGO.png',
                        width: 48,
                        height: 48,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Avatar and Info
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: const Color(0xFF8E97FD),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: const Color(0xFF8E97FD),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: GoogleFonts.afacad(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '3',
                        'Thú cưng',
                        Icons.pets,
                        const Color(0xFFFFB74D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '24',
                        'Hoạt động',
                        Icons.event_note,
                        const Color(0xFF64B5F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '5',
                        'Nhắc nhở',
                        Icons.notifications_active,
                        const Color(0xFF66BB6A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Menu Options
                Text(
                  'Cài đặt',
                  style: GoogleFonts.afacad(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 16),

                _buildMenuOption(
                  Icons.person_outline,
                  'Thông tin cá nhân',
                  'Chỉnh sửa hồ sơ của bạn',
                  () => _showEditProfileDialog(),
                ),
                _buildMenuOption(
                  Icons.pets,
                  'Quản lý thú cưng',
                  'Thêm hoặc chỉnh sửa thông tin thú cưng',
                  () => _showPetManagementDialog(),
                ),
                _buildMenuOption(
                  Icons.notifications_outlined,
                  'Thông báo',
                  'Cài đặt nhắc nhở và thông báo',
                  () => _showNotificationSettings(),
                ),
                _buildMenuOption(
                  Icons.security,
                  'Bảo mật',
                  'Thay đổi mật khẩu và cài đặt bảo mật',
                  () => _showSecuritySettings(),
                ),
                _buildMenuOption(
                  Icons.language,
                  'Ngôn ngữ',
                  'Tiếng Việt',
                  () {},
                ),
                _buildMenuOption(
                  Icons.help_outline,
                  'Trợ giúp & Hỗ trợ',
                  'Câu hỏi thường gặp và liên hệ',
                  () {},
                ),
                _buildMenuOption(
                  Icons.info_outline,
                  'Về ứng dụng',
                  'Phiên bản 1.0.0',
                  () {},
                ),
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF5350),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Đăng xuất',
                          style: GoogleFonts.afacad(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.afacad(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8E97FD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8E97FD),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.afacad(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.afacad(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFFBDBDBD),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Đăng xuất',
            style: GoogleFonts.afacad(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: GoogleFonts.afacad(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: GoogleFonts.afacad(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout logic
              },
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.afacad(
                  color: const Color(0xFFEF5350),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa thông tin',
              style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  style: GoogleFonts.afacad(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  style: GoogleFonts.afacad(),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userName = nameController.text;
                  userEmail = emailController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã cập nhật thông tin'),
                    backgroundColor: Color(0xFF66BB6A),
                  ),
                );
              },
              child: Text('Lưu',
                  style: GoogleFonts.afacad(
                      color: Color(0xFF8E97FD), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPetManagementDialog() {
    final List<Map<String, dynamic>> pets = [
      {
        'name': 'Mochi',
        'type': 'Mèo Ba Tư',
        'age': '2 tuổi',
        'icon': Icons.pets
      },
      {
        'name': 'Lucky',
        'type': 'Chó Golden',
        'age': '3 tuổi',
        'icon': Icons.pets
      },
      {
        'name': 'Kitty',
        'type': 'Mèo Anh lông ngắn',
        'age': '1 tuổi',
        'icon': Icons.pets
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quản lý thú cưng',
              style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF8E97FD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(pet['icon'], color: Color(0xFF8E97FD)),
                    title: Text(pet['name'],
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pet['type']} • ${pet['age']}',
                        style: GoogleFonts.afacad()),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Edit pet details
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Add new pet dialog
                _showAddPetDialog();
              },
              child: Text('Thêm mới',
                  style: GoogleFonts.afacad(
                      color: Color(0xFF66BB6A), fontWeight: FontWeight.bold)),
            ),
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

  void _showAddPetDialog() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm thú cưng mới',
              style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên thú cưng',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.pets),
                  ),
                  style: GoogleFonts.afacad(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Giống loài',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    hintText: 'VD: Mèo Ba Tư, Chó Golden',
                  ),
                  style: GoogleFonts.afacad(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: 'Tuổi',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    hintText: 'VD: 2 tuổi',
                  ),
                  style: GoogleFonts.afacad(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập tên thú cưng')),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm ${nameController.text}'),
                    backgroundColor: Color(0xFF66BB6A),
                  ),
                );
              },
              child: Text('Thêm',
                  style: GoogleFonts.afacad(
                      color: Color(0xFF8E97FD), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationSettings() {
    bool dailyReminder = true;
    bool appointmentReminder = true;
    bool feedingReminder = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Cài đặt thông báo',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title:
                        Text('Nhắc nhở hàng ngày', style: GoogleFonts.afacad()),
                    subtitle: Text('Nhắc chăm sóc thú cưng mỗi ngày',
                        style: GoogleFonts.afacad(fontSize: 12)),
                    value: dailyReminder,
                    activeColor: Color(0xFF8E97FD),
                    onChanged: (value) {
                      setDialogState(() {
                        dailyReminder = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('Nhắc lịch hẹn', style: GoogleFonts.afacad()),
                    subtitle: Text('Nhắc trước 1 ngày',
                        style: GoogleFonts.afacad(fontSize: 12)),
                    value: appointmentReminder,
                    activeColor: Color(0xFF8E97FD),
                    onChanged: (value) {
                      setDialogState(() {
                        appointmentReminder = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('Nhắc cho ăn', style: GoogleFonts.afacad()),
                    subtitle: Text('Nhắc giờ cho ăn',
                        style: GoogleFonts.afacad(fontSize: 12)),
                    value: feedingReminder,
                    activeColor: Color(0xFF8E97FD),
                    onChanged: (value) {
                      setDialogState(() {
                        feedingReminder = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã lưu cài đặt thông báo'),
                        backgroundColor: Color(0xFF66BB6A),
                      ),
                    );
                  },
                  child: Text('Lưu',
                      style: GoogleFonts.afacad(
                          color: Color(0xFF8E97FD),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSecuritySettings() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thay đổi mật khẩu',
              style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  style: GoogleFonts.afacad(),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  style: GoogleFonts.afacad(),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    labelStyle: GoogleFonts.afacad(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  style: GoogleFonts.afacad(),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mật khẩu xác nhận không khớp'),
                      backgroundColor: Color(0xFFEF5350),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thay đổi mật khẩu thành công'),
                    backgroundColor: Color(0xFF66BB6A),
                  ),
                );
              },
              child: Text('Lưu',
                  style: GoogleFonts.afacad(
                      color: Color(0xFF8E97FD), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

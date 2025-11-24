// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ocean_pet/services/AuthService.dart';
import 'package:ocean_pet/services/FirebaseService.dart';
import 'package:ocean_pet/services/UserProfileService.dart';
import 'package:ocean_pet/services/QuickLoginService.dart';
import './custom_bottom_nav.dart';
import 'login_screen.dart';
import 'quick_login_screen.dart';
import 'profile_detail_screen.dart';
import 'pet_management_screen.dart';
import 'help_support_screen.dart';
import 'about_app_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Chủ của Mochi';
  String userEmail = 'mochi@oceanpet.com';
  String? avatarUrl;
  bool isLoading = true;
  
  // Stats data
  int petCount = 0;
  int activityCount = 0;
  int reminderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats khi quay lại màn hình
    _loadStats();
  }

  Future<void> _loadStats() async {
    print('🔄 Loading stats...');
    
    int pets = 0;
    int activities = 0;
    int reminders = 0;
    
    // Load pet count
    try {
      final petList = await FirebaseService.getPets();
      pets = petList.length;
      print('🐾 Pets loaded: $pets');
    } catch (e) {
      print('❌ Error loading pets: $e');
    }
    
    // Load activity count (appointments + diary entries)
    try {
      await FirebaseService.getUserAppointments().first.then((appointments) {
        activities = appointments.length;
        print('📅 Activities loaded: $activities');
      });
    } catch (e) {
      print('❌ Error loading activities: $e');
    }
    
    // Load reminder count from diary entries (SharedPreferences)
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString('diary_entries');
      
      if (entriesJson != null) {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        final now = DateTime.now();
        
        // Count entries with active (future) reminders
        for (final entry in decoded) {
          final reminderDateTime = entry['reminderDateTime'];
          if (reminderDateTime != null && reminderDateTime.isNotEmpty) {
            try {
              final reminder = DateTime.parse(reminderDateTime);
              if (reminder.isAfter(now)) {
                reminders++;
              }
            } catch (e) {
              // Invalid date format, skip
            }
          }
        }
      }
      print('🔔 Reminders from diary loaded: $reminders');
    } catch (e) {
      print('❌ Error loading diary reminders: $e');
    }
    
    // Update state với dữ liệu đã load được
    if (mounted) {
      setState(() {
        petCount = pets;
        activityCount = activities;
        reminderCount = reminders;
      });
      print('Stats updated: Pets=$petCount, Activities=$activityCount, Reminders=$reminderCount');
    }
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Lấy thông tin từ Firebase Firestore (user profile)
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Lấy profile từ Firestore
        final userProfile = await UserProfileService.getUserProfile();
        
        if (userProfile != null) {
          // Load from Firestore user profile
          setState(() {
            userName = userProfile['name'] ?? firebaseUser.displayName ?? 'Người dùng';
            userEmail = userProfile['email'] ?? firebaseUser.email ?? '';
            avatarUrl = userProfile['avatar_url'] ?? firebaseUser.photoURL;
            isLoading = false;
          });
          print('✅ [ProfileScreen] User profile loaded from Firestore');
        } else {
          // Fallback to Firebase Auth if no Firestore profile
          setState(() {
            userName = firebaseUser.displayName ?? 'Người dùng';
            userEmail = firebaseUser.email ?? '';
            avatarUrl = firebaseUser.photoURL;
            isLoading = false;
          });
          print('⚠️ [ProfileScreen] Using Firebase Auth data (no Firestore profile)');
        }
      } else {
        // User đăng nhập qua email/password, lấy từ MySQL
        final result = await AuthService.getUserInfo();

        if (result['success']) {
          final user = result['user'];
          setState(() {
            userName = user['name'] ?? 'Người dùng';
            userEmail = user['email'] ?? '';
            avatarUrl = user['avatarUrl'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Lỗi load user info: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8E97FD),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                // ...existing code...

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
                            backgroundImage:
                                avatarUrl != null && avatarUrl!.isNotEmpty
                                    ? NetworkImage(avatarUrl!)
                                    : null,
                            child: avatarUrl == null || avatarUrl!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: const Color(0xFF8E97FD),
                                  )
                                : null,
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
                        '$petCount',
                        'Thú cưng',
                        Icons.pets,
                        const Color(0xFFFFB74D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '$activityCount',
                        'Hoạt động',
                        Icons.event_note,
                        const Color(0xFF64B5F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '$reminderCount',
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
                  () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileDetailScreen(
                          useFirebase: true,
                          userName: userName,
                          userEmail: userEmail,
                          avatarUrl: avatarUrl,
                          onUpdate: (newName, newEmail, newAvatar) {
                            setState(() {
                              userName = newName;
                              userEmail = newEmail;
                              avatarUrl = newAvatar;
                            });
                          },
                        ),
                      ),
                    );
                    
                    // Reload user info from Firebase if update was successful
                    if (result == true) {
                      print('📝 [ProfileScreen] Update successful, reloading user info...');
                      await _loadUserInfo();
                    }
                  },
                ),
                _buildMenuOption(
                  Icons.pets,
                  'Quản lý thú cưng',
                  'Thêm hoặc chỉnh sửa thông tin thú cưng',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PetManagementScreen(),
                      ),
                    );
                  },
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
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuOption(
                  Icons.info_outline,
                  'Về ứng dụng',
                  'Phiên bản 1.0.0',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutAppScreen(),
                      ),
                    );
                  },
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
          backgroundColor: Colors.white,
          title: Text(
            'Đăng xuất',
            style: GoogleFonts.afacad(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: GoogleFonts.afacad(color: Colors.black),
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
              onPressed: () async {
                Navigator.of(context).pop();

                // Logout immediately
                await AuthService.logout();
                
                // Clear quick login credentials
                try {
                  await QuickLoginService.clearCredentials();
                  print('✅ [Logout] Quick login credentials cleared');
                } catch (e) {
                  print('❌ [Logout] Error clearing quick login credentials: $e');
                }

                // Navigate back - check if user has logged in before
                if (context.mounted) {
                  print('[Logout] Redirecting user...');
                  
                  // Check if user has logged in before (has saved credentials)
                  final hasLoggedInBefore = await QuickLoginService.hasLoggedInBefore();
                  
                  if (hasLoggedInBefore) {
                    // Go to QuickLoginScreen
                    print('[Logout] Going to QuickLoginScreen');
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const QuickLoginScreen()),
                        (route) => false,
                      );
                    }
                  } else {
                    // Go to LoginScreen (first time)
                    print('[Logout] Going to LoginScreen');
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                }
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

  void _showNotificationSettings() async {
    // Load notification settings from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    bool notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    bool appointmentReminder = prefs.getBool('appointment_reminder') ?? true;
    bool diaryReminder = prefs.getBool('diary_reminder') ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.notifications_active,
                      color: Color(0xFF8E97FD)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cài đặt thông báo',
                      style: GoogleFonts.afacad(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Master notification toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEF5350).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Bật/Tắt thông báo toàn bộ app',
                        style: GoogleFonts.afacad(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      subtitle: Text(
                        'Áp dụng cho toàn bộ ứng dụng',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      value: notificationsEnabled,
                      activeThumbColor: const Color(0xFF66BB6A),
                      activeTrackColor: const Color(0xFF66BB6A).withOpacity(0.5),
                      inactiveThumbColor: const Color(0xFFBDBDBD),
                      onChanged: (value) {
                        setDialogState(() {
                          notificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  
                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      color: const Color(0xFF8E97FD).withOpacity(0.2),
                      thickness: 1,
                    ),
                  ),
                  
                  // Individual notification settings (only enabled if master is on)
                  Opacity(
                    opacity: notificationsEnabled ? 1.0 : 0.5,
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Thông báo lịch hẹn',
                          subtitle: 'Nhắc trước 1 ngày khi có lịch khám, tiêm chủng...',
                          value: appointmentReminder && notificationsEnabled,
                          onChanged: notificationsEnabled
                              ? (value) {
                                  setDialogState(() {
                                    appointmentReminder = value;
                                  });
                                }
                              : null,
                        ),
                        _buildSwitchTile(
                          title: 'Thông báo nhắc nhở',
                          subtitle: 'Nhắc nhở từ các mục trong nhật ký',
                          value: diaryReminder && notificationsEnabled,
                          onChanged: notificationsEnabled
                              ? (value) {
                                  setDialogState(() {
                                    diaryReminder = value;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.afacad(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Save settings to SharedPreferences
                    await prefs.setBool('notifications_enabled', notificationsEnabled);
                    await prefs.setBool('appointment_reminder', appointmentReminder);
                    await prefs.setBool('diary_reminder', diaryReminder);
                    
                    print('✅ [Notification Settings] Saved:');
                    print('   - Notifications enabled: $notificationsEnabled');
                    print('   - Appointment reminder: $appointmentReminder');
                    print('   - Diary reminder: $diaryReminder');
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã lưu cài đặt thông báo'),
                          backgroundColor: const Color(0xFF66BB6A),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E97FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lưu',
                    style: GoogleFonts.afacad(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8E97FD).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.afacad(
            fontWeight: FontWeight.bold,
            color: onChanged != null ? const Color(0xFF22223B) : const Color(0xFF22223B).withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.afacad(
            fontSize: 12,
            color: onChanged != null ? const Color(0xFF6B7280) : const Color(0xFF6B7280).withOpacity(0.5),
          ),
        ),
        value: value,
        activeThumbColor: const Color(0xFF8E97FD),
        activeTrackColor: const Color(0xFF8E97FD).withOpacity(0.5),
        inactiveThumbColor: const Color(0xFFBDBDBD),
        onChanged: onChanged,
      ),
    );
  }

  void _showSecuritySettings() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.lock, color: Color(0xFF8E97FD)),
                  const SizedBox(width: 12),
                  Text(
                    'Thay đổi mật khẩu',
                    style: GoogleFonts.afacad(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 350,
                  maxWidth: 420,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại',
                          labelStyle: GoogleFonts.afacad(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFF8E97FD)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF8E97FD),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.afacad(),
                        obscureText: obscureCurrent,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          labelStyle: GoogleFonts.afacad(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Color(0xFF8E97FD)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF8E97FD),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.afacad(),
                        obscureText: obscureNew,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu mới',
                          labelStyle: GoogleFonts.afacad(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_clock,
                              color: Color(0xFF8E97FD)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF8E97FD),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.afacad(),
                        obscureText: obscureConfirm,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy',
                      style: GoogleFonts.afacad(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (currentPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin'),
                          backgroundColor: Color(0xFFEF5350),
                        ),
                      );
                      return;
                    }
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
                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E97FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lưu',
                    style: GoogleFonts.afacad(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

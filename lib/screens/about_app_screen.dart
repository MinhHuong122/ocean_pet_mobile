// lib/screens/about_app_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

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
          'Về ứng dụng',
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF8E97FD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'lib/res/drawables/setting/LOGO.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ocean Pet',
                    style: GoogleFonts.aclonica(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phiên bản 1.0.0',
                    style: GoogleFonts.afacad(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giới thiệu',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8E97FD).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Ocean Pet là ứng dụng quản lý thú cưng toàn diện, giúp bạn chăm sóc và theo dõi sức khỏe của người bạn bốn chân một cách dễ dàng. Với các tính năng thông minh và giao diện thân thiện, Ocean Pet là người bạn đồng hành đáng tin cậy trong hành trình nuôi dưỡng thú cưng.',
                      style: GoogleFonts.afacad(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tính năng nổi bật',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.pets,
                    title: 'Quản lý thú cưng',
                    description:
                        'Lưu trữ thông tin chi tiết về thú cưng của bạn',
                    color: const Color(0xFFFFB74D),
                  ),
                  _buildFeatureItem(
                    icon: Icons.calendar_today,
                    title: 'Lịch hẹn khám bệnh',
                    description: 'Đặt lịch và nhận nhắc nhở khám bệnh định kỳ',
                    color: const Color(0xFF64B5F6),
                  ),
                  _buildFeatureItem(
                    icon: Icons.menu_book,
                    title: 'Nhật ký chăm sóc',
                    description: 'Ghi chép quá trình chăm sóc hàng ngày',
                    color: const Color(0xFF66BB6A),
                  ),
                  _buildFeatureItem(
                    icon: Icons.smart_toy,
                    title: 'Trợ lý AI',
                    description: 'Tư vấn chăm sóc thú cưng với AI thông minh',
                    color: const Color(0xFF8E97FD),
                  ),
                  _buildFeatureItem(
                    icon: Icons.notifications_active,
                    title: 'Nhắc nhở thông minh',
                    description: 'Nhận thông báo về lịch hẹn và chăm sóc',
                    color: const Color(0xFFEF5350),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Team Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhóm phát triển',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8E97FD),
                          const Color(0xFF8E97FD).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Đại học Hùng Vương',
                          style: GoogleFonts.afacad(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đồ án chuyên ngành - Năm 4',
                          style: GoogleFonts.afacad(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const Divider(
                          color: Colors.white54,
                          height: 32,
                        ),
                        _buildTeamMember('Đỗ Nguyễn Minh Hương', 'Developer'),
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact & Social
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kết nối với chúng tôi',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        color: const Color(0xFF1877F2),
                        onTap: () => _openURL('https://facebook.com/oceanpet'),
                      ),
                      _buildSocialButton(
                        icon: Icons.language,
                        label: 'Website',
                        color: const Color(0xFF8E97FD),
                        onTap: () => _openURL('https://oceanpet.com'),
                      ),
                      _buildSocialButton(
                        icon: Icons.email,
                        label: 'Email',
                        color: const Color(0xFFEF5350),
                        onTap: () => _sendEmail('info@oceanpet.com'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Legal & Privacy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildLegalLink('Điều khoản sử dụng', () {}),
                  const SizedBox(height: 8),
                  _buildLegalLink('Chính sách bảo mật', () {}),
                  const SizedBox(height: 8),
                  _buildLegalLink('Giấy phép mã nguồn mở', () {}),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Copyright
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '© 2024 Ocean Pet',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with ❤️ in Vietnam',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.afacad(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.afacad(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.afacad(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.description, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _openURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Liên hệ về Ocean Pet App',
    );
    await launchUrl(launchUri);
  }
}

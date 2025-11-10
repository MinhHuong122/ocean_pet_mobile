// lib/screens/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

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
          'Trợ giúp & Hỗ trợ',
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF8E97FD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chúng tôi có thể giúp gì cho bạn?',
                    style: GoogleFonts.afacad(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liên hệ nhanh',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          icon: Icons.phone,
                          label: 'Gọi điện',
                          color: const Color(0xFF66BB6A),
                          onTap: () => _makePhoneCall('+84123456789'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          icon: Icons.email,
                          label: 'Email',
                          color: const Color(0xFF64B5F6),
                          onTap: () => _sendEmail('support@oceanpet.com'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          icon: Icons.chat,
                          label: 'Chat AI',
                          color: const Color(0xFFFFB74D),
                          onTap: () {
                            // Navigate to AI chat
                            Navigator.pushNamed(context, '/ai_chat');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // FAQ Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Câu hỏi thường gặp',
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'Làm thế nào để thêm thú cưng mới?',
                    answer:
                        'Vào mục "Quản lý thú cưng" trên trang cá nhân, sau đó nhấn nút "Thêm mới" để thêm thông tin thú cưng của bạn.',
                  ),
                  _buildFAQItem(
                    question: 'Làm sao để đặt lịch hẹn khám bệnh?',
                    answer:
                        'Vào tab "Lịch", chọn ngày muốn đặt lịch, sau đó nhấn nút "+" để tạo cuộc hẹn mới. Điền đầy đủ thông tin và lưu lại.',
                  ),
                  _buildFAQItem(
                    question: 'Tôi quên mật khẩu, phải làm sao?',
                    answer:
                        'Tại màn hình đăng nhập, nhấn "Quên mật khẩu?". Nhập email của bạn và làm theo hướng dẫn được gửi qua email.',
                  ),
                  _buildFAQItem(
                    question: 'Làm thế nào để bật thông báo nhắc nhở?',
                    answer:
                        'Vào "Cài đặt" > "Thông báo" trên trang cá nhân. Bật các tùy chọn nhắc nhở mà bạn muốn nhận.',
                  ),
                  _buildFAQItem(
                    question: 'Ứng dụng có miễn phí không?',
                    answer:
                        'Ocean Pet hoàn toàn miễn phí với đầy đủ tính năng quản lý thú cưng, lịch hẹn, nhắc nhở và nhiều hơn nữa!',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                      Icons.support_agent,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cần hỗ trợ thêm?',
                      style: GoogleFonts.afacad(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Liên hệ với chúng tôi qua:',
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(Icons.phone, '+84 123 456 789'),
                    const SizedBox(height: 8),
                    _buildContactInfo(Icons.email, 'support@oceanpet.com'),
                    const SizedBox(height: 8),
                    _buildContactInfo(
                        Icons.access_time, 'T2-T7: 8:00 - 18:00'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question,
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8E97FD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.help_outline,
              color: Color(0xFF8E97FD),
              size: 20,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.afacad(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Yêu cầu hỗ trợ từ Ocean Pet App',
    );
    await launchUrl(launchUri);
  }
}

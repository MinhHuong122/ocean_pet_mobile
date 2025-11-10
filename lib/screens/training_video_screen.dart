// lib/screens/training_video_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TrainingVideoScreen extends StatefulWidget {
  const TrainingVideoScreen({super.key});

  @override
  State<TrainingVideoScreen> createState() => _TrainingVideoScreenState();
}

class _TrainingVideoScreenState extends State<TrainingVideoScreen> {
  final List<Map<String, dynamic>> trainingVideos = [
    {
      'title': 'Huấn luyện cơ bản cho chó',
      'url': 'https://www.youtube.com/watch?v=vwGr1GAQ7Xg',
      'thumbnail': Icons.play_circle,
      'duration': '15:30',
      'description': 'Hướng dẫn các lệnh cơ bản: ngồi, nằm, đứng yên',
      'level': 'Cơ bản',
    },
    {
      'title': 'Huấn luyện chó nghe lời',
      'url': 'https://www.youtube.com/watch?v=4dbzPoB7AKk',
      'thumbnail': Icons.play_circle,
      'duration': '20:15',
      'description': 'Dạy chó nghe lời chủ và tuân theo mệnh lệnh',
      'level': 'Trung cấp',
    },
    {
      'title': 'Huấn luyện mèo',
      'url': 'https://www.youtube.com/watch?v=T0xzdu-wTM0',
      'thumbnail': Icons.play_circle,
      'duration': '12:45',
      'description': 'Cách huấn luyện mèo cưng thông minh',
      'level': 'Cơ bản',
    },
    {
      'title': 'Huấn luyện chó đi vệ sinh đúng chỗ',
      'url': 'https://www.youtube.com/watch?v=qKnMxZjn6fI',
      'thumbnail': Icons.play_circle,
      'duration': '18:20',
      'description': 'Dạy chó đi vệ sinh đúng nơi quy định',
      'level': 'Cơ bản',
    },
    {
      'title': 'Kỹ năng xã hội cho thú cưng',
      'url': 'https://www.youtube.com/watch?v=example1',
      'thumbnail': Icons.play_circle,
      'duration': '22:10',
      'description': 'Giúp thú cưng giao tiếp tốt với người và động vật khác',
      'level': 'Nâng cao',
    },
    {
      'title': 'Huấn luyện chó nhặt đồ',
      'url': 'https://www.youtube.com/watch?v=example2',
      'thumbnail': Icons.play_circle,
      'duration': '16:40',
      'description': 'Dạy chó nhặt đồ vật và đưa cho chủ',
      'level': 'Trung cấp',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Video huấn luyện',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFFEF5350)),
            onPressed: _showDonateDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trainingVideos.length,
        itemBuilder: (context, index) {
          final video = trainingVideos[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openVideo(video['url']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAB47BC), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      video['thumbnail'],
                      color: Colors.white,
                      size: 48,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video['duration'],
                          style: GoogleFonts.afacad(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video['description'],
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(video['level']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video['level'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getLevelColor(video['level']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Cơ bản':
        return const Color(0xFF66BB6A);
      case 'Trung cấp':
        return const Color(0xFFFFB74D);
      case 'Nâng cao':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF8E97FD);
    }
  }

  Future<void> _openVideo(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể mở video',
                style: GoogleFonts.afacad(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e', style: GoogleFonts.afacad()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDonateDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ủng hộ chúng tôi',
                  style: GoogleFonts.afacad(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cảm ơn bạn đã ủng hộ để chúng tôi có thể tạo ra nhiều video huấn luyện hữu ích hơn!',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // QR Code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8E97FD).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: 'https://qr.momo.vn/1234567890',
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Quét mã QR để chuyển khoản',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          color: const Color(0xFF22223B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Bank Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Ngân hàng', 'MoMo'),
                      const Divider(),
                      _buildInfoRow('Số tài khoản', '0123456789'),
                      const Divider(),
                      _buildInfoRow('Tên', 'OCEAN PET CARE'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Donate Options
                Text(
                  'Hoặc chọn số tiền:',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDonateButton('10.000đ'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDonateButton('50.000đ'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDonateButton('100.000đ'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E97FD),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Đóng',
                      style: GoogleFonts.afacad(
                        fontSize: 16,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.afacad(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
      ],
    );
  }

  Widget _buildDonateButton(String amount) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cảm ơn bạn đã ủng hộ $amount!',
              style: GoogleFonts.afacad(),
            ),
            backgroundColor: const Color(0xFF66BB6A),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF5350),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        amount,
        style: GoogleFonts.afacad(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

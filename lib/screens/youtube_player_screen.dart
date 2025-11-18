// lib/screens/youtube_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  const YoutubePlayerScreen({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
  });

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  void _initializePlayer() {
    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            showLiveFullscreenButton: true,
            hideControls: false,
            hideThumbnail: false,
          ),
        );
        _controller.addListener(_listener);
        if (mounted) {
          setState(() {
            _isPlayerReady = true;
          });
        }
      } else {
        if (mounted) {
          _showError('Video ID không hợp lệ');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Lỗi khi khởi tạo player: $e');
      }
    }
  }

  void _listener() {
    if (_isPlayerReady && mounted && _controller.value.isFullScreen) {
      setState(() {});
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.afacad()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.videoTitle,
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: _isPlayerReady
          ? Column(
              children: [
                // YouTube Player
                YoutubePlayerBuilder(
                  onExitFullScreen: () {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                  },
                  player: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFF8B5CF6),
                    progressColors: const ProgressBarColors(
                      playedColor: Color(0xFF8B5CF6),
                      handleColor: Color(0xFFEF5350),
                    ),
                    onEnded: (data) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Video đã kết thúc ✓',
                            style: GoogleFonts.afacad(),
                          ),
                          backgroundColor: const Color(0xFF66BB6A),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  builder: (context, player) => player,
                ),
                // Info section
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: const Color(0xFF22223B),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.videoTitle,
                            style: GoogleFonts.afacad(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E97FD).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF8E97FD),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Nhấn vào video để xem toàn màn hình',
                                    style: GoogleFonts.afacad(
                                      color: const Color(0xFF8E97FD),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hướng dẫn phát video:',
                            style: GoogleFonts.afacad(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTip('🎬', 'Nhấn nút phát để bắt đầu'),
                          _buildTip('⏸️', 'Nhấn để tạm dừng'),
                          _buildTip('📺', 'Vuốt để thay đổi độ sáng và âm lượng'),
                          _buildTip('⛔', 'Vuốt phải để tua nhanh, trái để tua lại'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF8E97FD),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải video...',
                    style: GoogleFonts.afacad(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.afacad(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

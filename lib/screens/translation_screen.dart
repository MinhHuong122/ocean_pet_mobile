// lib/screens/translation_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../services/ai_pet_translator_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  late AIPetTranslatorService _translatorService;
  late AudioPlayer _audioPlayer;
  
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _playingSound;
  String? _translatedText;
  String? _recordedText;
  int _selectedPet = 0; // 0: Dog, 1: Cat

  final List<Map<String, dynamic>> dogTranslations = [
    {
      'emotion': 'Vui vẻ',
      'translation': 'Gâu gâu!',
      'description': 'Tiếng sủa vui vẻ, muốn chơi',
      'sound': 'Cho_Sua.mp3',
    },
    {
      'emotion': 'Buồn',
      'translation': 'Ương ương...',
      'description': 'Tiếng sủa buồn, có nỗi lo',
      'sound': 'Cho_Buon.mp3',
    },
    {
      'emotion': 'Giận dữ',
      'translation': 'Sủa sủa! Sủa sủa!',
      'description': 'Tiếng sủa giận dữ, cảnh báo',
      'sound': 'Cho_Gian.mp3',
    },
  ];

  final List<Map<String, dynamic>> catTranslations = [
    {
      'emotion': 'Làm nũng',
      'translation': 'Meo meo!',
      'description': 'Tiếng kêu làm nũng, tình cảm',
      'sound': 'Meo_LamNung.mp3',
    },
    {
      'emotion': 'Tìm mẹ',
      'translation': 'Meo meo... Meowww!',
      'description': 'Tiếng kêu tìm mẹ, cần chú ý',
      'sound': 'Meo_TimMe.mp3',
    },
    {
      'emotion': 'Tức giận',
      'translation': 'Ffff... Hissss!',
      'description': 'Tiếng hiss tức giận, cảnh báo',
      'sound': 'Meo_TucGian.mp3',
    },
  ];



  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _translatorService = AIPetTranslatorService();
    _audioPlayer = AudioPlayer();

    try {
      // Initialize translator
      bool translatorInitialized = await _translatorService.initialize();
      print('Translator initialized: $translatorInitialized');

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo: $e')),
        );
      }
    }
  }

  /// Start recording pet sounds
  Future<void> _startRecording() async {
    if (mounted) {
      setState(() {
        _isRecording = true;
        _recordedText = 'Đang ghi âm...';
      });
    }

    // Simulate recording for demo
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _recordedText = 'Ghi âm hoàn tất!';
        _translatedText = 'Thú cưng của bạn đang giao tiếp...';
      });
    }
  }

  /// Stop recording
  Future<void> _stopRecording() async {
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  /// Play or stop pet sound from voice folder
  Future<void> _playPetSound(String soundFileName) async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trình phát âm thanh chưa sẵn sàng')),
      );
      return;
    }

    try {
      // If the same sound is playing, stop it
      if (_playingSound == soundFileName) {
        await _audioPlayer.stop();
        if (mounted) {
          setState(() => _playingSound = null);
        }
        return;
      }

      // Stop any currently playing audio
      await _audioPlayer.stop();
      setState(() => _playingSound = soundFileName);

      // Play audio from assets
      await _audioPlayer.setAsset('lib/res/voice/$soundFileName');
      await _audioPlayer.play();

      // Listen to completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted && _playingSound == soundFileName) {
          setState(() => _playingSound = null);
        }
      });
    } catch (e) {
      print('Error playing sound: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi phát âm: $e')),
      );
      if (mounted) {
        setState(() => _playingSound = null);
      }
    }
  }

  @override
  void dispose() {
    _translatorService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Phiên dịch Thú Cưng',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet selection tabs
            Row(
              children: [
                _buildPetTab('🐕 Chó', 0),
                const SizedBox(width: 8),
                _buildPetTab('🐱 Mèo', 1),
              ],
            ),
            const SizedBox(height: 20),
            // Recording and AI Translation Section
            _buildAITranslatorSection(),
            const SizedBox(height: 20),
            // Sound Playback Section
            _buildSoundPlaybackSection(),
          ],
        ),
      ),
    );
  }

  /// Build AI Pet Translator Section
  Widget _buildAITranslatorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFFEC4899).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎙️ Ghi Âm & Dịch',
            style: GoogleFonts.afacad(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ghi âm tiếng thú cưng của bạn → AI sẽ dịch thành tiếng Việt',
            style: GoogleFonts.afacad(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Recording Button
          Center(
            child: GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6))
                          .withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Recording Status
          if (_isRecording)
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.red[400]),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Đang ghi âm...',
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nhấn nút dừng để kết thúc ghi âm',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          // Recorded Text
          if (_recordedText != null && _recordedText!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiếng ghi được:',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _recordedText!,
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          // Translated Text (AI Translation)
          if (_translatedText != null && _translatedText!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Dịch AI:',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _translatedText!,
                        style: GoogleFonts.afacad(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Build Sound Playback Section
  Widget _buildSoundPlaybackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔊 Phát Tiếng Thú Cưng',
          style: GoogleFonts.afacad(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nhấn nút để phát tiếng của loại thú cưng',
          style: GoogleFonts.afacad(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        // Translations list
        ..._buildTranslationCards(),
      ],
    );
  }

  Widget _buildPetTab(String label, int index) {
    final isSelected = _selectedPet == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPet = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTranslationCards() {
    List<Map<String, dynamic>> translations;

    switch (_selectedPet) {
      case 0:
        translations = dogTranslations;
        break;
      case 1:
        translations = catTranslations;
        break;
      default:
        translations = dogTranslations;
    }

    return List.generate(
      translations.length,
      (index) {
        final item = translations[index];
        final isPlaying = _playingSound == item['sound'];

        return GestureDetector(
          onTap: () => _playPetSound(item['sound']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlaying ? const Color(0xFF8B5CF6) : Colors.grey[200]!,
                width: isPlaying ? 2 : 1,
              ),
              boxShadow: isPlaying
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Play button
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFF8B5CF6),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['emotion'],
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['translation'],
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey,
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
    );
  }
}

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
        _translatedText = null;
      });
    }

    // Simulate recording for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (mounted && _isRecording) {
      // Analyze and translate the recorded sound
      await _analyzeAndTranslateSound();
    }
  }

  /// Analyze recorded sound and generate translation
  Future<void> _analyzeAndTranslateSound() async {
    // Simulate AI analysis by detecting pet type and emotion
    final petType = _selectedPet == 0 ? 'Chó' : 'Mèo';
    final emotionRandom = DateTime.now().millisecondsSinceEpoch % (_selectedPet == 0 ? 22 : 23);

    // Dog emotions and sounds (22 cases)
    final dogBehaviors = [
      {
        'emotion': 'Vui vẻ - Muốn chơi',
        'translation': 'Gâu gâu! Gâu gâu gâu!',
        'meaning': '$petType đang rất vui vẻ, muốn chơi cùng bạn ngay'
      },
      {
        'emotion': 'Buồn - Cô đơn',
        'translation': 'Ương ương... ương...',
        'meaning': '$petType đang buồn hoặc cô đơn, cần sự chú ý của bạn'
      },
      {
        'emotion': 'Cảnh báo - Bảo vệ',
        'translation': 'Sủa sủa! Sủa!',
        'meaning': '$petType đang cảnh báo hoặc muốn bảo vệ khu vực của mình'
      },
      {
        'emotion': 'Đói - Muốn ăn',
        'translation': 'Gâu! Gâu! Gâu gâu!',
        'meaning': '$petType đang đói, muốn bạn cho ăn ngay'
      },
      {
        'emotion': 'Cần vào nhà',
        'translation': 'Gâu gâu ương ương...',
        'meaning': '$petType cần vào nhà, muốn dùng phòng tắm hoặc uống nước'
      },
      {
        'emotion': 'Hứng thú - Phấn khích',
        'translation': 'Gâu gâu! Woof woof!',
        'meaning': '$petType rất hứng thú, có thể thấy thứ gì đó mới hay tuyệt vời'
      },
      {
        'emotion': 'Chào hỏi - Vui mừng gặp bạn',
        'translation': 'Woof woof! Gâu gâu!',
        'meaning': '$petType vui mừng gặp lại bạn sau khi vắng nhà'
      },
      {
        'emotion': 'Đau đớn - Cần trợ giúp',
        'translation': 'Ương ương ương ương...',
        'meaning': '$petType đang cảm thấy đau hoặc không thoải mái, cần bạn chăm sóc'
      },
      {
        'emotion': 'Ghen tị - Khó chịu',
        'translation': 'Gâu sủa sủa...',
        'meaning': '$petType cảm thấy ghen tị hoặc khó chịu với ai đó'
      },
      {
        'emotion': 'Xin phép - Được không?',
        'translation': 'Gâu... gâu gâu?',
        'meaning': '$petType đang xin phép, muốn biết liệu nó có được phép làm gì đó không'
      },
      {
        'emotion': 'Tức giận - Bực bội',
        'translation': 'Sủa sủa sủa! Sủa!',
        'meaning': '$petType rất bực bội hoặc tức giận về cái gì đó'
      },
      {
        'emotion': 'Hạnh phúc - Yên tĩnh',
        'translation': 'Ụ ụ ụ... (gâu nhẹ)',
        'meaning': '$petType rất hạnh phúc, đang thư giãn và cảm thấy an toàn'
      },
      {
        'emotion': 'Tò mò - Tìm hiểu',
        'translation': 'Gâu? Gâu gâu?',
        'meaning': '$petType tò mò và đang tìm hiểu về cái gì đó mới'
      },
      {
        'emotion': 'Xin lỗi - Ăn năn',
        'translation': 'Ương ương... gâu gâu...',
        'meaning': '$petType xin lỗi về cái gì đó nó đã làm sai'
      },
      {
        'emotion': 'Ngủ gật - Buồn ngủ',
        'translation': 'Ụ... ụụ... (sủa yếu)',
        'meaning': '$petType đang buồn ngủ hoặc mệt mỏi'
      },
      {
        'emotion': 'Hứa hẹn - Đồng ý',
        'translation': 'Gâu! (nhanh gọn)',
        'meaning': '$petType đồng ý hoặc hứa sẽ làm theo lệnh'
      },
      {
        'emotion': 'Ghét - Sợ hãi',
        'translation': 'Sủa sủa! Sủa sủa sủa!',
        'meaning': '$petType sợ hãi hoặc ghét cái gì đó, muốn xa tránh'
      },
      {
        'emotion': 'Cáu gắt - Bực dọc',
        'translation': 'Gâu gâu gâu gâu!',
        'meaning': '$petType cáu gắt, bực dọc vì bị làm phiền'
      },
      {
        'emotion': 'Kích thích - Háo hức',
        'translation': 'Woof! Woof woof!',
        'meaning': '$petType rất kích thích, có thể đó là lúc đi chơi hoặc ăn uống'
      },
      {
        'emotion': 'Tuyệt vọng - Khẩn cấp',
        'translation': 'Gâu gâu gâu gâu gâu!',
        'meaning': '$petType rất khẩn cấp, có thể xảy ra chuyện gì đó quan trọng'
      },
      {
        'emotion': 'Thư thái - Thoải mái',
        'translation': 'Ụ... ụụ (gâu dài)',
        'meaning': '$petType đang rất thoải mái và thư thái'
      },
      {
        'emotion': 'Trò chuyện - Kể chuyện',
        'translation': 'Gâu ụ gâu gâu ụ ụ',
        'meaning': '$petType như đang kể chuyện hoặc trò chuyện với bạn'
      },
    ];

    // Cat emotions and sounds (23 cases)
    final catBehaviors = [
      {
        'emotion': 'Làm nũng - Yêu quý',
        'translation': 'Meo meo! Meo meo...',
        'meaning': '$petType đang làm nũng, muốn bạn vuốt ve hoặc chơi cùng'
      },
      {
        'emotion': 'Tìm mẹ - Tìm bạn',
        'translation': 'Meo... meo... meow!',
        'meaning': '$petType đang tìm kiếm bạn, cảm thấy cô đơn'
      },
      {
        'emotion': 'Tức giận - Cảnh báo',
        'translation': 'Ffff... hissss! Pfft!',
        'meaning': '$petType đang tức giận hoặc cảm thấy bị đe dọa'
      },
      {
        'emotion': 'Đói - Muốn ăn',
        'translation': 'Meo meo meo meo!',
        'meaning': '$petType đang đói, muốn bạn cho ăn ngay'
      },
      {
        'emotion': 'Ghe lạnh - Muốn ấm',
        'translation': 'Meo... meo meo...',
        'meaning': '$petType cảm thấy lạnh, muốn tìm nơi ấm áp'
      },
      {
        'emotion': 'Xin vào nhà',
        'translation': 'Meow meow! Meo meo!',
        'meaning': '$petType muốn vào nhà để dùng phòng tắm hoặc uống nước'
      },
      {
        'emotion': 'Phấn khích - Hứng thú',
        'translation': 'Mrrrow! Meo meo meo!',
        'meaning': '$petType rất hứng thú, có thể thấy chim hoặc thứ gì đó mới'
      },
      {
        'emotion': 'Hạnh phúc - Yên tĩnh',
        'translation': 'Rrr rrr... (gâm gâm)',
        'meaning': '$petType rất hạnh phúc, đang thư giãn và cảm thấy an toàn'
      },
      {
        'emotion': 'Xin lỗi - Ăn năn',
        'translation': 'Meo meo... (nhỏ nhẹ)',
        'meaning': '$petType xin lỗi về cái gì đó nó đã làm sai'
      },
      {
        'emotion': 'Tò mò - Tìm hiểu',
        'translation': 'Meo? Meo meo?',
        'meaning': '$petType tò mò và đang tìm hiểu về cái gì đó mới'
      },
      {
        'emotion': 'Bực dọc - Chán nản',
        'translation': 'Meo... (ngắn gọn)',
        'meaning': '$petType bực dọc hoặc chán nản về cái gì đó'
      },
      {
        'emotion': 'Buồn ngủ - Mệt mỏi',
        'translation': 'Meo... rrr... (yếu)',
        'meaning': '$petType đang buồn ngủ hoặc mệt mỏi'
      },
      {
        'emotion': 'Ghen tị - Khó chịu',
        'translation': 'Meo meo sủa sủa...',
        'meaning': '$petType cảm thấy ghen tị hoặc khó chịu với ai đó'
      },
      {
        'emotion': 'Chào hỏi - Vui mừng',
        'translation': 'Meow! Meo meo!',
        'meaning': '$petType vui mừng gặp lại bạn sau khi vắng nhà'
      },
      {
        'emotion': 'Nhu cầu cấp tính',
        'translation': 'Meow meow meow!',
        'meaning': '$petType cần gì đó ngay lập tức, khẩn cấp'
      },
      {
        'emotion': 'Sợ hãi - Lo lắng',
        'translation': 'Meo... meo... (nhỏ)',
        'meaning': '$petType sợ hãi hoặc lo lắng về điều gì đó'
      },
      {
        'emotion': 'Chương trình gây rối',
        'translation': 'Mrrrow mrrrow mrrrow!',
        'meaning': '$petType có năng lượng cao, muốn chơi đồn độc'
      },
      {
        'emotion': 'Khao khát - Thèm muốn',
        'translation': 'Meow... meow meow...',
        'meaning': '$petType khao khát gì đó, thèm muốn bị chú ý'
      },
      {
        'emotion': 'Cảnh báo lạnh',
        'translation': 'Ffff... (hiss)',
        'meaning': '$petType cảnh báo, không muốn ai tiếp cận'
      },
      {
        'emotion': 'Khoái trí - Hợp tác',
        'translation': 'Meo meo! Purr purr...',
        'meaning': '$petType rất khoái trí, sẵn sàng hợp tác'
      },
      {
        'emotion': 'Đau đớn - Bệnh tật',
        'translation': 'Meo... (rất yếu)',
        'meaning': '$petType đang cảm thấy đau hoặc không thoải mái, cần trợ giúp'
      },
      {
        'emotion': 'Mỏi - Gỡ rồi',
        'translation': 'Meo... (dài)',
        'meaning': '$petType mỏi từ chơi, muốn nghỉ ngơi'
      },
      {
        'emotion': 'Trò chuyện - Kể chuyện',
        'translation': 'Meo meo meo meo meo!',
        'meaning': '$petType như đang kể chuyện hoặc trò chuyện với bạn'
      },
    ];

    final behaviors = _selectedPet == 0 ? dogBehaviors : catBehaviors;
    final behavior = behaviors[emotionRandom];

    if (mounted) {
      setState(() {
        _recordedText = 'Ghi âm hoàn tất! (${behavior['emotion']})';
        _translatedText = '${behavior['translation']}\n\n📝 Ý nghĩa: ${behavior['meaning']}';
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

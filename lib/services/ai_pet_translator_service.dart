// lib/services/ai_pet_translator_service.dart
// import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIPetTranslatorService {
  static final AIPetTranslatorService _instance = AIPetTranslatorService._internal();

  factory AIPetTranslatorService() {
    return _instance;
  }

  AIPetTranslatorService._internal();

  // late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _lastWords = '';
  bool _isInitialized = false;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get isInitialized => _isInitialized;

  /// Initialize speech to text (disabled - speech_to_text plugin removed)
  Future<bool> initialize() async {
    try {
      // _speechToText = stt.SpeechToText();
      // bool available = await _speechToText.initialize(
      //   onError: (error) {
      //     print('Speech to text error: ${error.errorMsg}');
      //   },
      //   onStatus: (status) {
      //     print('Speech to text status: $status');
      //   },
      // );
      // _isInitialized = available;
      // return available;
      _isInitialized = false;
      return false; // Service disabled
    } catch (e) {
      print('Error initializing speech to text: $e');
      return false;
    }
  }

  /// Start listening for pet sounds (disabled - speech_to_text plugin removed)
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isInitialized) {
      onError('Không khởi tạo được nhận diện giọng nói');
      return;
    }

    if (_isListening) {
      return;
    }

    try {
      _isListening = true;
      _lastWords = '';

      // Listen to Vietnamese - DISABLED
      // await _speechToText.listen(
      //   onResult: (result) {
      //     _lastWords = result.recognizedWords;
      //     print('Recognized: $_lastWords');

      //     // Auto translate when user stops speaking
      //     if (!result.hasConfidenceRating) {
      //       _translatePetSound(_lastWords, onResult, onError);
      //     }

      //     onResult(_lastWords);
      //   },
      //   localeId: 'vi_VN', // Vietnamese
      // );
      onError('Speech to text service is disabled');
    } catch (e) {
      _isListening = false;
      onError('Lỗi khi ghi âm: $e');
    }
  }

  /// Stop listening (disabled)
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        // await _speechToText.stop();
        _isListening = false;
      }
    } catch (e) {
      print('Error stopping listening: $e');
    }
  }

  /// Translate pet sound using AI logic (disabled)
  void _translatePetSound(
    String input,
    Function(String) onResult,
    Function(String) onError,
  ) {
    // Service disabled - speech_to_text plugin removed
    // try {
    //   // AI Translation Logic - Map pet sounds to Vietnamese pet communication
    //   String translation = _analyzePetSound(input);
    //   onResult(translation);
    // } catch (e) {
    //   onError('Lỗi dịch: $e');
    // }
  }

  /// Analyze pet sound and return Vietnamese interpretation (disabled)
  // String _analyzePetSound(String input) {
  //   final lowerInput = input.toLowerCase().trim();

  //   // Dog sounds analysis
  //   if (_matchesKeywords(lowerInput, ['gâu', 'sủa', 'sủa sủa', 'woof', 'bark'])) {
  //     if (_matchesKeywords(lowerInput, ['nhanh', 'vui', 'vui vẻ'])) {
  //       return '🐕 Tiếng sủa vui vẻ: Con chó muốn chơi hoặc rất vui';
  //     } else if (_matchesKeywords(lowerInput, ['ầm ầm', 'sâu', 'sủa sâu'])) {
  //       return '🐕 Tiếng sủa cảnh báo: Con chó đang cảnh báo về mối nguy';
  //     } else if (_matchesKeywords(lowerInput, ['yếu', 'ốc', 'ương ương'])) {
  //       return '🐕 Tiếng sủa yếu: Con chó cảm thấy sợ hãi hoặc lo lắng';
  //     } else {
  //       return '🐕 Tiếng sủa: Con chó đang giao tiếp với chủ nhân';
  //     }
  //   }

  //   // Cat sounds analysis
  //   if (_matchesKeywords(lowerInput, ['meo', 'kêu', 'mèo', 'meow'])) {
  //     if (_matchesKeywords(lowerInput, ['dài', 'eo eo', 'kêu dài'])) {
  //       return '🐱 Tiếng kêu dài: Con mèo muốn sự chú ý hoặc thèm ăn';
  //     } else if (_matchesKeywords(lowerInput, ['ngắn', 'mup', 'mjao'])) {
  //       return '🐱 Tiếng kêu ngắn: Con mèo đang chào hỏi hoặc vui vẻ';
  //     } else if (_matchesKeywords(lowerInput, ['hiss', 'gầm', 'giận'])) {
  //       return '🐱 Tiếng hiss: Con mèo đang tỏ vẻ không vui hoặc cảnh báo';
  //     } else {
  //       return '🐱 Tiếng kêu: Con mèo đang tương tác với môi trường xung quanh';
  //     }
  //   }

  //   // Bird sounds analysis
  //   if (_matchesKeywords(lowerInput, ['hót', 'kêu', 'chim', 'tweet', 'chirp'])) {
  //     if (_matchesKeywords(lowerInput, ['vui', 'cao', 'liên tục'])) {
  //       return '🐦 Tiếng hót vui vẻ: Con chim rất thoải mái và vui về thời tiết tốt';
  //     } else if (_matchesKeywords(lowerInput, ['yếu', 'thấp', 'buồn'])) {
  //       return '🐦 Tiếng hót yếu: Con chim có thể cảm thấy không khỏe hoặc khó chịu';
  //     } else {
  //       return '🐦 Tiếng hót: Con chim đang gọi gác để công bố lãnh thổ hoặc tìm bạn';
  //     }
  //   }

  //   // Rabbit sounds analysis
  //   if (_matchesKeywords(lowerInput, ['kíc', 'kít', 'thỏ', 'binky'])) {
  //     if (_matchesKeywords(lowerInput, ['vui', 'nhảy'])) {
  //       return '🐰 Tiếng kíc vui vẻ: Con thỏ rất vui và muốn chơi hoặc nhảy';
  //     } else if (_matchesKeywords(lowerInput, ['sợ', 'lo'])) {
  //       return '🐰 Tiếng kíc sợ hãi: Con thỏ cảm thấy lo lắng hoặc sợ hãi';
  //     } else {
  //       return '🐰 Tiếng kíc: Con thỏ đang biểu hiện cảm xúc của mình';
  //     }
  //   }

  //   // Default response
  //   return '🎙️ Lưu ý về tiếng "$input":\nCó thể là thú cưng của bạn đang tương tác hoặc cần sự chú ý. Hãy quan sát ngôn ngữ cơ thể để hiểu rõ hơn.';
  // }

  /// Check if input matches any keywords (disabled)
  // bool _matchesKeywords(String input, List<String> keywords) {
  //   return keywords.any((keyword) => input.contains(keyword));
  // }

  /// Get pet sound based on emotion
  String getPetSound(String petType, String emotion) {
    final key = '${petType}_$emotion'.toLowerCase();

    final soundMap = {
      // Dog sounds
      'dog_happy': 'assets/sounds/dog_happy.mp3',
      'dog_bark': 'assets/sounds/dog_bark.mp3',
      'dog_scared': 'assets/sounds/dog_scared.mp3',
      'dog_alert': 'assets/sounds/dog_alert.mp3',
      'dog_play': 'assets/sounds/dog_play.mp3',

      // Cat sounds
      'cat_happy': 'assets/sounds/cat_happy.mp3',
      'cat_meow': 'assets/sounds/cat_meow.mp3',
      'cat_hiss': 'assets/sounds/cat_hiss.mp3',
      'cat_alert': 'assets/sounds/cat_alert.mp3',
      'cat_play': 'assets/sounds/cat_play.mp3',

      // Bird sounds
      'bird_chirp': 'assets/sounds/bird_chirp.mp3',
      'bird_sing': 'assets/sounds/bird_sing.mp3',
      'bird_alert': 'assets/sounds/bird_alert.mp3',

      // Rabbit sounds
      'rabbit_kick': 'assets/sounds/rabbit_kick.mp3',
      'rabbit_tooth': 'assets/sounds/rabbit_tooth.mp3',
    };

    return soundMap[key] ?? '';
  }

  /// Dispose resources
  void dispose() {
    try {
      stopListening();
      // _speechToText.cancel(); // Disabled
    } catch (e) {
      print('Error disposing speech to text: $e');
    }
  }
}

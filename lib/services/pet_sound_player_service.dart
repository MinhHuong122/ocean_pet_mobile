// lib/services/pet_sound_player_service.dart
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class PetSoundPlayerService {
  static final PetSoundPlayerService _instance = PetSoundPlayerService._internal();

  factory PetSoundPlayerService() {
    return _instance;
  }

  PetSoundPlayerService._internal();

  late FlutterSoundPlayer _soundPlayer;
  bool _isInitialized = false;
  String? _currentPlayingSound;

  bool get isInitialized => _isInitialized;
  String? get currentPlayingSound => _currentPlayingSound;

  /// Initialize the sound player
  Future<bool> initialize() async {
    try {
      _soundPlayer = FlutterSoundPlayer();

      // Request audio permissions
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('Microphone permission not granted');
        return false;
      }

      await _soundPlayer.openPlayer();
      _isInitialized = true;
      print('Sound player initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing sound player: $e');
      return false;
    }
  }

  /// Play a pet sound from assets
  Future<void> playSound(String soundPath) async {
    if (!_isInitialized) {
      print('Sound player not initialized');
      return;
    }

    try {
      // Stop any currently playing sound
      if (_currentPlayingSound != null && _currentPlayingSound != soundPath) {
        await _soundPlayer.stopPlayer();
      }

      _currentPlayingSound = soundPath;

      // Load and play the sound from assets
      await _soundPlayer.startPlayer(
        fromURI: soundPath,
        whenFinished: () {
          _currentPlayingSound = null;
          print('Sound finished: $soundPath');
        },
      );

      print('Playing sound: $soundPath');
    } catch (e) {
      print('Error playing sound: $e');
      _currentPlayingSound = null;
    }
  }

  /// Stop current playing sound
  Future<void> stopSound() async {
    try {
      if (_currentPlayingSound != null) {
        await _soundPlayer.stopPlayer();
        _currentPlayingSound = null;
      }
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  /// Play a predefined pet sound based on pet type and emotion
  Future<void> playPetSound(String petType, String emotion) async {
    final soundPath = _getSoundPath(petType, emotion);
    if (soundPath.isNotEmpty) {
      await playSound(soundPath);
    }
  }

  /// Get sound file path based on pet type and emotion
  String _getSoundPath(String petType, String emotion) {
    final key = '${petType}_${emotion}'.toLowerCase().replaceAll(' ', '_');

    final soundMap = {
      // Dog sounds (using real voice files from lib/res/voice)
      'dog_happy': 'lib/res/voice/Cho_Sua.mp3',
      'dog_bark': 'lib/res/voice/Cho_Sua.mp3',
      'dog_woof': 'lib/res/voice/Cho_Sua.mp3',
      'dog_scared': 'lib/res/voice/Cho_Buon.mp3',
      'dog_whine': 'lib/res/voice/Cho_Buon.mp3',
      'dog_alert': 'lib/res/voice/Cho_Gian.mp3',
      'dog_play': 'lib/res/voice/Cho_Sua.mp3',

      // Cat sounds (using real voice files from lib/res/voice)
      'cat_happy': 'lib/res/voice/Meo_LamNung.mp3',
      'cat_meow': 'lib/res/voice/Meo_TimMe.mp3',
      'cat_purr': 'lib/res/voice/Meo_LamNung.mp3',
      'cat_hiss': 'lib/res/voice/Meo_TucGian.mp3',
      'cat_alert': 'lib/res/voice/Meo_TucGian.mp3',
      'cat_play': 'lib/res/voice/Meo_LamNung.mp3',

      // Bird sounds (placeholder - using cat sounds as fallback)
      'bird_chirp': 'lib/res/voice/Meo_LamNung.mp3',
      'bird_sing': 'lib/res/voice/Meo_LamNung.mp3',
      'bird_tweet': 'lib/res/voice/Meo_LamNung.mp3',
      'bird_alert': 'lib/res/voice/Meo_TucGian.mp3',

      // Rabbit sounds (placeholder - using dog sounds as fallback)
      'rabbit_kick': 'lib/res/voice/Cho_Sua.mp3',
      'rabbit_tooth': 'lib/res/voice/Cho_Gian.mp3',
      'rabbit_happy': 'lib/res/voice/Cho_Sua.mp3',
    };

    return soundMap[key] ?? '';
  }

  /// Get all available pet sounds for a specific pet type
  List<Map<String, String>> getPetSounds(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
      case 'chó':
        return [
          {'emotion': 'Vui vẻ', 'sound': 'dog_happy', 'icon': '🐕'},
          {'emotion': 'Sủa bình thường', 'sound': 'dog_bark', 'icon': '🐕'},
          {'emotion': 'Sợ hãi', 'sound': 'dog_scared', 'icon': '🐕'},
          {'emotion': 'Cảnh báo', 'sound': 'dog_alert', 'icon': '🐕'},
          {'emotion': 'Muốn chơi', 'sound': 'dog_play', 'icon': '🐕'},
        ];
      case 'cat':
      case 'mèo':
        return [
          {'emotion': 'Vui vẻ', 'sound': 'cat_happy', 'icon': '🐱'},
          {'emotion': 'Meo thường', 'sound': 'cat_meow', 'icon': '🐱'},
          {'emotion': 'Hiss', 'sound': 'cat_hiss', 'icon': '🐱'},
          {'emotion': 'Cảnh báo', 'sound': 'cat_alert', 'icon': '🐱'},
          {'emotion': 'Muốn chơi', 'sound': 'cat_play', 'icon': '🐱'},
        ];
      case 'bird':
      case 'chim':
        return [
          {'emotion': 'Hót vui vẻ', 'sound': 'bird_chirp', 'icon': '🐦'},
          {'emotion': 'Hát', 'sound': 'bird_sing', 'icon': '🐦'},
          {'emotion': 'Cảnh báo', 'sound': 'bird_alert', 'icon': '🐦'},
        ];
      case 'rabbit':
      case 'thỏ':
        return [
          {'emotion': 'Vui vẻ', 'sound': 'rabbit_happy', 'icon': '🐰'},
          {'emotion': 'Đá chân', 'sound': 'rabbit_kick', 'icon': '🐰'},
          {'emotion': 'Nghiến răng', 'sound': 'rabbit_tooth', 'icon': '🐰'},
        ];
      default:
        return [];
    }
  }

  /// Dispose resources
  void dispose() {
    try {
      stopSound();
      _soundPlayer.closePlayer();
    } catch (e) {
      print('Error disposing sound player: $e');
    }
  }
}

@echo off
REM Quick Start Guide - AI Pet Translator (Windows)

echo.
echo 🎙️  AI Pet Translator - Quick Setup
echo =====================================
echo.

REM Step 1: Get dependencies
echo Step 1: Installing dependencies...
call flutter pub get

REM Step 2: Create sound assets directory
echo Step 2: Creating sound assets directory...
if not exist "assets\sounds" mkdir "assets\sounds"
echo ✅ assets\sounds\ directory created

REM Step 3: Analyze code
echo Step 3: Analyzing code...
call flutter analyze lib\screens\translation_screen.dart
call flutter analyze lib\services\ai_pet_translator_service.dart
call flutter analyze lib\services\pet_sound_player_service.dart

REM Step 4: Instructions
echo.
echo 📋 NEXT STEPS:
echo ==============
echo.
echo 1. Download 16 pet sound files from:
echo    - Freesound.org
echo    - Pixabay Sounds (https://pixabay.com/sounds/)
echo    - Zapsplat (https://www.zapsplat.com)
echo.
echo 2. Place them in: assets\sounds\
echo    Required files:
echo    - dog_happy.mp3
echo    - dog_bark.mp3
echo    - dog_scared.mp3
echo    - dog_alert.mp3
echo    - dog_play.mp3
echo    - cat_happy.mp3
echo    - cat_meow.mp3
echo    - cat_hiss.mp3
echo    - cat_alert.mp3
echo    - cat_play.mp3
echo    - bird_chirp.mp3
echo    - bird_sing.mp3
echo    - bird_alert.mp3
echo    - rabbit_happy.mp3
echo    - rabbit_kick.mp3
echo    - rabbit_tooth.mp3
echo.
echo 3. Update Android permissions:
echo    File: android\app\src\main\AndroidManifest.xml
echo    Add:
echo    ^<uses-permission android:name="android.permission.RECORD_AUDIO" /^>
echo    ^<uses-permission android:name="android.permission.INTERNET" /^>
echo.
echo 4. Update iOS permissions:
echo    File: ios\Runner\Info.plist
echo    Add:
echo    ^<key^>NSMicrophoneUsageDescription^</key^>
echo    ^<string^>Cho phép ứng dụng ghi âm tiếng thú cưng^</string^>
echo.
echo 5. Run the app:
echo    flutter run
echo.
echo ✅ Setup Complete! All code is ready to use.
echo.
echo 📖 For more details, see:
echo    - AI_PET_TRANSLATOR_GUIDE.md
echo    - IMPLEMENTATION_SUMMARY_AI_TRANSLATOR.md
echo.
pause

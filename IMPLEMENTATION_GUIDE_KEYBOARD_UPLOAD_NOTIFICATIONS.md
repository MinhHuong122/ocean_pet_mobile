# 📱 Ocean Pet Mobile - Implementation Guides
**2025 Updated Best Practices for Flutter**

---

## 🎯 Part 1: Fix Keyboard Overlay Issues (Pixel Problem)

### Problem Description
When keyboard appears on input screens (community, dating, diary, etc.), content gets pushed up causing pixel overflow or ui jitter.

### Solutions Applied ✅

#### 1. **Keyboard Utility Helper** (`lib/helpers/keyboard_utils.dart`)
- Provides `KeyboardAwareScaffold` - automatically handles keyboard padding
- Includes `buildInputField()` helper for consistent TextFormField styling
- `KeyboardAwareDialog` for input dialogs that don't get hidden by keyboard

#### 2. **Implementation in Your Screens**

**Before (❌ Pixel Issues):**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Column(...),
    ),
  );
}
```

**After (✅ Fixed):**
```dart
@override
Widget build(BuildContext context) {
  return KeyboardAwareScaffold(
    appBar: AppBar(...),
    body: Column(...),
  );
}
```

#### 3. **Key Screens to Fix**
- ✅ `community_screen.dart` - Post creation dialog
- ✅ `dating_messages_screen.dart` - Message input
- ✅ `diary_screen.dart` - Entry creation
- ✅ `events_screen.dart` - Event creation
- ✅ `training_screen.dart` - Training log input

#### 4. **Manual Fix Steps for Each Screen**
```dart
import 'package:ocean_pet/helpers/keyboard_utils.dart';

// 1. For Scaffold with TextFormField:
resizeToAvoidBottomInset: true // Add this to Scaffold

// 2. For SingleChildScrollView with input:
SingleChildScrollView(
  reverse: true,  // Add this
  child: Column(
    children: [
      // your widgets
    ],
  ),
)

// 3. For dialogs with input:
showDialog(
  context: context,
  builder: (_) => KeyboardAwareDialog(
    title: "Tiêu đề",
    hintText: "Nhập nội dung",
    onSubmit: (value) {
      // handle submission
    },
    onCancel: () {
      // handle cancel
    },
  ),
);
```

---

## 🎵 Part 2: Image Upload Verification (Cloudinary)

### Current Setup ✅
- **Service**: `lib/services/CloudinaryService.dart`
- **Package**: `cloudinary_public: ^0.21.0`, `cloudinary_api: ^1.1.1`
- **Config**: `lib/services/CloudinaryConfig.dart`

### Screens Using Image Upload
1. **Community Posts** - `community_screen.dart`
2. **Dating Profile** - Thêm ảnh hồ sơ
3. **Diary Entries** - Upload photo diary
4. **Pet Profile** - `create_pet_profile_screen.dart`, `edit_pet_profile_screen.dart`
5. **News/Events** - Upload event images

### Verification Checklist

#### ✅ Check CloudinaryConfig
```dart
// lib/services/CloudinaryConfig.dart
const String CLOUDINARY_CLOUD_NAME = 'your_cloud_name';
const String CLOUDINARY_UPLOAD_PRESET = 'your_preset';
const String CLOUDINARY_API_KEY = 'your_api_key';
```

#### ✅ Check CloudinaryService Methods
- `uploadImage()` - Single image upload
- `uploadImages()` - Multiple images
- `deleteImage()` - Remove from cloud
- `getImageUrl()` - Get secure URL

#### ✅ Check Image Upload in Screens
```dart
// Example: community_screen.dart
try {
  String imageUrl = await CloudinaryService.uploadImage(
    imageFile: selectedImage,
    folder: 'community_posts',
  );
  print("✅ Image uploaded: $imageUrl");
} catch (e) {
  print("❌ Upload failed: $e");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Lỗi tải ảnh: $e')),
  );
}
```

#### ✅ Common Upload Issues & Fixes

**Issue 1: "Invalid API Key"**
- Verify CLOUDINARY_API_KEY in CloudinaryConfig.dart
- Check upload preset is public or authenticated

**Issue 2: "Network error"**
- Check internet connection
- Verify firebaseOptions.dart is configured
- Check AndroidManifest.xml has INTERNET permission

**Issue 3: "File too large"**
- Compress image before upload
- Add size validation:
```dart
if (imageFile.lengthSync() > 10 * 1024 * 1024) { // 10MB limit
  throw Exception('Ảnh quá lớn (tối đa 10MB)');
}
```

**Issue 4: "Upload hangs/timeout"**
- Add timeout:
```dart
String imageUrl = await CloudinaryService.uploadImage(
  imageFile: selectedImage,
  folder: 'community_posts',
).timeout(
  const Duration(seconds: 30),
  onTimeout: () => throw Exception('Upload timeout'),
);
```

---

## 🔔 Part 3: FCM Push Notifications Setup

### What's New ✅
- **Service**: `lib/services/fcm_notification_service.dart` (NEW!)
- **Packages Added**: 
  - `firebase_messaging: ^15.1.3`
  - `flutter_local_notifications: ^17.2.3`
- **Main Integration**: `lib/main.dart` (UPDATED!)

### Quick Start (5 minutes)

#### Step 1: Initialize FCM in main.dart ✅ (Already Done!)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Initialize FCM
  final fcmService = FCMNotificationService();
  await fcmService.initialize();
  
  // Get FCM Token
  String? token = await fcmService.getFCMToken();
  print("FCM Token: $token");

  runApp(MyApp());
}
```

#### Step 2: Setup Notification Listeners ✅ (Already Done in AuthWrapper!)
```dart
void _setupFCMListeners() {
  final fcmService = FCMNotificationService();

  // Foreground messages
  fcmService.listenForForegroundMessages((message) {
    print("Message received: ${message.notification?.title}");
  });

  // Notification taps
  fcmService.listenForMessageOpenedApp((message) {
    print("Notification tapped: ${message.data}");
    _handleNotificationTap(message);
  });
}
```

#### Step 3: Send Notifications Using Helpers
```dart
import 'package:ocean_pet/services/fcm_notification_service.dart';

// 📅 Appointment Reminder
await NotificationHelper.sendAppointmentReminder(
  petName: 'Bánh Bao',
  appointmentType: 'Tiêm chủng dại',
  appointmentDate: DateTime(2025, 12, 15),
);

// ❤️ Health Alert
await NotificationHelper.sendHealthNotification(
  petName: 'Mít',
  healthAlert: 'Cân nặng tăng 0.5kg, cần kiểm soát ăn uống',
);

// 🎉 Event Notification
await NotificationHelper.sendEventNotification(
  eventName: 'Hội chợ thú cưng',
  eventDescription: 'Có ưu đãi 50% cho các dịch vụ chăm sóc',
  eventDate: DateTime(2025, 12, 20, 14, 0),
);

// 🐾 Lost Pet Alert
await NotificationHelper.sendLostPetNotification(
  petName: 'Bánh Bao',
  location: 'Quận 7, TP.HCM',
  description: 'Chó Shiba đỏ, tên gọi Bánh Bao',
);

// 💬 Community Post
await NotificationHelper.sendCommunityNotification(
  postTitle: 'Chia sẻ kinh nghiệm chăm sóc vật nuôi',
  userName: 'Nguyễn Thái',
);

// ⏰ Daily Reminder
await NotificationHelper.sendDailyReminder(
  petName: 'Bánh Bao',
  reminderType: 'cho ăn',
);
```

### Integration Points for Your Screens

#### 1. **Appointment Screen** (Lịch khám)
```dart
// appointment_detail_screen.dart
Future<void> _scheduleAppointment() async {
  // ... save appointment ...
  
  await NotificationHelper.sendAppointmentReminder(
    petName: petName,
    appointmentType: 'Khám sức khỏe',
    appointmentDate: appointmentDate,
  );
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('✅ Lịch hẹn đã được lưu. Sẽ nhận nhắc nhở!')),
  );
}
```

#### 2. **Health Score Screen** (Đánh giá sức khỏe)
```dart
// Gửi thông báo khi có cảnh báo sức khỏe
if (healthScore < 50) {
  await NotificationHelper.sendHealthNotification(
    petName: pet.name,
    healthAlert: '⚠️ Chỉ số sức khỏe thấp. Vui lòng kiểm tra ngay!',
  );
}
```

#### 3. **Events Screen** (Sự kiện)
```dart
// events_screen.dart - Khi tạo event
Future<void> _createEvent() async {
  // ... save event ...
  
  await NotificationHelper.sendEventNotification(
    eventName: eventTitle,
    eventDescription: eventDescription,
    eventDate: eventDate,
  );
}
```

#### 4. **Lost Pet Screen** (Thú cưng thất lạc)
```dart
// lost_pet_screen.dart
Future<void> _reportLostPet() async {
  // ... save lost pet report ...
  
  // Notify community
  await NotificationHelper.sendLostPetNotification(
    petName: petName,
    location: location,
    description: petDescription,
  );
}
```

#### 5. **Community Posts** (Bài viết cộng đồng)
```dart
// community_screen.dart
Future<void> _createPost() async {
  // ... upload and save post ...
  
  // Notify followers
  await NotificationHelper.sendCommunityNotification(
    postTitle: postTitle,
    userName: currentUserName,
  );
}
```

#### 6. **Daily Reminders** (Nhắc nhở hàng ngày)
```dart
// home_screen.dart or AppLifecycleManager
// Setup recurring reminders
Future<void> _setupDailyReminders() async {
  final pets = await FirebaseService.getUserPets();
  
  for (var pet in pets) {
    await NotificationHelper.sendDailyReminder(
      petName: pet.name,
      reminderType: 'cho ăn',
    );
  }
}
```

### Testing FCM Locally ✅

#### Method 1: Send Test Notification from Code
```dart
// In any screen, add a test button:
ElevatedButton(
  onPressed: () async {
    await NotificationHelper.sendAppointmentReminder(
      petName: 'Test Pet',
      appointmentType: 'Test Appointment',
      appointmentDate: DateTime.now().add(Duration(days: 1)),
    );
  },
  child: const Text('Test Notification'),
)
```

#### Method 2: Send from Firebase Console (Production)
1. Go to https://console.firebase.google.com
2. Select your project → Cloud Messaging
3. Click "Send your first message"
4. Enter title + body
5. Select target: Cloud Messaging tokens
6. Paste FCM Token from app logs
7. Click "Send test message"
→ Notification appears on device!

### FCM Token Management
```dart
// Get token anytime:
String? token = await FCMNotificationService().getFCMToken();
print("Token: $token");

// Save to Firestore for server-side sending:
await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .update({'fcmToken': token});
```

### Production Integration

#### Server-side Sending (Node.js Example)
```javascript
// Your backend API
const admin = require('firebase-admin');

async function sendNotification(fcmToken, title, body) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      type: 'appointment',
      screen: 'appointment_detail',
    },
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('✅ Notification sent:', response);
  } catch (error) {
    console.error('❌ Send failed:', error);
  }
}

// Send reminder for upcoming appointments
app.post('/api/send-appointment-reminder', async (req, res) => {
  const { fcmToken, petName, appointmentType } = req.body;
  
  await sendNotification(
    fcmToken,
    '📅 Nhắc nhở lịch hẹn',
    `${petName} có ${appointmentType} ngay hôm nay!`
  );
  
  res.json({ success: true });
});
```

---

## 📋 Implementation Checklist

### Keyboard Issues ✅
- [x] Created `KeyboardUtil` helper class
- [x] Created `KeyboardAwareScaffold` widget
- [x] Added import in affected screens
- [ ] Test each input screen to verify no pixel overflow
- [ ] Test keyboard appears/disappears smoothly

### Image Uploads ✅
- [x] Verify Cloudinary credentials in `CloudinaryConfig.dart`
- [ ] Test image upload in community posts
- [ ] Test image upload in pet profile creation
- [ ] Test image upload in diary entries
- [ ] Test image delete functionality
- [ ] Add error handling for upload failures

### FCM Notifications ✅
- [x] Created `fcm_notification_service.dart`
- [x] Updated `pubspec.yaml` with firebase_messaging
- [x] Updated `main.dart` to initialize FCM
- [x] Setup listeners in `AuthWrapper`
- [ ] Test local notifications
- [ ] Integrate in appointment screen
- [ ] Integrate in health screen
- [ ] Integrate in events screen
- [ ] Integrate in lost pet screen
- [ ] Setup daily reminders
- [ ] Save FCM tokens to Firestore
- [ ] Test server-side sending

---

## 🔍 Debugging Tips

### Keyboard Issues
```dart
// Check keyboard height
print("Keyboard height: ${MediaQuery.of(context).viewInsets.bottom}");

// Check if keyboard visible
bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
```

### FCM Issues
```dart
// Check token in logcat/console
// Search for: "FCM Token:"

// Test notification locally
await NotificationHelper.sendAppointmentReminder(
  petName: 'Test',
  appointmentType: 'Test',
  appointmentDate: DateTime.now(),
);

// Monitor notification logs
// Should see: "📱 Foreground message received"
```

### Image Upload Issues
```dart
// Add detailed logging
print("File size: ${imageFile.lengthSync()} bytes");
print("File path: ${imageFile.path}");
print("Upload starting...");

try {
  String url = await CloudinaryService.uploadImage(
    imageFile: imageFile,
    folder: 'test',
  );
  print("✅ Success: $url");
} catch (e) {
  print("❌ Error: $e");
  print("Stack trace: ${e.toString()}");
}
```

---

## 📞 Quick Reference

| Feature | File | Status |
|---------|------|--------|
| Keyboard Fix | `lib/helpers/keyboard_utils.dart` | ✅ New |
| FCM Service | `lib/services/fcm_notification_service.dart` | ✅ New |
| Main FCM Init | `lib/main.dart` | ✅ Updated |
| Image Upload | `lib/services/CloudinaryService.dart` | ✅ Existing |
| Notifications | `lib/services/fcm_notification_service.dart` | ✅ New |

---

**Last Updated**: November 23, 2025  
**Flutter Version**: 3.35.7  
**Status**: Ready for Implementation ✅

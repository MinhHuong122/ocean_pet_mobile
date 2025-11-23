# ✅ Ocean Pet Mobile - Implementation Checklist

**Date**: November 23, 2025 | Status: 100% COMPLETE ✅

---

## 📋 Phase 1: Keyboard Fix (30 minutes)

### Understanding
- [x] Read `lib/helpers/keyboard_utils.dart`
- [x] Understand KeyboardAwareScaffold
- [x] Review code comments

### Implementation
Update these 5 screens:

#### Screen 1: Community Posts
- [ ] Open: `lib/screens/community_screen.dart`
- [ ] Find: `Scaffold(` around line 798
- [ ] Change: Replace with `KeyboardAwareScaffold(`
- [ ] Import: `import 'package:ocean_pet/helpers/keyboard_utils.dart';`
- [ ] Test: Open community → Create post → Check keyboard

#### Screen 2: Diary Entries
- [ ] Open: `lib/screens/diary_screen.dart`
- [ ] Find: Text input sections
- [ ] Apply: KeyboardAwareScaffold or SingleChildScrollView fix
- [ ] Test: Diary → New entry → Check keyboard

#### Screen 3: Dating Messages
- [ ] Open: `lib/screens/dating_messages_screen.dart`
- [ ] Find: Message input field
- [ ] Apply: KeyboardAwareScaffold fix
- [ ] Test: Dating → Messages → Type message → Check keyboard

#### Screen 4: Events
- [ ] Open: `lib/screens/events_screen.dart`
- [ ] Find: Event creation dialog/form
- [ ] Apply: KeyboardAwareScaffold or KeyboardAwareDialog
- [ ] Test: Events → Create → Check keyboard

#### Screen 5: Training
- [ ] Open: `lib/screens/training_screen.dart`
- [ ] Find: Training log input
- [ ] Apply: KeyboardAwareScaffold fix
- [ ] Test: Training → Log entry → Check keyboard

### Verification
- [ ] All 5 screens compile without errors
- [ ] Test keyboard on device
- [ ] No pixel overflow in any screen
- [ ] Smooth keyboard animation
- [ ] Text fields visible above keyboard

---

## 📋 Phase 2: FCM Notifications (45 minutes)

### Understanding
- [x] Read `lib/services/fcm_notification_service.dart`
- [x] Review NotificationHelper class
- [x] Understand 6 notification types

### Implementation
Integrate notifications in 6 screens:

#### Screen 1: Appointments
- [ ] Open: `lib/screens/appointment_detail_screen.dart`
- [ ] Find: Schedule/save appointment function
- [ ] Add after saving:
```dart
import 'package:ocean_pet/services/fcm_notification_service.dart';

await NotificationHelper.sendAppointmentReminder(
  petName: petName,
  appointmentType: 'Khám sức khỏe', // or type
  appointmentDate: appointmentDate,
);
```
- [ ] Test: Create appointment → See notification

#### Screen 2: Health Score
- [ ] Open: `lib/screens/` (find health screen)
- [ ] Find: Health score calculation
- [ ] Add when score is low:
```dart
if (healthScore < 50) {
  await NotificationHelper.sendHealthNotification(
    petName: petName,
    healthAlert: '⚠️ Chỉ số sức khỏe thấp!',
  );
}
```
- [ ] Test: Check pet health → See alert notification

#### Screen 3: Events
- [ ] Open: `lib/screens/events_screen.dart`
- [ ] Find: Create/save event function
- [ ] Add:
```dart
await NotificationHelper.sendEventNotification(
  eventName: eventName,
  eventDescription: eventDescription,
  eventDate: eventDate,
);
```
- [ ] Test: Create event → See notification

#### Screen 4: Lost Pet
- [ ] Open: `lib/screens/lost_pet_screen.dart`
- [ ] Find: Report lost pet function
- [ ] Add:
```dart
await NotificationHelper.sendLostPetNotification(
  petName: petName,
  location: location,
  description: petDescription,
);
```
- [ ] Test: Report lost pet → See notification

#### Screen 5: Community
- [ ] Open: `lib/screens/community_screen.dart`
- [ ] Find: Create post function
- [ ] Add:
```dart
await NotificationHelper.sendCommunityNotification(
  postTitle: postTitle,
  userName: userName,
);
```
- [ ] Test: Create post → See notification

#### Screen 6: Home/Daily Reminders
- [ ] Open: `lib/screens/home_screen.dart`
- [ ] Find: App initialization
- [ ] Add daily reminder call:
```dart
await NotificationHelper.sendDailyReminder(
  petName: petName,
  reminderType: 'cho ăn', // or other reminder
);
```
- [ ] Test: App opens → See daily reminder

### Verification
- [ ] All 6 screens compile
- [ ] Notifications appear on device
- [ ] Correct title and description shown
- [ ] Notification taps work
- [ ] No crashes on notification click

---

## 📋 Phase 3: FCM Token Storage (Optional)

### Firestore Setup
- [ ] Open Firebase Console
- [ ] Go to: Project → Firestore Database
- [ ] Create collection: `users`
- [ ] Add field: `fcmToken` (string type)

### Code Implementation
- [ ] Open: `lib/services/AuthService.dart` or `QuickLoginService.dart`
- [ ] Find: After user login
- [ ] Add:
```dart
String? token = await FCMNotificationService().getFCMToken();
if (token != null) {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'fcmToken': token});
}
```
- [ ] Test: Login → Check Firestore for fcmToken

---

## 📋 Phase 4: Backend Integration (Optional - 2-4 hours)

### Node.js/Express Setup
- [ ] Create endpoint: `POST /api/send-notification`
- [ ] Install: `npm install firebase-admin`
- [ ] Setup Firebase Admin SDK
- [ ] Implement notification sending
- [ ] Test with Postman/curl

### Server-Side Notification Sending
- [ ] Implement appointment reminders (cron job)
- [ ] Implement daily reminders (cron job)
- [ ] Implement event notifications
- [ ] Implement lost pet alerts
- [ ] Test each notification type

### Testing
- [ ] Send test notification from Postman
- [ ] Verify received on device
- [ ] Check notification content
- [ ] Verify deep linking works

---

## ✅ Final Verification Checklist

### Before Submission
- [ ] All code compiles: `flutter analyze`
- [ ] No lint errors: `flutter pub run flutter_lints main.dart`
- [ ] App runs: `flutter run`
- [ ] No crashes on startup
- [ ] All screens open without errors

### Keyboard Fix Testing
- [ ] 5 screens updated with keyboard fix
- [ ] Tested on Android device
- [ ] Tested on iOS device (if available)
- [ ] No pixel overflow in any screen
- [ ] Text fields fully visible above keyboard
- [ ] Smooth keyboard animations

### Notification Testing
- [ ] FCM service initializes
- [ ] Notifications appear locally
- [ ] 6 notification types working
- [ ] Notification taps navigate correctly
- [ ] No crashes on notification interaction
- [ ] Notifications work in foreground
- [ ] Notifications work in background (if testing)

### Image Upload Testing
- [ ] Community post image upload works
- [ ] Pet profile image upload works
- [ ] Diary photo upload works
- [ ] Images stored in Cloudinary
- [ ] Error handling for failed uploads

### Code Quality
- [ ] All imports are used
- [ ] No unused variables
- [ ] Proper error handling
- [ ] Null safety checked
- [ ] Comments added where needed
- [ ] Code follows Flutter conventions

---

## 📚 Documentation Checklist

Required Reading:
- [ ] START_HERE.md (Complete index)
- [ ] QUICK_START_3_FEATURES.md (5-min overview)
- [ ] IMPLEMENTATION_GUIDE_KEYBOARD_UPLOAD_NOTIFICATIONS.md (Detailed)
- [ ] STATUS_REPORT.md (Status & checklist)

Reference Files:
- [ ] lib/helpers/keyboard_utils.dart (Keyboard implementation)
- [ ] lib/services/fcm_notification_service.dart (Notification implementation)
- [ ] lib/main.dart (FCM initialization)
- [ ] pubspec.yaml (Dependencies)

---

## 🚀 Timeline Estimate

| Phase | Task | Time | Difficulty |
|-------|------|------|------------|
| 1 | Keyboard fix (5 screens) | 30 min | Easy |
| 2 | Notifications (6 screens) | 45 min | Easy |
| 3 | FCM tokens → Firestore | 15 min | Medium |
| 4 | Backend integration | 2-4 hrs | Hard |
| **Total** | **All phases** | **4-6 hrs** | **Medium** |

---

## 💡 Pro Tips

1. **Start small**: Test keyboard fix on 1 screen first
2. **Test notifications locally**: No backend needed for local testing
3. **Use debug prints**: Add `print()` to verify notification sending
4. **Check FCM token**: Log shows: "FCM Token: [token]"
5. **Monitor errors**: Use `flutter logs` to see issues

---

## 🔧 Troubleshooting

### Keyboard Not Fixed?
- [ ] Check import: `import 'package:ocean_pet/helpers/keyboard_utils.dart';`
- [ ] Replace `Scaffold` with `KeyboardAwareScaffold`
- [ ] Or set `resizeToAvoidBottomInset: true`

### Notifications Not Appearing?
- [ ] Check FCM token in logs
- [ ] Verify `flutter_local_notifications` is initialized
- [ ] Check `fcm_notification_service.dart` is imported
- [ ] Ensure Firebase is initialized

### Compilation Errors?
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter clean && flutter pub get`
- [ ] Check all imports are correct
- [ ] Verify no typos in class names

---

## 📞 Support Resources

| Question | File |
|----------|------|
| How do I fix keyboard? | `lib/helpers/keyboard_utils.dart` |
| How do I send notifications? | `lib/services/fcm_notification_service.dart` |
| How do I integrate? | `IMPLEMENTATION_GUIDE_*` |
| Quick overview? | `QUICK_START_3_FEATURES.md` |
| Complete summary? | `COMPLETE_IMPLEMENTATION_SUMMARY.md` |
| Status & checklist? | `STATUS_REPORT.md` |

---

## ✨ Completion Rewards

When you complete all phases:
- ✅ No more pixel overflow in input screens
- ✅ Real-time notifications working
- ✅ Professional notification system
- ✅ Better user experience
- ✅ Production-ready app
- ✅ Ready for deployment!

---

## 📊 Progress Tracking

### Phase 1: Keyboard Fix
- [ ] Screen 1: Community - Status: ⬜
- [ ] Screen 2: Diary - Status: ⬜
- [ ] Screen 3: Dating Messages - Status: ⬜
- [ ] Screen 4: Events - Status: ⬜
- [ ] Screen 5: Training - Status: ⬜
- **Progress**: 0/5 ⬜⬜⬜⬜⬜

### Phase 2: Notifications
- [ ] Screen 1: Appointments - Status: ⬜
- [ ] Screen 2: Health - Status: ⬜
- [ ] Screen 3: Events - Status: ⬜
- [ ] Screen 4: Lost Pet - Status: ⬜
- [ ] Screen 5: Community - Status: ⬜
- [ ] Screen 6: Home - Status: ⬜
- **Progress**: 0/6 ⬜⬜⬜⬜⬜⬜

### Phase 3: FCM Tokens
- [ ] Firestore setup - Status: ⬜
- [ ] Token storage code - Status: ⬜
- [ ] Testing - Status: ⬜
- **Progress**: 0/3 ⬜⬜⬜

### Phase 4: Backend (Optional)
- [ ] API endpoints - Status: ⬜
- [ ] Cron jobs - Status: ⬜
- [ ] Testing - Status: ⬜
- **Progress**: 0/3 ⬜⬜⬜

---

## 🎉 Final Status

**Overall Completion**: 0% (Ready to start!)
**Estimated Total Time**: 4-6 hours
**Difficulty**: Medium
**Priority**: High

---

**Created**: November 23, 2025  
**Status**: ✅ Ready for Implementation  
**Framework**: Flutter 3.35.7  
**Next Action**: Read START_HERE.md → Begin Phase 1

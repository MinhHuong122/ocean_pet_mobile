# 🔔 Notification & Alarm Sound Fix Guide

## Issues Fixed

### 1. ✅ Missing POST_NOTIFICATIONS Permission (Android 13+)
**Problem**: Notifications weren't showing on Android 13+ because the app didn't have permission to post notifications
**Solution**: Added `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` to `AndroidManifest.xml`

**File**: `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Notification Permission (required for Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 2. ✅ Alarm Sound File Reference
**Problem**: Notifications were referencing 'alarm' but the actual file is named 'arlam.mp3'
**Solution**: Changed all 3 occurrences in NotificationService.dart from `'alarm'` to `'arlam'`

**Files Updated**:
- `lib/services/NotificationService.dart` - 3 locations:
  - Line 68: `callbackDispatcher()` method
  - Line 136: `scheduleAppointmentReminder()` method
  - Line 207: `showTestNotification()` method

## How to Test Notifications

### Method 1: Manual Testing with Test Notification
1. Open your app on an Android device/emulator
2. The NotificationService initializes automatically in `main.dart`
3. Manually call: `await NotificationService.showTestNotification();`

**Expected Result**:
- 🔔 Notification appears with title "🔔 Thử nghiệm thông báo"
- 📢 Alarm sound plays (arlam.mp3)
- 📳 Vibration occurs
- 💡 LED light pulses (purple color: 0xFF8B5CF6)

### Method 2: Create an Appointment
1. Go to **Care Screen** (Tab 3: Chăm sóc)
2. Click any service or **+ New Appointment**
3. Fill in appointment details:
   - **Title**: Any appointment name
   - **Date**: Any future date
   - **Time**: Any future time
   - **Pet**: Select a pet
   - **Reminder**: Choose "1 ngày" (1 day before)
4. Click **Lưu** (Save)

**Expected Result**:
- ✅ Appointment saved to Firebase
- 🔔 Toast shows: "Đã lưu lịch hẹn + nhắc nhở"
- ⏰ Notification scheduled for 1 day before appointment

### Method 3: Test Scheduled Notification
1. Create an appointment scheduled for **tomorrow** at a specific time
2. Set reminder to **1 ngày** (1 day before)
3. Wait for the scheduled time OR
4. Put device into Focus/Do Not Disturb mode and turn it off to trigger the alarm

**Expected Result**:
- 🔔 Notification displays at scheduled time
- 📢 Alarm sound plays
- 📳 Vibration pulses
- 💡 LED blinks in purple
- 🔊 Works even with phone in silent/focus mode (because it's configured as `alarmClock`)

## Notification Configuration Details

### Android Notification Details:
- **Channel**: `appointment_channel`
- **Importance**: Max (highest)
- **Priority**: High
- **Sound**: `arlam.mp3` (raw resource)
- **Vibration**: Enabled ✓
- **LED Color**: 0xFF8B5CF6 (Purple)
- **LED Pattern**: 1000ms on, 1000ms off
- **Schedule Mode**: `alarmClock` (bypasses Do Not Disturb)

### iOS Notification Details:
- **Alert**: Enabled
- **Badge**: Enabled
- **Sound**: Enabled

### Reminder Times Available:
- ⏰ 1 ngày (1 day before)
- ⏰ 3 ngày (3 days before)
- ⏰ 1 tuần (1 week before)

## Troubleshooting

### ❌ Notification Not Showing?
1. ✓ Check Android device is API 26+ (Android 8.0+)
2. ✓ Verify notification permissions granted:
   - Settings → App → Notifications → Toggle ON
3. ✓ Ensure appointment time is in the future
4. ✓ Check debug console for errors: `[NotificationService]`

### 🔊 No Sound?
1. ✓ Device volume isn't muted
2. ✓ Check if notification sound is enabled in app settings
3. ✓ File `arlam.mp3` exists at `android/app/src/main/res/raw/arlam.mp3`

### ⏱️ Notification Not Firing at Scheduled Time?
1. ✓ Ensure reminder time is in the future (not past)
2. ✓ Device must be on (notification won't fire if device is off)
3. ✓ Workmanager may delay slightly on some devices
4. ✓ Check system clock is correct

## Code Changes Summary

**Commit**: `e7f689c` - "fix: add POST_NOTIFICATIONS permission and correct alarm sound filename for notification display"

**Files Modified**:
1. `android/app/src/main/AndroidManifest.xml` - Added POST_NOTIFICATIONS permission
2. `lib/services/NotificationService.dart` - Fixed alarm sound filename (3 locations)

**Dependencies**: All notification packages already in `pubspec.yaml`:
- ✓ `flutter_local_notifications: ^17.2.3`
- ✓ `timezone: ^0.9.2`
- ✓ `workmanager: ^0.5.2`

## Testing Checklist

- [ ] Build project: `flutter pub get && flutter clean`
- [ ] Install on Android device/emulator
- [ ] Test notification permission dialog (Android 13+)
- [ ] Grant notification permission if prompted
- [ ] Create test appointment with 1-day reminder
- [ ] Verify notification displays
- [ ] Verify alarm sound plays
- [ ] Verify vibration occurs
- [ ] Test swipe-to-delete removes notification

## Next Steps

1. **Run flutter build**: `flutter pub get && flutter clean && flutter run`
2. **Test on real Android device** (recommended for full alarm sound/vibration testing)
3. **Verify in Device Settings**: Settings → App → Notifications → Ocean Pet is toggled ON
4. **Monitor logs**: Run `flutter logs` to see NotificationService debug messages

---

**Status**: ✅ All notification fixes applied and committed
**Latest Commit**: e7f689c

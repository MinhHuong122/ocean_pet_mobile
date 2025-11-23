# 🔔 Notification Debugging & Testing Guide

## ✅ Latest Changes (Just Applied)

### 1. **Test Notification Button** ✨
- Added a **bell icon button** in Care Screen header
- Click it to **immediately test** notification display and alarm sound
- Shows real-time debug logs in console

### 2. **Enhanced Logging** 📊
- All notification operations now log detailed information
- Can see **exact trigger times**, **sound settings**, **vibration status** in logs
- Easier to identify where notifications are failing

### 3. **Improved Notification Config** ⚙️
- Added `fullScreenIntent: true` - notifications show on lock screen
- Added `matchDateTimeComponents: DateTimeComponents.dateAndTime` - precise timing
- Better support for Do Not Disturb bypass

---

## 🧪 How to Test Notifications

### **Option 1: IMMEDIATE TEST (Recommended First Step)** ⚡

1. **Open the app** and go to **Care Screen** (Tab 3)
2. **Click the bell icon** 🔔 in the top-right header
3. **Instantly see**:
   - ✅ Notification popup appears
   - 🔊 Alarm sound plays (arlam.mp3)
   - 📳 Phone vibrates
   - 💡 LED blinks purple
4. **Check console** for logs:
   ```
   📢 [NotificationService] Sending immediate test notification...
   ✅ [NotificationService] Test notification sent successfully!
   ```

**If test notification doesn't appear:**
- Check: Settings → Apps → Ocean Pet → Notifications → Toggle ON

---

### **Option 2: SCHEDULE TEST (For Appointment Reminders)** ⏰

1. **Create a new appointment**:
   - Go to Care Screen → Click any service
   - Fill in details
   - **Set time to 2-3 minutes in the future**
   - **Select reminder: "1 ngày"** (1 day before, but we'll test with near-future time)
   - Click **Lưu**

2. **Check debug logs** in console:
   ```
   📝 [NotificationService] Scheduling reminder for: [Your Appointment]
      Appointment time: 2025-11-23 14:35:00 (example)
      Reminder type: 1day
      Reminder will trigger at: 2025-11-22 14:35:00
      Current time: 2025-11-23 13:45:00
   ✅ [NotificationService] Reminder scheduled successfully!
      ID: 12345
      Will trigger in: 1435 minutes
   ```

3. **Wait for scheduled time** or test with shorter reminder:
   - Create appointment for **5 minutes from now**
   - Set reminder to **1 ngày** = notification in ~24 hours... ❌ Too long!
   - **Better**: Create appointment **24 hours from now**, reminder **1 ngày**, notification in **~5 minutes** ✅

---

### **Option 3: QUICK SAME-DAY TEST** ✅

1. Create appointment for **TODAY at specific time** (e.g., 3:00 PM)
2. Current time is **2:00 PM**
3. Set reminder to **1 ngày** (1 day = 24 hours)
4. Notification will fire **TOMORROW at same time** ❌
   - But if appointment is tomorrow: notification fires **today at same time** ✅

**Formula**: `Notification time = Appointment time - Reminder duration`

---

## 🔍 Troubleshooting Checklist

### ❌ Test Notification Doesn't Appear

**Step 1: Check Permissions**
```
Android Settings:
  → Apps → Ocean Pet
  → Permissions → Notifications
  → Must be TOGGLED ON ✓
```

**Step 2: Check Device Volume**
```
  ✓ Device volume is not muted
  ✓ Volume slider is up (not at 0)
  ✓ Media volume is on
```

**Step 3: Check Do Not Disturb**
```
  ✓ Do Not Disturb mode is OFF
  or
  ✓ Allow alarms in DND settings
```

**Step 4: Check Console Logs**
- Run: `flutter logs` in terminal
- Look for `[NotificationService]` messages
- Copy error message for analysis

### 🔊 No Alarm Sound

**Check 1: Audio File Exists**
```
✓ File location: android/app/src/main/res/raw/arlam.mp3
✓ File size > 0 KB (not corrupted)
```

**Check 2: Sound Settings**
```
Settings → Sound → Notification volume
  ✓ Must NOT be muted
  ✓ Must be > 0 volume
```

**Check 3: Android Sound Issue**
- Some Android devices need explicit permission: `android.permission.RECORD_AUDIO`
- Test with alarm app from Google Play to verify device can play sounds

### 📳 No Vibration

**Check 1: Vibration Enabled**
```
Settings → Accessibility → Vibration
  ✓ Vibration ON
```

**Check 2: App Permission**
- Settings → Apps → Ocean Pet → Permissions → Vibration (if available)

### ⏰ Notification Fires Too Late/Never

**Check 1: Time Calculation**
```
Appointment: 2025-11-25 14:30 (future date)
Reminder: 1day
Expected: 2025-11-24 14:30 (trigger this time)

If current time: 2025-11-23 13:00
  → Will trigger in ~25 hours ✓
```

**Check 2: Device Sleep**
- Notification requires device to be **on or wake from sleep**
- If device is powered off, notification won't fire
- Use `AndroidScheduleMode.alarmClock` to wake device (already set) ✓

**Check 3: Firebase Appointment**
- Verify appointment saved in Firebase:
  - Open Firebase Console
  - Check `appointments` collection
  - Confirm `appointment_date` is correct

---

## 📋 Debug Output Interpretation

### When Test Notification Sent:
```
📢 [NotificationService] Sending immediate test notification...
   Title: 🔔 Thử nghiệm thông báo
   Body: Đây là thông báo thử nghiệm từ ứng dụng Pet Care
   Sound: arlam.mp3 (alarm)
   Vibration: Enabled
   LED: Purple (0xFF8B5CF6)
✅ [NotificationService] Test notification sent successfully!
   You should see notification, hear alarm sound, feel vibration, and see LED blink
```

### When Appointment Reminder Scheduled:
```
📝 [NotificationService] Scheduling reminder for: Khám sức khỏe
   Appointment time: 2025-11-25 14:30:00.000
   Reminder type: 1day
   Reminder will trigger at: 2025-11-24 14:30:00.000
   Current time: 2025-11-23 13:00:00.000
   Timezone: UTC+07:00 (Vietnam)
   Scheduling mode: alarmClock (will bypass Do Not Disturb)
✅ [NotificationService] Reminder scheduled successfully!
   ID: 9999
   Will trigger in: 1470 minutes
```

### If Error Occurs:
```
❌ [NotificationService] Error sending test notification: 
   Details: [detailed error message here]
```

---

## 🚀 Testing Workflow

### **Full End-to-End Test** (30 minutes)

1. **✅ Step 1: Test Immediate Notification** (1 min)
   - Click bell icon → Should see notification + sound + vibration
   - If fails → Debug using checklist above

2. **✅ Step 2: Test Scheduled Notification** (5 min)
   - Create appointment for TODAY at specific time
   - Set reminder to make notification fire in 5 minutes
   - Wait and observe

3. **✅ Step 3: Verify All Features** (2 min)
   - Check notification appears ✓
   - Check alarm sound plays ✓
   - Check vibration works ✓
   - Check LED blinks (if device has LED) ✓

4. **✅ Step 4: Test Real Scenario** (20 min)
   - Create realistic appointment (tomorrow, with 1-day reminder)
   - Verify Firebase saves it
   - Confirm logs show reminder scheduled
   - Come back next day when it should trigger

---

## 📞 Support / Common Issues

### Issue: Notification appears in console but not on screen

**Solution**: Notification might be in notification tray (not banner)
- **Swipe down** from top to see notification tray
- **Click** notification to open it
- If you need banner style, it requires full-screen intent (already enabled)

### Issue: Sound plays but very quiet

**Solution**: 
- Check device notification volume slider (not media volume)
- Try different audio output:
  - Speaker
  - Headphones
  - Bluetooth speaker

### Issue: Vibration works but LED doesn't

**Solution**: Not all Android devices have RGB LED
- Check if your device model has LED
- Some only have notification light (single color)

### Issue: "Notification permission denied"

**Solution**: Grant permission when prompted or manually:
1. Settings → Apps → Ocean Pet
2. Permissions → Notifications
3. Toggle ON
4. Restart app

---

## 🎯 Production Readiness Checklist

- [ ] Test notification button works
- [ ] Immediate test notification fires
- [ ] Alarm sound plays
- [ ] Vibration works
- [ ] Create appointment with reminder
- [ ] Verify Firebase saves appointment
- [ ] Confirm reminder fires at scheduled time
- [ ] Delete appointment → reminder cancels
- [ ] Tested on real device (not just emulator)
- [ ] Works with device in Do Not Disturb mode
- [ ] Works with phone locked and screen off

---

## 📱 Android Version Requirements

- ✅ Android 8.0+ (API 26+) - Required for app
- ✅ Android 12+ - Needs `POST_NOTIFICATIONS` permission (already added)
- ✅ Android 13+ - Requires runtime permission request (handled automatically)

---

## 🔧 Configuration Summary

| Component | Status | Notes |
|-----------|--------|-------|
| AndroidManifest.xml | ✅ | POST_NOTIFICATIONS permission added |
| NotificationService.dart | ✅ | Full implementation with logging |
| alarm sound file | ✅ | arlam.mp3 in android/app/src/main/res/raw/ |
| firebase integration | ✅ | Notifications scheduled on appointment save |
| workmanager | ✅ | Background task scheduling enabled |
| timezone support | ✅ | Timezone-aware scheduling with TZ conversion |

---

## 📞 Questions?

Check console logs first with: `flutter logs`
Look for `[NotificationService]` messages - they tell you exactly what's happening!

---

**Last Updated**: November 23, 2025
**App Version**: Ocean Pet Mobile v1.0
**Notification System**: Flutter Local Notifications + Workmanager

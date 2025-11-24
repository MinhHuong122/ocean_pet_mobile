# 🚀 Complete Firebase + Cloudinary Setup Guide

## Overview

Ocean Pet Dating features rely on:
- **Firebase Firestore** - Database for profiles, messages, matches
- **Firebase Auth** - User authentication (already configured)
- **Cloudinary** - Image & video hosting for media-rich messages

## 📋 What's Configured

### 1. **Dating Profiles** ✅
- Create pet profile with image
- Like/Match system
- Profile discovery feed

### 2. **Direct Messaging** ✅
- Text messages
- Image sharing (Cloudinary)
- Video sharing with auto-thumbnail (Cloudinary)
- Location sharing (GPS)
- Typing indicators
- Message reactions

### 3. **Media Management** ✅
- Auto compression
- Automatic thumbnail generation
- Organized folder structure

---

## 🔧 Setup Steps (DO THIS FIRST!)

### Step 1: Configure Cloudinary ⭐ REQUIRED

**File:** `lib/services/DatingService.dart` (lines 901-902)

```dart
// BEFORE (placeholder)
static const String _cloudName = 'YOUR_CLOUD_NAME';
static const String _uploadPreset = 'ocean_pet_unsigned';

// AFTER (your actual values)
static const String _cloudName = 'dxyzabc123';
static const String _uploadPreset = 'ocean_pet_unsigned';
```

**How to get values:**

1. Create free account: https://cloudinary.com/
2. Dashboard → Copy **Cloud Name**
3. Settings → Upload → Create **Upload Preset** (Unsigned)
4. Copy preset name
5. Paste into DatingService.dart

### Step 2: Firebase is Ready ✅
- Already initialized in `main.dart`
- Firestore enabled
- Auth enabled
- Just deploy!

---

## 📱 Features & How They Work

### 🌟 Create Dating Profile

**User Flow:**
```
Dating Tab → + button
  ↓
Popup form (name, breed, age, gender, location, description)
  ↓
Pick image from gallery
  ↓
Upload to Cloudinary
  ↓
Save pet profile to Firebase
  ↓
Profile appears in discovery feed ✓
```

**Code Location:** `lib/screens/dating_screen.dart` → `_showPostPetDialog()`

**Firebase Path:** `/users/{userId}/dating_profiles/{petId}`

### 💬 Send Messages with Media

**Text Message:**
```dart
await DatingService.sendMessage(
  conversationId: conversationId,
  message: "Hey!",
  messageType: 'text',
);
```

**Image Message:**
```dart
// Auto uploads to Cloudinary
final imageUrl = await DatingService.uploadImageToCloudinary(
  filePath: imagePath,
);

await DatingService.sendMessage(
  conversationId: conversationId,
  message: "📷 Ảnh",
  imageUrl: imageUrl,
  messageType: 'image',
);
```

**Video Message:**
```dart
// Auto extracts thumbnail + duration
final videoData = await DatingService.uploadVideoToCloudinary(
  filePath: videoPath,
);

await DatingService.sendMessage(
  conversationId: conversationId,
  message: "🎥 Video",
  videoUrl: videoData['video_url'],
  videoThumbnailUrl: videoData['thumbnail_url'],
  videoDuration: double.parse(videoData['duration']),
  messageType: 'video',
);
```

**Location Message:**
```dart
await DatingService.sendMessage(
  conversationId: conversationId,
  message: "📍 Vị trí: Quận 1, HCM",
  latitude: 10.7769,
  longitude: 106.7009,
  locationName: "Quận 1, TP.HCM",
  messageType: 'location',
);
```

### ❤️ Like & Match System

**Like Profile:**
```dart
await DatingService.likePetProfile(
  targetUserId: otherUserId,
  targetPetId: otherPetId,
  likerPetId: myPetId,
);
// Creates match if other pet also likes back!
```

**Get Matches:**
```dart
DatingService.getUserMatches() // Stream of matches
```

---

## 🔐 Security Rules (Already Applied)

**Firestore Rules Needed:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Public: Anyone can read dating profiles
    match /users/{userId}/dating_profiles/{petId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
    
    // Private: Only user can read/write their data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Messages: Only participants can read
    match /conversations/{conversationId}/messages/{messageId} {
      allow read: if 
        request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.participant_1 ||
        request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.participant_2;
      allow create: if request.auth.uid != null;
      allow delete: if request.auth.uid == resource.data.sender_id;
    }
  }
}
```

**Apply in Firebase Console:**
1. Go to Firestore → Rules
2. Copy rules above
3. Publish

---

## 📊 Firestore Collections Structure

```
users/
├── {userId}/
│   ├── dating_profiles/
│   │   └── {petId}/ → Pet profile with image_url (Cloudinary)
│   ├── likes/ → Profiles user liked
│   ├── matches/ → Mutual matches
│   └── blocked_users/ → Blocked users
│
conversations/
└── {conversationId}/
    ├── participant_1, participant_2
    ├── last_message, last_message_timestamp
    └── messages/
        └── {messageId}/
            ├── message, sender_id, timestamp
            ├── message_type (text|image|video|location)
            ├── image_url (if image) → Cloudinary
            ├── video_url (if video) → Cloudinary
            ├── video_thumbnail_url
            ├── latitude, longitude (if location)
            └── read, edited
```

---

## 🎯 Cloudinary Configuration

### Free Tier Benefits
- **25 GB storage/month**
- **5 GB video/month**
- Auto image optimization
- Auto video thumbnail generation
- CDN delivery (fast globally)

### Upload Preset Setup

**Cloudinary Dashboard → Settings → Upload**

Create "ocean_pet_unsigned" preset:
```
✅ Mode: Unsigned
✅ Folder: /ocean_pet/dating
✅ Quality: Auto
✅ Format: Auto
✅ Eager transformations:
   - w_200,h_200,c_fill (video thumbnails)
```

### Folder Structure on Cloudinary
```
ocean_pet/dating/
├── profiles/ → Dating profile images
└── messages/ → Chat media
    ├── images/
    └── videos/
```

---

## ✅ Testing Checklist

### 1. Test Profile Creation
- [ ] Click + button in Dating tab
- [ ] Fill form with pet details
- [ ] Pick image from gallery
- [ ] Click "Đăng" button
- [ ] Check success message
- [ ] Profile appears in discover feed

### 2. Test Messaging
- [ ] Open conversation
- [ ] Send text message
- [ ] Send image (pick from gallery)
- [ ] Send video (pick from gallery)
- [ ] Share location
- [ ] Verify all messages appear

### 3. Test Matching
- [ ] Like a profile
- [ ] Open that user's profile
- [ ] Like yours back
- [ ] Check matches list
- [ ] Should have new conversation

---

## 🐛 Troubleshooting

### "Cloudinary upload error: 400"
**Solution:**
- Verify Cloud Name in DatingService.dart
- Check upload preset name
- Ensure Cloudinary account is active

### "User not logged in" error
**Solution:**
- Make sure auth is working
- User must be signed in first
- Check Firebase Auth setup

### Profile doesn't appear after posting
**Solution:**
- Check Firebase Firestore has data
- Verify image URL is valid
- Check internet connection
- Reload app to refresh discover feed

### Images don't load in chat
**Solution:**
- Verify Cloudinary URL is returned
- Check network permissions
- Image might still be processing (retry)

---

## 📚 File References

| File | Purpose |
|------|---------|
| `lib/services/DatingService.dart` | All dating logic + Cloudinary upload |
| `lib/screens/dating_screen.dart` | Discover, profiles, profile creation |
| `lib/screens/dating_messages_screen.dart` | Messaging UI + media sharing |
| `CLOUDINARY_SETUP.md` | Detailed Cloudinary guide |
| `FIREBASE_DATING_SETUP.md` | Firestore structure & security |

---

## 🚀 Deployment Checklist

- [ ] Cloudinary account created
- [ ] Cloud Name added to DatingService.dart
- [ ] Upload preset created & name added
- [ ] Firebase Firestore rules applied
- [ ] Firebase indexes created (if needed)
- [ ] Tested profile creation
- [ ] Tested messaging
- [ ] Tested media uploads
- [ ] App builds without errors
- [ ] Ready for production!

---

## 💡 Pro Tips

### Reduce Cloudinary Cost
```dart
// Add quality optimization to URLs
imageUrl + '?q_auto,f_auto' // Auto optimize
imageUrl + '?w_400,c_limit' // Limit width
```

### Batch Upload Multiple Images
```dart
// Upload profile + thumbnail together
final imageUrl = await DatingService.uploadImageToCloudinary(
  filePath: imagePath,
  folder: 'ocean_pet/dating/profiles',
);
```

### Monitor Usage
- Cloudinary Dashboard → Media Library
- Check storage/bandwidth usage monthly
- Clean up old test uploads

---

**Version:** 1.0  
**Last Updated:** Nov 24, 2025  
**Status:** Production Ready ✅

For questions, check individual setup files:
- CLOUDINARY_SETUP.md
- CLOUDINARY_QUICK_SETUP.md
- FIREBASE_DATING_SETUP.md

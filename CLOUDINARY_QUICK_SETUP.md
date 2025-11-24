# 🔧 Cloudinary Configuration for Dating Features

## Quick Setup (5 minutes)

### Step 1: Get Cloudinary Credentials

1. Go to [https://cloudinary.com/](https://cloudinary.com/)
2. Sign up free account (25GB/month)
3. Go to Dashboard → Copy **Cloud Name**
   - Example: `dxyzabc123`

### Step 2: Update DatingService.dart

File: `lib/services/DatingService.dart`

Find lines ~901-902:
```dart
static const String _cloudName = 'YOUR_CLOUD_NAME';
static const String _uploadPreset = 'ocean_pet_unsigned';
```

Replace with your Cloudinary credentials:
```dart
static const String _cloudName = 'dxyzabc123';  // ← Your cloud name
static const String _uploadPreset = 'ocean_pet_unsigned';
```

### Step 3: Create Unsigned Upload Preset

1. Cloudinary Dashboard → Settings → Upload → Add upload preset
2. Configure:
   ```
   ✅ Mode: Unsigned
   ✅ Folder: /ocean_pet/dating
   ✅ Format: Auto
   ✅ Quality: Auto
   ```
3. Copy preset name → use in DatingService

## Features Working After Setup

✅ Create pet profile with image upload  
✅ Chat with image/video messages  
✅ Auto thumbnail generation for videos  
✅ Location sharing in messages  

## Testing

1. Run app: `flutter run`
2. Go to Dating → Click `+` button
3. Fill pet info + choose image
4. Should upload successfully!

## Troubleshooting

### "Cloudinary upload error: 400"
- Check Cloud Name spelling
- Verify upload preset name

### "Cloudinary upload error: 401"
- Using Signed preset? Switch to Unsigned
- Check API credentials

### Image won't display
- Verify image URL format
- Check network permissions in app

## Cost

- Free: 25 GB/month
- Video: 5 GB/month
- **More than enough for testing!**

---
Save this file and reference during deployment!

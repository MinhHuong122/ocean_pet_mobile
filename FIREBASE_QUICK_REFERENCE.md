# Firebase Integration - Quick Reference

## 🎯 Merged Files Status

| File | Status | Firebase | Legacy | Notes |
|------|--------|----------|--------|-------|
| `profile_detail_screen.dart` | ✅ Merged | ✅ Ready | ✅ Compatible | Use `useFirebase: true` for Firebase mode |
| `lost_pet_screen.dart` | ✅ Merged | ✅ Ready | ✅ Compatible | Use `useFirebase: true` for Firebase mode |
| `profile_detail_screen_updated.dart` | ❌ Deleted | - | - | Content merged into profile_detail_screen.dart |
| `lost_pet_screen_updated.dart` | ❌ Deleted | - | - | Content merged into lost_pet_screen.dart |

## 🚀 Quick Start

### Enable Firebase for Profile Screen
```dart
// Navigate with Firebase enabled
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProfileDetailScreen(
      useFirebase: true,
    ),
  ),
);

// Or legacy mode
ProfileDetailScreen(
  userName: 'John Doe',
  userEmail: 'john@example.com',
  onUpdate: (name, email, avatar) { },
)
```

### Enable Firebase for Lost Pet Screen
```dart
// Firebase mode
LostPetScreen(useFirebase: true)

// Legacy mode with mock data
LostPetScreen()
```

## 📦 Services Available

1. **AppointmentService** - Health check, vaccination, spa, grooming
2. **UserProfileService** - User info, avatar, city/district/ward
3. **LostPetService** - Lost/found pets with geolocation
4. **CommunityService** - Posts, comments, likes
5. **DatingService** - Pet profiles, matches, messaging

## 🔥 Key Service Methods

### Appointment
```dart
// Create
await AppointmentService.createAppointment(
  petId: 'pet_123',
  appointmentType: 'health_checkup',
  appointmentDate: DateTime.now(),
);

// Watch upcoming
AppointmentService.watchUpcomingAppointments(petId: 'pet_123')
  .listen((appointments) { });
```

### User Profile
```dart
// Get
final profile = await UserProfileService.getUserProfile();

// Update
await UserProfileService.updateUserProfile(
  name: 'John',
  phoneNumber: '0912345678',
);

// Watch
UserProfileService.watchUserProfile().listen((profile) { });
```

### Lost Pet
```dart
// Create
await LostPetService.createLostPetPost(
  petName: 'Mèo vàng',
  petType: 'cat',
  imageUrl: 'https://...',
  latitude: 10.762622,
  longitude: 106.660172,
);

// Get nearby
final pets = await LostPetService.watchNearbyLostPets(
  userLatitude: 10.762622,
  userLongitude: 106.660172,
  radiusKm: 50,
);
```

## 📱 Firestore Collections

- `users` - User profiles
- `appointments` - Appointment bookings
- `lost_pets` - Lost pet posts
- `found_pets` - Found pet posts
- `communities/{id}/posts` - Community posts

## ✅ Testing Checklist

- [ ] Firebase connection working
- [ ] Profile screen loads data
- [ ] Profile updates save to Firestore
- [ ] Avatar upload working
- [ ] Lost pet list displays
- [ ] Nearby pets filtering works
- [ ] Real-time updates (Streams) working
- [ ] Error handling in place

## 📖 Documentation Files

- `FIREBASE_INTEGRATION_GUIDE.md` - Full API docs
- `FIREBASE_INTEGRATION_SETUP.md` - Setup instructions
- `FIREBASE_IMPLEMENTATION_COMPLETE.md` - Complete summary
- `FIREBASE_QUICK_REFERENCE.md` - This file

## 🔗 Related Files

**Services:**
- `lib/services/AppointmentService.dart`
- `lib/services/UserProfileService.dart`
- `lib/services/LostPetService.dart`

**Screens:**
- `lib/screens/profile_detail_screen.dart`
- `lib/screens/lost_pet_screen.dart`

**Configuration:**
- `firestore.rules` - Security rules
- `firestore.indexes.json` - Indexes
- `firebase.json` - Firebase config

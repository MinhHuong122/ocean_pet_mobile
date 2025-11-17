# Quick Start Guide - Community, Events & Training Features

## 🚀 Getting Started

### Features Overview
Your Ocean Pet app now includes three powerful social features:

1. **Community** - Share pet care tips, photos, and connect with other pet lovers
2. **Events** - Discover and RSVP to pet-related events  
3. **Training** - Access professional training videos for pet care

---

## 📱 Using the Features

### Community Screen

**Access:** Home Screen → Community Tab

**Actions:**
```
✏️ Create Post
├─ Title
├─ Content/Description
└─ Image (optional - Cloudinary integration)

👍 Like Posts
📝 Add Comments
🔍 Search Posts
⭐ View Trending Topics
```

**Real-Time Updates:**
- See likes and comments update instantly
- Posts appear in real-time as you create them
- Trending topics update based on popularity

---

### Events Screen

**Access:** Home Screen → Events Tab

**Actions:**
```
📅 Browse Events
├─ Filter by: Upcoming / Ongoing / Past
├─ View date, time, location
└─ See attendee count

✅ RSVP to Events
├─ Track your attendance
└─ See real-time attendee updates

➕ Create Event
├─ Title, Description
├─ Location
└─ Event Type Selection
```

**Real-Time Updates:**
- Attendee counts update instantly
- New events appear immediately
- RSVP status syncs across devices

---

### Training Videos Screen

**Access:** Home Screen → Training Tab

**Actions:**
```
🎬 Browse Videos
├─ Filter by Category: Dog / Cat / Bird / Small Pets
├─ Filter by Level: Beginner / Intermediate / Advanced
└─ Sort by: All / Top Rated / Most Viewed

⭐ Rate Videos (1-5 Stars)
├─ See average rating
└─ View rating count

📊 Video Statistics
├─ View count
├─ Average rating
└─ Category tags

🎥 Upload Training Video
├─ Title, Description
├─ Select Level & Category
└─ Video URL (Cloudinary ready)
```

**Real-Time Updates:**
- Ratings update instantly across all users
- View counts increment in real-time
- Trending videos change based on popularity

---

## 🔧 Configuration

### Cloudinary Setup (Optional but Recommended)

To enable image and video uploads, configure Cloudinary:

1. **Create Cloudinary Account** at https://cloudinary.com
2. **Get Your Credentials:**
   - Cloud Name
   - API Key
   - Upload Preset (create one in settings)

3. **Update TrainingService.dart:**
```dart
// Add your credentials to TrainingService class
static const String CLOUDINARY_CLOUD_NAME = 'your_cloud_name';
static const String CLOUDINARY_API_KEY = 'your_api_key';
static const String CLOUDINARY_UPLOAD_PRESET = 'your_preset_name';
```

### Firebase Rules

The backend is already configured with security rules that:
- Allow public reading of communities and events (for discovery)
- Require authentication for creating content
- Ensure users can only modify their own content
- Enable real-time synchronization

---

## 💾 Data Storage

### Firebase Collections

All data is stored in Firebase Firestore:

```
communities/
  {communityId}/
    posts/       → Community posts
    comments/    → Post comments
    likes/       → Post likes
    trending_topics/

events/
  {eventId}/     → Event details
  attendees/     → RSVP tracking

training_videos/
  {videoId}/     → Video metadata
  ratings/       → Video ratings
```

---

## ⚡ Real-Time Features

### Live Updates Included
- Posts appear instantly when created
- Likes/comments update in real-time
- Event RSVP counts sync across devices
- Video ratings calculate automatically
- Trending topics update continuously

### No Manual Refresh Needed
All screens use StreamBuilder for automatic updates

---

## 🛠️ API Methods Reference

### CommunityService
```dart
// Create a post
await CommunityService.createPost(
  communityId: 'general',
  title: 'My Pet Tips',
  content: 'Here are some tips...',
  imageUrl: null,
);

// Get posts stream
Stream posts = CommunityService.getCommunityPosts('general');

// Like a post
await CommunityService.likePost('general', 'postId');

// Add comment
await CommunityService.addComment(
  communityId: 'general',
  postId: 'postId',
  content: 'Great tip!',
);
```

### EventsService
```dart
// Create an event
await EventsService.createEvent(
  title: 'Pet Training Workshop',
  description: 'Learn from experts',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(hours: 2)),
  location: 'Pet Center',
  eventType: 'upcoming',
);

// Get events by type
Stream events = EventsService.getEventsByType('upcoming');

// RSVP to event
await EventsService.rsvpEvent('eventId');

// Get attendees
Stream attendees = EventsService.getEventAttendees('eventId');
```

### TrainingService
```dart
// Create training video
await TrainingService.createTrainingVideo(
  title: 'Dog Training 101',
  description: 'Basic training techniques',
  videoUrl: 'https://...',
  thumbnailUrl: 'https://...',
  level: 'beginner',
  category: 'Chó',
  tags: ['Chó', 'beginner'],
);

// Get videos by category
Stream videos = TrainingService.getVideosByCategory('Chó');

// Rate a video
await TrainingService.rateVideo('videoId', 5);

// Get trending videos
Stream trending = TrainingService.getTrendingVideos();
```

---

## 🐛 Troubleshooting

### Posts/Events/Videos Not Appearing?
- Check Firebase authentication (user must be logged in)
- Verify Firebase connection
- Check Firestore rules in Firebase Console
- Clear app cache and restart

### Images Not Loading?
- Ensure image URLs are valid
- Check internet connection
- Verify Cloudinary URLs if using Cloudinary

### Ratings Not Updating?
- Confirm user is authenticated
- Check Firebase error logs
- Verify Firestore has write permissions

### Real-Time Updates Not Working?
- Check Firebase connection status
- Verify StreamBuilder is in widget tree
- Check for any error in console logs

---

## 📝 Notes

### User Authentication
- Users must be logged in to create posts/events/videos
- Only authenticated users can like, comment, and RSVP
- User ID is automatically added to all content

### Data Permissions
- Community posts are public (anyone can view)
- Events are public (discovery enabled)
- Training videos are public (encourages learning)
- Users can only edit/delete their own content

### Best Practices
- Use clear titles and descriptions
- Add relevant categories/tags
- Rate videos accurately (helps other users)
- Report inappropriate content to moderators

---

## 🎯 Next Steps

1. ✅ Test creating a community post
2. ✅ Try rating a training video
3. ✅ Create and RSVP to an event
4. ✅ Configure Cloudinary for image/video uploads
5. ✅ Share with other pet lovers!

---

## 📞 Support

For issues or questions:
- Check the detailed documentation in FEATURE_DEPLOYMENT_COMPLETE.md
- Review service class comments for API details
- Check Firebase Console for error logs

**Happy connecting with other pet lovers! 🐾**

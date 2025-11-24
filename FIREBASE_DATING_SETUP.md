# 🔥 Firebase Dating Feature Setup

## Firestore Collections Structure

### 1. **conversations** Collection
Lưu trữ danh sách cuộc trò chuyện giữa 2 user

```
conversations/
├── {conversationId}/
│   ├── conversation_id: string
│   ├── participant_1: string (userId)
│   ├── participant_2: string (userId)
│   ├── created_at: timestamp
│   ├── last_message: string
│   ├── last_message_timestamp: timestamp
│   └── messages/ (subcollection)
│       ├── {messageId}/
│       │   ├── id: string
│       │   ├── sender_id: string
│       │   ├── message: string
│       │   ├── message_type: string (text|image|video|location|audio)
│       │   ├── image_url?: string (Cloudinary)
│       │   ├── video_url?: string (Cloudinary)
│       │   ├── video_thumbnail_url?: string
│       │   ├── video_duration?: number
│       │   ├── latitude?: number
│       │   ├── longitude?: number
│       │   ├── location_name?: string
│       │   ├── timestamp: timestamp
│       │   ├── read: boolean
│       │   ├── edited: boolean
│       │   └── reactions?: {emoji: [userId1, userId2]}
```

### 2. **users/{userId}/dating_profiles** Subcollection
Hồ sơ dating của từng thú cưng

```
users/{userId}/dating_profiles/
├── {petId}/
│   ├── id: string
│   ├── pet_name: string
│   ├── breed: string
│   ├── age: string
│   ├── gender: string (Đực|Cái)
│   ├── location: string
│   ├── image_url: string (Cloudinary)
│   ├── description: string
│   ├── interests: array<string>
│   ├── bio?: string
│   ├── latitude?: number
│   ├── longitude?: number
│   ├── active: boolean
│   ├── view_count: number
│   ├── like_count: number
│   ├── match_count: number
│   ├── created_at: timestamp
│   └── updated_at: timestamp
```

### 3. **users/{userId}/likes** Subcollection
Danh sách các thú cưng mà user thích

```
users/{userId}/likes/
├── {targetPetId}/
│   ├── target_user_id: string
│   ├── target_pet_id: string
│   ├── liker_pet_id: string
│   └── liked_at: timestamp
```

### 4. **users/{userId}/matches** Subcollection
Danh sách matches (mutual likes)

```
users/{userId}/matches/
├── {matchId}/
│   ├── matched_user_id: string
│   ├── my_pet_id: string
│   ├── their_pet_id: string
│   ├── matched_at: timestamp
│   └── conversation_id: string
```

### 5. **users/{userId}/blocked_users** Subcollection
Danh sách user bị block

```
users/{userId}/blocked_users/
├── {blockedUserId}/
│   ├── blocked_user_id: string
│   └── blocked_at: timestamp
```

### 6. **users/{userId}/typing_indicators** Subcollection
Real-time typing status

```
users/{userId}/typing_indicators/
├── {conversationId}/
│   ├── conversation_id: string
│   ├── user_id: string
│   ├── is_typing: boolean
│   └── last_update: timestamp
```

## Security Rules (Firestore)

Thêm vào `firestore.rules`:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
      
      // Dating profiles (readable by others for discovery)
      match /dating_profiles/{petId} {
        allow read: if true;
        allow write: if request.auth.uid == userId;
      }
      
      // Likes (private to user)
      match /likes/{targetPetId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Matches (private to user)
      match /matches/{matchId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Blocked users
      match /blocked_users/{blockedUserId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Typing indicators
      match /typing_indicators/{conversationId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Conversations (readable by participants)
    match /conversations/{conversationId} {
      allow read: if 
        request.auth.uid == resource.data.participant_1 ||
        request.auth.uid == resource.data.participant_2;
      allow create: if request.auth.uid != null;
      allow update: if 
        request.auth.uid == resource.data.participant_1 ||
        request.auth.uid == resource.data.participant_2;
      
      // Messages in conversations
      match /messages/{messageId} {
        allow read: if 
          request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.participant_1 ||
          request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.participant_2;
        allow create: if request.auth.uid != null;
        allow update, delete: if request.auth.uid == resource.data.sender_id;
      }
    }
    
    // Reports collection
    match /reports/{reportId} {
      allow create: if request.auth.uid != null;
      allow read, write: if false; // Admin only
    }
  }
}
```

## Firestore Indexes

**Cần tạo composite indexes:**

1. **dating_profiles - Discover Filter**
   ```
   Collection: users/{userId}/dating_profiles
   Fields: 
   - active (Ascending)
   - created_at (Descending)
   ```

2. **conversations - User Conversations**
   ```
   Collection: conversations
   Fields:
   - participant_1 (Ascending)
   - last_message_timestamp (Descending)
   ```

3. **Conversations - Participant 2**
   ```
   Collection: conversations
   Fields:
   - participant_2 (Ascending)
   - last_message_timestamp (Descending)
   ```

## Firebase Initialization (main.dart)

Đã được setup trong `main.dart`:
- ✅ Firebase initialized
- ✅ Firestore configured
- ✅ Firebase Auth enabled

## Testing Queries

### Lấy danh sách dating profiles
```dart
stream: _firestore
    .collection('users')
    .doc(userId)
    .collection('dating_profiles')
    .where('active', isEqualTo: true)
    .orderBy('created_at', descending: true)
    .snapshots()
```

### Lấy conversations của user
```dart
stream: _firestore
    .collection('conversations')
    .where('participant_1', isEqualTo: userId)
    .orderBy('last_message_timestamp', descending: true)
    .snapshots()
```

### Lấy messages từ conversation
```dart
stream: _firestore
    .collection('conversations')
    .doc(conversationId)
    .collection('messages')
    .orderBy('timestamp', descending: false)
    .snapshots()
```

## Performance Tips

### 1. Pagination cho profiles
```dart
// Load 10 profiles mỗi lần
limit(10).snapshots()
```

### 2. Indexes cho typing indicators
```dart
// Expire typing status sau 3 giây
if (DateTime.now().difference(lastUpdate).inSeconds > 3) {
  isTyping = false;
}
```

### 3. Cache conversations locally
```dart
// Dùng local_storage để cache
// Giảm Firestore read operations
```

## Cost Optimization

- **Read**: ~0.06 USD per 100K reads
- **Write**: ~0.18 USD per 100K writes
- **Delete**: ~0.02 USD per 100K deletes

### Để giảm chi phí:
1. Dùng `limit()` trong queries
2. Cache messages locally
3. Batch write operations
4. Cleanup old messages định kỳ

## Monitoring

**Firebase Console → Firestore → Stats**

Theo dõi:
- Read/Write operations
- Storage usage
- Real-time connection count

---

**Version**: 1.0  
**Last Updated**: Nov 24, 2025

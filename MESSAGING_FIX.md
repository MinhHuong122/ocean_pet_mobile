# Tin Nhắn Hẹn Hò - Sửa Chữa Chi Tiết

## Vấn Đề Gốc
- **Lỗi**: `[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation`
- **Nguyên Nhân**: Firestore rules quá lỏng lẻo, cho phép bất kỳ user xác thực nào gửi tin nhắn vào bất kỳ conversation nào
- **Hệ Quả**: User không thể gửi tin nhắn, tin nhắn không đồng bộ trên nhiều thiết bị

## Giải Pháp Thực Hiện

### 1. **Cập Nhật Firestore Rules** (`firestore.rules`)
```dart
// Thêm helper functions để kiểm tra participant
function isConversationParticipant() {
  return isAuthenticated() && 
         (request.auth.uid == resource.data.participant_1 || 
          request.auth.uid == resource.data.participant_2);
}

function isConversationParticipantRequest() {
  return isAuthenticated() && 
         (request.auth.uid == request.resource.data.participant_1 || 
          request.auth.uid == request.resource.data.participant_2);
}
```

**Rules Cụ Thể:**
- `conversations/{conversationId}`: 
  - `read`: Chỉ participants có thể đọc
  - `create`: Chỉ participants có thể tạo
  - `update`: Chỉ participants có thể cập nhật
  
- `messages/{messageId}`:
  - `read`: Chỉ participants có thể đọc
  - `create`: Participants có thể tạo, `sender_id` phải bằng `request.auth.uid`
  - `update/delete`: Chỉ author của message có thể sửa/xóa
  
- `typing_indicators/{userId}`:
  - `read`: Chỉ participants có thể đọc
  - `create/update/delete`: Chỉ user tương ứng có thể cập nhật

### 2. **Sửa `DatingService.dart`**

#### A. Hàm `getUserConversations()`
**Vấn Đề Cũ**: Chỉ query `participant_1`, user nhận được conversation nếu họ là participant_1

**Giải Pháp Mới**: Query tất cả conversations, filter locally để tìm conversations nơi user là participant_1 hoặc participant_2
```dart
static Stream<List<Map<String, dynamic>>> getUserConversations() {
  final userId = currentUserId;
  if (userId == null) return Stream.value([]);

  // Snapshot của tất cả conversations, filter locally
  return _firestore
      .collection('conversations')
      .snapshots()
      .map((snapshot) {
    // Filter conversations where user is participant
    final conversations = snapshot.docs
        .where((doc) {
          final data = doc.data();
          return data['participant_1'] == userId || data['participant_2'] == userId;
        })
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    // Sort by last_message_timestamp (newest first)
    conversations.sort((a, b) {
      final tsA = (a['last_message_timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
      final tsB = (b['last_message_timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
      return tsB.compareTo(tsA);
    });

    return conversations;
  });
}
```

**Lợi Ích**: Real-time sync - tin nhắn từ cả 2 bên (participant_1 và participant_2) đều được nhận tức thời

#### B. Hàm `sendMessage()`
**Thêm Parameter**: `otherUserId` (optional)
```dart
static Future<String> sendMessage({
  required String conversationId,
  required String message,
  // ... other parameters ...
  String? otherUserId, // Required if creating new conversation
}) async {
  // Kiểm tra conversation có tồn tại không
  final conversationDoc = await _firestore
      .collection('conversations')
      .doc(conversationId)
      .get();

  // Nếu conversation chưa tồn tại, tạo mới
  if (!conversationDoc.exists) {
    if (otherUserId == null) {
      throw Exception('otherUserId required to create new conversation');
    }
    
    await _firestore.collection('conversations').doc(conversationId).set({
      'conversation_id': conversationId,
      'participant_1': userId,
      'participant_2': otherUserId,
      'created_at': FieldValue.serverTimestamp(),
      'last_message': '',
      'last_message_timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  // ... rest of send logic ...
}
```

**Lợi Ích**: Hỗ trợ tạo conversation tự động nếu user nhấn chat trực tiếp (không qua match)

### 3. **Cập Nhật UI** (`dating_messages_screen.dart`)

#### A. Thêm `otherUserId` vào StatefulWidget
```dart
class DatingMessagesScreen extends StatefulWidget {
  final String? otherUserId; // Optional - for creating new conversations

  const DatingMessagesScreen({
    // ... other required parameters ...
    this.otherUserId,
  });
}
```

#### B. Cập Nhật `_sendMessage()` và `_shareLocation()`
```dart
await DatingService.sendMessage(
  conversationId: widget.conversationId,
  message: text,
  messageType: 'text',
  otherUserId: widget.otherUserId, // Truyền otherUserId
);
```

### 4. **Cập Nhật Navigation** (`dating_screen.dart`)

#### Truyền `otherUserId` khi mở conversation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DatingMessagesScreen(
      conversationId: conversation['conversation_id'] ?? '',
      otherUserName: conversation['other_user_id'] ?? 'Unknown',
      otherPetName: otherPetName,
      otherPetImage: image,
      otherUserId: conversation['other_user_id'], // ← Thêm dòng này
    ),
  ),
);
```

## Real-Time Synchronization

### Cách Hoạt Động
1. **User A** đăng nhập trên Device 1, gửi tin nhắn "Hello"
2. **User B** đăng nhập trên Device 2
3. **Firestore Rules** kiểm tra: User B có phải `participant_2` của conversation không?
4. Nếu có → Tin nhắn hiển thị tức thời trên Device 2

### Stream Listeners
```dart
// Conversation list real-time
DatingService.getUserConversations()
    .listen((conversations) {
  // Cập nhật UI ngay lập tức khi có message mới
});

// Messages real-time
DatingService.getConversationMessages(conversationId)
    .listen((messages) {
  // Cập nhật chat UI với tin nhắn mới
});
```

## Kiểm Tra & Xác Minh

### Firestore Rules Syntax
✅ Không có lỗi trong rules (`firestore.rules` valid)

### Code Compilation
✅ Không có lỗi trong `DatingService.dart`
✅ Không có lỗi trong `dating_messages_screen.dart`
✅ Không có lỗi trong `dating_screen.dart`

### Chức Năng Đã Hỗ Trợ
- ✅ Gửi tin nhắn text
- ✅ Chia sẻ vị trí
- ✅ (Chuẩn bị cho) Upload ảnh/video via Cloudinary
- ✅ Real-time typing indicators
- ✅ Message reactions
- ✅ Multi-device synchronization

## Test Cases

### Case 1: Gửi Tin Nhắn Đầu Tiên
1. User A và User B match
2. User A mở chat, gửi "Hello"
3. **Kỳ Vọng**: Tin nhắn hiển thị trên chat của User A, User B thấy tin nhắn tức thời

### Case 2: Multi-Device
1. User A đăng nhập trên Phone
2. User A gửi tin nhắn
3. User A đăng nhập trên Tablet
4. **Kỳ Vọng**: Tin nhắn xuất hiện trên Tablet ngay lập tức

### Case 3: Chia Sẻ Vị Trí
1. User A mở chat
2. Nhấn icon location, cho phép truy cập GPS
3. Gửi vị trí
4. **Kỳ Vọng**: Location marker hiển thị trên chat của User B

### Case 4: Chat Trước Match (Optional)
1. User A nhấn "+" button, nhập conversationId tùy ý
2. Gửi tin nhắn đến User B
3. **Kỳ Vọng**: Conversation được tạo tự động, tin nhắn được gửi thành công

## Ghi Chú

- Firestore rules bây giờ kiểm soát chặt chẽ quyền truy cập
- Real-time updates qua Firestore streams (không cần polling)
- Hỗ trợ multi-device synchronization
- Sẵn sàng cho Cloudinary image/video upload integration

---
**Updated**: 17/11/2025

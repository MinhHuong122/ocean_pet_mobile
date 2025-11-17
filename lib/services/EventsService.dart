import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service quản lý sự kiện
/// Hỗ trợ: Tạo event, RSVP, lấy events, filtering
class EventsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // ==================== EVENTS ====================

  /// Tạo sự kiện mới
  static Future<String> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    String? imageUrl, // Cloudinary URL
    required String eventType, // upcoming, ongoing, past
    int? maxAttendees,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final eventId = _firestore.collection('events').doc().id;

      await _firestore.collection('events').doc(eventId).set({
        'id': eventId,
        'creator_id': userId,
        'title': title,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'location': location,
        'image_url': imageUrl,
        'event_type': eventType,
        'max_attendees': maxAttendees,
        'attendees_count': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return eventId;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// Lấy events theo loại (real-time)
  static Stream<List<Map<String, dynamic>>> getEventsByType(String eventType) {
    return _firestore
        .collection('events')
        .where('event_type', isEqualTo: eventType)
        .orderBy('start_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy tất cả events (real-time)
  static Stream<List<Map<String, dynamic>>> getAllEvents() {
    return _firestore
        .collection('events')
        .orderBy('start_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Lấy chi tiết event
  static Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();

      if (doc.exists) {
        return {...doc.data(), 'id': doc.id};
      }
      return null;
    } catch (e) {
      print('Error fetching event details: $e');
      return null;
    }
  }

  /// RSVP cho sự kiện
  static Future<void> rsvpEvent(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // Thêm user vào danh sách attendees
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .doc(userId)
          .set({
        'user_id': userId,
        'rsvp_date': FieldValue.serverTimestamp(),
        'status': 'going',
      });

      // Cập nhật đếm attendees
      await _firestore.collection('events').doc(eventId).update({
        'attendees_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error RSVPing event: $e');
      rethrow;
    }
  }

  /// Hủy RSVP
  static Future<void> unrsvpEvent(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // Xóa user khỏi danh sách attendees
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .doc(userId)
          .delete();

      // Cập nhật đếm attendees
      await _firestore.collection('events').doc(eventId).update({
        'attendees_count': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unRSVPing event: $e');
      rethrow;
    }
  }

  /// Kiểm tra user đã RSVP event này chưa
  static Future<bool> hasUserRSVPed(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking RSVP: $e');
      return false;
    }
  }

  /// Lấy danh sách attendees của event
  static Stream<List<Map<String, dynamic>>> getEventAttendees(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('attendees')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Cập nhật event
  static Future<void> updateEvent(
    String eventId, {
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? imageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (startDate != null) updates['start_date'] = startDate;
      if (endDate != null) updates['end_date'] = endDate;
      if (location != null) updates['location'] = location;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      updates['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('events').doc(eventId).update(updates);
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// Xóa event
  static Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  /// Tìm kiếm events theo keyword
  static Future<List<Map<String, dynamic>>> searchEvents(String keyword) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('title', isGreaterThanOrEqualTo: keyword)
          .where('title', isLessThan: keyword + 'z')
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  /// Lấy events của user (events mà user đã RSVP)
  static Stream<List<Map<String, dynamic>>> getUserEvents() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collectionGroup('attendees')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final eventIds = snapshot.docs
          .map((doc) => doc.reference.parent.parent?.id)
          .whereType<String>()
          .toList();

      final events = <Map<String, dynamic>>[];
      for (final eventId in eventIds) {
        final eventDoc = await _firestore.collection('events').doc(eventId).get();
        if (eventDoc.exists) {
          events.add({...eventDoc.data(), 'id': eventDoc.id});
        }
      }

      return events;
    });
  }
}

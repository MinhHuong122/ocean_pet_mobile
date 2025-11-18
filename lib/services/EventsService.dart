import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsService {
  // ==================== EVENT MANAGEMENT ====================

  /// Create a new event with type filtering
  static Future<String> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    String? imageUrl,
    String eventType = 'upcoming',
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final docRef = await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'location': location,
        'image_url': imageUrl,
        'event_type': eventType,
        'created_by': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'attendees_count': 0,
      });

      // Create attendee entry for event creator
      await docRef.collection('attendees').doc(user.uid).set({
        'user_id': user.uid,
        'joined_at': FieldValue.serverTimestamp(),
      });

      // Update attendees count
      await docRef.update({
        'attendees_count': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// Get events stream filtered by type (upcoming/ongoing/past)
  static Stream<List<Map<String, dynamic>>> getEventsByType(String eventType) {
    try {
      return FirebaseFirestore.instance
          .collection('events')
          .where('event_type', isEqualTo: eventType)
          .orderBy('start_date', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error getting events by type: $e');
      return Stream.value([]);
    }
  }

  /// Check if user has RSVP'd to an event
  static Future<bool> hasUserRSVPed(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .doc(user.uid)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking RSVP status: $e');
      return false;
    }
  }

  /// RSVP to an event with attendee count update (persisted in Firebase)
  static Future<void> rsvpEvent(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final db = FirebaseFirestore.instance;
      final eventRef = db.collection('events').doc(eventId);

      // Check if already RSVP'd
      final attendeeDoc =
          await eventRef.collection('attendees').doc(user.uid).get();
      if (attendeeDoc.exists) {
        throw Exception('Already RSVP\'d to this event');
      }

      await db.runTransaction((transaction) async {
        // Add attendee
        transaction.set(
          eventRef.collection('attendees').doc(user.uid),
          {
            'user_id': user.uid,
            'joined_at': FieldValue.serverTimestamp(),
          },
        );

        // Increment attendees count
        transaction.update(eventRef, {
          'attendees_count': FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('Error RSVP to event: $e');
      rethrow;
    }
  }

  /// Remove RSVP from an event with attendee count update (persisted in Firebase)
  static Future<void> unrsvpEvent(String eventId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final db = FirebaseFirestore.instance;
      final eventRef = db.collection('events').doc(eventId);

      await db.runTransaction((transaction) async {
        // Remove attendee
        transaction.delete(
          eventRef.collection('attendees').doc(user.uid),
        );

        // Decrement attendees count
        transaction.update(eventRef, {
          'attendees_count': FieldValue.increment(-1),
        });
      });
    } catch (e) {
      print('Error unRSVP from event: $e');
      rethrow;
    }
  }

  /// Get real-time stream of event attendees
  static Stream<List<Map<String, dynamic>>> getEventAttendees(String eventId) {
    try {
      return FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .orderBy('joined_at', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error getting event attendees: $e');
      return Stream.value([]);
    }
  }

  /// Get events the current user is attending (persisted across app restarts)
  static Stream<List<Map<String, dynamic>>> getUserEvents() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value([]);

      return FirebaseFirestore.instance
          .collectionGroup('attendees')
          .where('user_id', isEqualTo: user.uid)
          .snapshots()
          .asyncMap((attendeesSnapshot) async {
        final eventIds = attendeesSnapshot.docs
            .map((doc) => doc.reference.parent.parent?.id)
            .whereType<String>()
            .toList();

        if (eventIds.isEmpty) {
          return [];
        }

        final eventsSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .where(FieldPath.documentId, whereIn: eventIds)
            .get();

        return eventsSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error getting user events: $e');
      return Stream.value([]);
    }
  }

  /// Search events by keyword
  static Stream<List<Map<String, dynamic>>> searchEvents(String keyword) {
    try {
      if (keyword.isEmpty) {
        return FirebaseFirestore.instance
            .collection('events')
            .orderBy('start_date', descending: false)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
        });
      }

      return FirebaseFirestore.instance
          .collection('events')
          .where('title', isGreaterThanOrEqualTo: keyword)
          .where('title', isLessThan: keyword + 'z')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error searching events: $e');
      return Stream.value([]);
    }
  }
}

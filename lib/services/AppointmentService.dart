import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Service quản lý đặt lịch khám sức khỏe, tiêm phòng, tắm và spa
class AppointmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _currentUserId => _auth.currentUser?.uid;

  /// Tạo lịch khám/tiêm/tắm/spa mới
  static Future<String> createAppointment({
    required String petId,
    required String type, // 'health_checkup', 'vaccination', 'bath_spa', 'grooming'
    required DateTime appointmentDate,
    required TimeOfDay appointmentTime,
    String? vetName,
    String? vetClinic,
    String? location,
    String? notes,
    String? reminderTime, // '1day', '3days', '1week'
    bool isRecurring = false,
    String? recurringCycle, // 'monthly', 'quarterly', 'biannual', 'yearly'
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        appointmentTime.hour,
        appointmentTime.minute,
      );

      final docRef = await _firestore.collection('appointments').add({
        'user_id': userId,
        'pet_id': petId,
        'type': type,
        'appointment_date': Timestamp.fromDate(appointmentDateTime),
        'vet_name': vetName,
        'vet_clinic': vetClinic,
        'location': location,
        'notes': notes,
        'reminder_time': reminderTime,
        'is_recurring': isRecurring,
        'recurring_cycle': recurringCycle,
        'status': 'scheduled', // scheduled, completed, cancelled
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  /// Lấy danh sách lịch hẹn
  static Future<List<Map<String, dynamic>>> getAppointments({
    String? petId,
    String? type,
    bool? isUpcoming,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      Query query = _firestore
          .collection('appointments')
          .where('user_id', isEqualTo: userId);

      if (petId != null) {
        query = query.where('pet_id', isEqualTo: petId);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      final snapshot = await query.orderBy('appointment_date').get();

      List<Map<String, dynamic>> appointments = [];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final appointmentDate =
            (data['appointment_date'] as Timestamp).toDate();

        if (isUpcoming != null) {
          if (isUpcoming && appointmentDate.isBefore(now)) continue;
          if (!isUpcoming && appointmentDate.isAfter(now)) continue;
        }

        appointments.add({...data, 'id': doc.id});
      }

      return appointments;
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  /// Cập nhật lịch hẹn
  static Future<void> updateAppointment(
    String appointmentId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update(data);
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  /// Xóa lịch hẹn
  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  /// Hoàn thành lịch hẹn
  static Future<void> completeAppointment(String appointmentId) async {
    try {
      await updateAppointment(appointmentId, {'status': 'completed'});
    } catch (e) {
      print('Error completing appointment: $e');
      rethrow;
    }
  }

  /// Hủy lịch hẹn
  static Future<void> cancelAppointment(String appointmentId) async {
    try {
      await updateAppointment(appointmentId, {'status': 'cancelled'});
    } catch (e) {
      print('Error cancelling appointment: $e');
      rethrow;
    }
  }

  /// Stream để theo dõi lịch hẹn sắp tới
  static Stream<List<Map<String, dynamic>>> watchUpcomingAppointments(
    String petId,
  ) {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not logged in');

      final now = DateTime.now();

      return _firestore
          .collection('appointments')
          .where('user_id', isEqualTo: userId)
          .where('pet_id', isEqualTo: petId)
          .where('appointment_date',
              isGreaterThan: Timestamp.fromDate(now))
          .where('status', isEqualTo: 'scheduled')
          .orderBy('appointment_date')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList());
    } catch (e) {
      print('Error watching appointments: $e');
      return Stream.value([]);
    }
  }
}

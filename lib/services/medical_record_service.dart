// lib/services/medical_record_service.dart - Firebase Service for Medical Records
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_models.dart';

class MedicalRecordService {
  static final _firestore = FirebaseFirestore.instance;
  static const String _collection = 'medical-records';

  /// Save complete medical record to Firebase
  static Future<void> saveMedicalRecord(CompleteMedicalRecord record) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(record.recordId)
          .set(record.toMap(), SetOptions(merge: true));
      print('✅ Medical record ${record.recordId} saved to Firebase');
    } catch (e) {
      print('❌ Error saving medical record: $e');
      rethrow;
    }
  }

  /// Get medical record by ID
  static Future<CompleteMedicalRecord?> getMedicalRecord(String recordId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(recordId)
          .get();

      if (!doc.exists) {
        print('⚠️ Medical record $recordId not found');
        return null;
      }

      return CompleteMedicalRecord.fromMap(doc.data() ?? {});
    } catch (e) {
      print('❌ Error retrieving medical record: $e');
      rethrow;
    }
  }

  /// Stream medical record updates (real-time)
  static Stream<CompleteMedicalRecord?> getMedicalRecordStream(String recordId) {
    return _firestore
        .collection(_collection)
        .doc(recordId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return CompleteMedicalRecord.fromMap(doc.data() ?? {});
    });
  }

  /// Get all medical records for owner
  static Future<List<CompleteMedicalRecord>> getOwnerMedicalRecords(String ownerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return querySnapshot.docs
          .map((doc) => CompleteMedicalRecord.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error retrieving owner records: $e');
      rethrow;
    }
  }

  /// Add vaccination record to medical record
  static Future<void> addVaccinationRecord(
    String recordId,
    VaccinationRecord vaccination,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({
        'vaccinations': FieldValue.arrayUnion([vaccination.toMap()])
      });
      print('✅ Vaccination record added to $recordId');
    } catch (e) {
      print('❌ Error adding vaccination: $e');
      rethrow;
    }
  }

  /// Add medical consultation record
  static Future<void> addConsultationRecord(
    String recordId,
    MedicalConsultationRecord consultation,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({
        'consultations': FieldValue.arrayUnion([consultation.toMap()])
      });
      print('✅ Consultation record added to $recordId');
    } catch (e) {
      print('❌ Error adding consultation: $e');
      rethrow;
    }
  }

  /// Add test result record
  static Future<void> addTestResultRecord(
    String recordId,
    TestResultRecord testResult,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({
        'testResults': FieldValue.arrayUnion([testResult.toMap()])
      });
      print('✅ Test result record added to $recordId');
    } catch (e) {
      print('❌ Error adding test result: $e');
      rethrow;
    }
  }

  /// Add surgery record
  static Future<void> addSurgeryRecord(
    String recordId,
    SurgeryRecord surgery,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({
        'surgeries': FieldValue.arrayUnion([surgery.toMap()])
      });
      print('✅ Surgery record added to $recordId');
    } catch (e) {
      print('❌ Error adding surgery: $e');
      rethrow;
    }
  }

  /// Add health monitoring record
  static Future<void> addHealthMonitoringRecord(
    String recordId,
    HealthMonitoringRecord monitoring,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({
        'healthMonitoring': FieldValue.arrayUnion([monitoring.toMap()])
      });
      print('✅ Health monitoring record added to $recordId');
    } catch (e) {
      print('❌ Error adding monitoring: $e');
      rethrow;
    }
  }

  /// Update basic pet info
  static Future<void> updatePetBasicInfo(
    String recordId,
    PetBasicInfo basicInfo,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({'basicInfo': basicInfo.toMap()});
      print('✅ Pet basic info updated for $recordId');
    } catch (e) {
      print('❌ Error updating basic info: $e');
      rethrow;
    }
  }

  /// Update owner info
  static Future<void> updateOwnerInfo(
    String recordId,
    OwnerInfo ownerInfo,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({'ownerInfo': ownerInfo.toMap()});
      print('✅ Owner info updated for $recordId');
    } catch (e) {
      print('❌ Error updating owner info: $e');
      rethrow;
    }
  }

  /// Add microchip info
  static Future<void> setMicrochipInfo(
    String recordId,
    MicrochipInfo microchipInfo,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({'microchipInfo': microchipInfo.toMap()});
      print('✅ Microchip info set for $recordId');
    } catch (e) {
      print('❌ Error setting microchip: $e');
      rethrow;
    }
  }

  /// Add blood type info
  static Future<void> setBloodTypeInfo(
    String recordId,
    BloodTypeInfo bloodTypeInfo,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({'bloodTypeInfo': bloodTypeInfo.toMap()});
      print('✅ Blood type info set for $recordId');
    } catch (e) {
      print('❌ Error setting blood type: $e');
      rethrow;
    }
  }

  /// Delete vaccination record
  static Future<void> deleteVaccinationRecord(
    String recordId,
    VaccinationRecord vaccination,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(recordId)
          .update({
        'vaccinations': FieldValue.arrayRemove([vaccination.toMap()])
      });
      print('✅ Vaccination record deleted from $recordId');
    } catch (e) {
      print('❌ Error deleting vaccination: $e');
      rethrow;
    }
  }

  /// Delete entire medical record
  static Future<void> deleteMedicalRecord(String recordId) async {
    try {
      await _firestore.collection(_collection).doc(recordId).delete();
      print('✅ Medical record $recordId deleted');
    } catch (e) {
      print('❌ Error deleting medical record: $e');
      rethrow;
    }
  }

  /// Get upcoming vaccinations (due within 30 days)
  static Future<List<VaccinationRecord>> getUpcomingVaccinations(String recordId) async {
    try {
      final record = await getMedicalRecord(recordId);
      if (record == null) return [];

      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      return record.vaccinations
          .where((vac) =>
              vac.expiryDate.isAfter(now) &&
              vac.expiryDate.isBefore(thirtyDaysLater))
          .toList();
    } catch (e) {
      print('❌ Error getting upcoming vaccinations: $e');
      return [];
    }
  }

  /// Get expired vaccinations
  static Future<List<VaccinationRecord>> getExpiredVaccinations(String recordId) async {
    try {
      final record = await getMedicalRecord(recordId);
      if (record == null) return [];

      final now = DateTime.now();
      return record.vaccinations
          .where((vac) => vac.expiryDate.isBefore(now))
          .toList();
    } catch (e) {
      print('❌ Error getting expired vaccinations: $e');
      return [];
    }
  }

  /// Calculate health score (0-100)
  static Future<int> calculateHealthScore(String recordId) async {
    try {
      final record = await getMedicalRecord(recordId);
      if (record == null) return 0;

      int score = 0;
      final now = DateTime.now();

      // 1. Vaccination status (25 points)
      final activeVaccinations =
          record.vaccinations.where((v) => v.expiryDate.isAfter(now)).length;
      if (activeVaccinations > 0) score += 25;

      // 2. Recent checkup within 6 months (25 points)
      final sixMonthsAgo = now.subtract(const Duration(days: 180));
      final hasRecentCheckup = record.consultations.any(
        (c) => c.consultationDate.isAfter(sixMonthsAgo) && c.isDischarged,
      );
      if (hasRecentCheckup) score += 25;

      // 3. Recent test results within 12 months (25 points)
      final oneYearAgo = now.subtract(const Duration(days: 365));
      final hasRecentTests =
          record.testResults.any((t) => t.testDate.isAfter(oneYearAgo));
      if (hasRecentTests) score += 25;

      // 4. Healthy weight (25 points)
      if (record.healthMonitoring.isNotEmpty) {
        final latestWeight = record.healthMonitoring.last.weight;
        // Simplified: assume healthy if weight recorded
        if (latestWeight != null && latestWeight > 0) score += 25;
      }

      return score;
    } catch (e) {
      print('❌ Error calculating health score: $e');
      return 0;
    }
  }

  /// Get last N health monitoring records for chart
  static Future<List<HealthMonitoringRecord>> getHealthMonitoringChart(
    String recordId, {
    int limit = 12,
  }) async {
    try {
      final record = await getMedicalRecord(recordId);
      if (record == null) return [];

      return record.healthMonitoring
          .take(limit)
          .toList()
          .reversed
          .toList(); // Most recent first
    } catch (e) {
      print('❌ Error getting monitoring chart: $e');
      return [];
    }
  }

  /// Search medical records by pet name
  static Future<List<CompleteMedicalRecord>> searchByPetName(
    String searchTerm,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('basicInfo.name', isGreaterThanOrEqualTo: searchTerm)
          .where('basicInfo.name', isLessThan: searchTerm + 'z')
          .get();

      return querySnapshot.docs
          .map((doc) => CompleteMedicalRecord.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error searching records: $e');
      return [];
    }
  }
}

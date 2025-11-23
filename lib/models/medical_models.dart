// lib/models/medical_models.dart - Complete Medical Record Models
import 'package:cloud_firestore/cloud_firestore.dart';

/// Basic Pet Information (bắt buộc)
class PetBasicInfo {
  final String petId;
  final String name;
  final String breed;
  final String coatColor;
  final String gender; // Đực/Cái
  final DateTime dateOfBirth; // hoặc estimatedAge
  final DateTime adoptionDate;
  final String? photoFrontUrl;
  final String? photoFullBodyUrl;
  final DateTime? photoUpdatedDate;

  PetBasicInfo({
    required this.petId,
    required this.name,
    required this.breed,
    required this.coatColor,
    required this.gender,
    required this.dateOfBirth,
    required this.adoptionDate,
    this.photoFrontUrl,
    this.photoFullBodyUrl,
    this.photoUpdatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'name': name,
      'breed': breed,
      'coatColor': coatColor,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'adoptionDate': adoptionDate,
      'photoFrontUrl': photoFrontUrl,
      'photoFullBodyUrl': photoFullBodyUrl,
      'photoUpdatedDate': photoUpdatedDate,
    };
  }

  factory PetBasicInfo.fromMap(Map<String, dynamic> map) {
    return PetBasicInfo(
      petId: map['petId'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      coatColor: map['coatColor'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adoptionDate: (map['adoptionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoFrontUrl: map['photoFrontUrl'],
      photoFullBodyUrl: map['photoFullBodyUrl'],
      photoUpdatedDate: (map['photoUpdatedDate'] as Timestamp?)?.toDate(),
    );
  }
}

/// Owner Information
class OwnerInfo {
  final String ownerId;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String city;

  OwnerInfo({
    required this.ownerId,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'city': city,
    };
  }

  factory OwnerInfo.fromMap(Map<String, dynamic> map) {
    return OwnerInfo(
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
    );
  }
}

/// Microchip Information (quan trọng khi lạc)
class MicrochipInfo {
  final String microchipNumber; // 15 số
  final DateTime implantDate;
  final String implantLocation; // gáy/cổ trái
  final String? vetClinic;
  final String? notes;

  MicrochipInfo({
    required this.microchipNumber,
    required this.implantDate,
    required this.implantLocation,
    this.vetClinic,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'microchipNumber': microchipNumber,
      'implantDate': implantDate,
      'implantLocation': implantLocation,
      'vetClinic': vetClinic,
      'notes': notes,
    };
  }

  factory MicrochipInfo.fromMap(Map<String, dynamic> map) {
    return MicrochipInfo(
      microchipNumber: map['microchipNumber'] ?? '',
      implantDate: (map['implantDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      implantLocation: map['implantLocation'] ?? '',
      vetClinic: map['vetClinic'],
      notes: map['notes'],
    );
  }
}

/// Blood Type Information (DEA for dogs)
class BloodTypeInfo {
  final String type; // DEA 1.1+, DEA 1.1–, DEA 1.2, etc.
  final DateTime testedDate;
  final String? vetClinic;

  BloodTypeInfo({
    required this.type,
    required this.testedDate,
    this.vetClinic,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'testedDate': testedDate,
      'vetClinic': vetClinic,
    };
  }

  factory BloodTypeInfo.fromMap(Map<String, dynamic> map) {
    return BloodTypeInfo(
      type: map['type'] ?? '',
      testedDate: (map['testedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vetClinic: map['vetClinic'],
    );
  }
}

/// Vaccination Record
class VaccinationRecord {
  final String id;
  final String vaccineName;
  final DateTime vaccinationDate;
  final DateTime expiryDate;
  final String? vetName;
  final String? vetClinic;
  final String type; // Dại, 5-bệnh, Giun sán, Ve rận, etc.
  final String? notes;
  final String? certificateFileUrl; // Giấy chứng nhận

  VaccinationRecord({
    required this.id,
    required this.vaccineName,
    required this.vaccinationDate,
    required this.expiryDate,
    this.vetName,
    this.vetClinic,
    required this.type,
    this.notes,
    this.certificateFileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'vaccinationDate': vaccinationDate,
      'expiryDate': expiryDate,
      'vetName': vetName,
      'vetClinic': vetClinic,
      'type': type,
      'notes': notes,
      'certificateFileUrl': certificateFileUrl,
    };
  }

  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      id: map['id'] ?? '',
      vaccineName: map['vaccineName'] ?? '',
      vaccinationDate: (map['vaccinationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vetName: map['vetName'],
      vetClinic: map['vetClinic'],
      type: map['type'] ?? '',
      notes: map['notes'],
      certificateFileUrl: map['certificateFileUrl'],
    );
  }
}

/// Medical Consultation Record
class MedicalConsultationRecord {
  final String id;
  final DateTime consultationDate;
  final String? symptoms;
  final String? diagnosis;
  final String? treatment;
  final String? prescription;
  final String vetName;
  final String vetClinic;
  final String? notes;
  final List<String> attachmentUrls; // PDF đơn thuốc, ảnh, video
  final bool isDischarged;

  MedicalConsultationRecord({
    required this.id,
    required this.consultationDate,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    this.prescription,
    required this.vetName,
    required this.vetClinic,
    this.notes,
    required this.attachmentUrls,
    this.isDischarged = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultationDate': consultationDate,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescription': prescription,
      'vetName': vetName,
      'vetClinic': vetClinic,
      'notes': notes,
      'attachmentUrls': attachmentUrls,
      'isDischarged': isDischarged,
    };
  }

  factory MedicalConsultationRecord.fromMap(Map<String, dynamic> map) {
    return MedicalConsultationRecord(
      id: map['id'] ?? '',
      consultationDate: (map['consultationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      symptoms: map['symptoms'],
      diagnosis: map['diagnosis'],
      treatment: map['treatment'],
      prescription: map['prescription'],
      vetName: map['vetName'] ?? '',
      vetClinic: map['vetClinic'] ?? '',
      notes: map['notes'],
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
      isDischarged: map['isDischarged'] ?? false,
    );
  }
}

/// Test Result Record
class TestResultRecord {
  final String id;
  final DateTime testDate;
  final String testType; // CBC, Sinh hóa thận gan, Xét nghiệm phân, etc.
  final String? testName;
  final Map<String, dynamic>? results; // Chi tiết kết quả
  final List<String> documentUrls; // Ảnh PDF, hình ảnh xét nghiệm
  final String? notes;

  TestResultRecord({
    required this.id,
    required this.testDate,
    required this.testType,
    this.testName,
    this.results,
    required this.documentUrls,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testDate': testDate,
      'testType': testType,
      'testName': testName,
      'results': results,
      'documentUrls': documentUrls,
      'notes': notes,
    };
  }

  factory TestResultRecord.fromMap(Map<String, dynamic> map) {
    return TestResultRecord(
      id: map['id'] ?? '',
      testDate: (map['testDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      testType: map['testType'] ?? '',
      testName: map['testName'],
      results: map['results'] as Map<String, dynamic>?,
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      notes: map['notes'],
    );
  }
}

/// Surgery/Procedure Record
class SurgeryRecord {
  final String id;
  final DateTime surgeryDate;
  final String surgeryType; // Thiến, Triệt sản, Nhổ răng, etc.
  final String vetName;
  final String vetClinic;
  final String? notes;
  final List<String> attachmentUrls;

  SurgeryRecord({
    required this.id,
    required this.surgeryDate,
    required this.surgeryType,
    required this.vetName,
    required this.vetClinic,
    this.notes,
    required this.attachmentUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surgeryDate': surgeryDate,
      'surgeryType': surgeryType,
      'vetName': vetName,
      'vetClinic': vetClinic,
      'notes': notes,
      'attachmentUrls': attachmentUrls,
    };
  }

  factory SurgeryRecord.fromMap(Map<String, dynamic> map) {
    return SurgeryRecord(
      id: map['id'] ?? '',
      surgeryDate: (map['surgeryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      surgeryType: map['surgeryType'] ?? '',
      vetName: map['vetName'] ?? '',
      vetClinic: map['vetClinic'] ?? '',
      notes: map['notes'],
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
    );
  }
}

/// Insurance Information
class InsuranceInfo {
  final String insuranceId;
  final String insuranceCompany;
  final String policyNumber;
  final String packageName;
  final DateTime startDate;
  final DateTime endDate;
  final String? contractFileUrl;

  InsuranceInfo({
    required this.insuranceId,
    required this.insuranceCompany,
    required this.policyNumber,
    required this.packageName,
    required this.startDate,
    required this.endDate,
    this.contractFileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'insuranceId': insuranceId,
      'insuranceCompany': insuranceCompany,
      'policyNumber': policyNumber,
      'packageName': packageName,
      'startDate': startDate,
      'endDate': endDate,
      'contractFileUrl': contractFileUrl,
    };
  }

  factory InsuranceInfo.fromMap(Map<String, dynamic> map) {
    return InsuranceInfo(
      insuranceId: map['insuranceId'] ?? '',
      insuranceCompany: map['insuranceCompany'] ?? '',
      policyNumber: map['policyNumber'] ?? '',
      packageName: map['packageName'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contractFileUrl: map['contractFileUrl'],
    );
  }
}

/// Health Monitoring Record (Theo dõi sức khỏe định kỳ)
class HealthMonitoringRecord {
  final String id;
  final DateTime recordDate;
  final double? weight; // kg
  final double? temperature; // °C
  final int? heartRate; // nhịp tim
  final int? respiratoryRate; // nhịp thở
  final String? notes;

  HealthMonitoringRecord({
    required this.id,
    required this.recordDate,
    this.weight,
    this.temperature,
    this.heartRate,
    this.respiratoryRate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recordDate': recordDate,
      'weight': weight,
      'temperature': temperature,
      'heartRate': heartRate,
      'respiratoryRate': respiratoryRate,
      'notes': notes,
    };
  }

  factory HealthMonitoringRecord.fromMap(Map<String, dynamic> map) {
    return HealthMonitoringRecord(
      id: map['id'] ?? '',
      recordDate: (map['recordDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weight: (map['weight'] as num?)?.toDouble(),
      temperature: (map['temperature'] as num?)?.toDouble(),
      heartRate: map['heartRate'] as int?,
      respiratoryRate: map['respiratoryRate'] as int?,
      notes: map['notes'],
    );
  }
}

/// Legal Documents
class LegalDocument {
  final String id;
  final String documentType; // Rabies certificate, Pet Passport, Microchip registration
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String? issuingAuthority;
  final String fileUrl;

  LegalDocument({
    required this.id,
    required this.documentType,
    required this.issuedDate,
    this.expiryDate,
    this.issuingAuthority,
    required this.fileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentType': documentType,
      'issuedDate': issuedDate,
      'expiryDate': expiryDate,
      'issuingAuthority': issuingAuthority,
      'fileUrl': fileUrl,
    };
  }

  factory LegalDocument.fromMap(Map<String, dynamic> map) {
    return LegalDocument(
      id: map['id'] ?? '',
      documentType: map['documentType'] ?? '',
      issuedDate: (map['issuedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      issuingAuthority: map['issuingAuthority'],
      fileUrl: map['fileUrl'] ?? '',
    );
  }
}

/// Complete Medical Record (Tổng hợp toàn bộ)
class CompleteMedicalRecord {
  final String recordId;
  final String petId;
  final String ownerId;
  final DateTime createdDate;
  final DateTime lastUpdatedDate;
  
  final PetBasicInfo basicInfo;
  final OwnerInfo ownerInfo;
  final MicrochipInfo? microchipInfo;
  final BloodTypeInfo? bloodTypeInfo;
  final List<VaccinationRecord> vaccinations;
  final List<MedicalConsultationRecord> consultations;
  final List<TestResultRecord> testResults;
  final List<SurgeryRecord> surgeries;
  final List<HealthMonitoringRecord> healthMonitoring;
  final List<LegalDocument> legalDocuments;
  final InsuranceInfo? insuranceInfo;

  CompleteMedicalRecord({
    required this.recordId,
    required this.petId,
    required this.ownerId,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.basicInfo,
    required this.ownerInfo,
    this.microchipInfo,
    this.bloodTypeInfo,
    required this.vaccinations,
    required this.consultations,
    required this.testResults,
    required this.surgeries,
    required this.healthMonitoring,
    required this.legalDocuments,
    this.insuranceInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'petId': petId,
      'ownerId': ownerId,
      'createdDate': createdDate,
      'lastUpdatedDate': lastUpdatedDate,
      'basicInfo': basicInfo.toMap(),
      'ownerInfo': ownerInfo.toMap(),
      'microchipInfo': microchipInfo?.toMap(),
      'bloodTypeInfo': bloodTypeInfo?.toMap(),
      'vaccinations': vaccinations.map((v) => v.toMap()).toList(),
      'consultations': consultations.map((c) => c.toMap()).toList(),
      'testResults': testResults.map((t) => t.toMap()).toList(),
      'surgeries': surgeries.map((s) => s.toMap()).toList(),
      'healthMonitoring': healthMonitoring.map((h) => h.toMap()).toList(),
      'legalDocuments': legalDocuments.map((d) => d.toMap()).toList(),
      'insuranceInfo': insuranceInfo?.toMap(),
    };
  }

  factory CompleteMedicalRecord.fromMap(Map<String, dynamic> map) {
    return CompleteMedicalRecord(
      recordId: map['recordId'] ?? '',
      petId: map['petId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      createdDate: (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdatedDate: (map['lastUpdatedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      basicInfo: PetBasicInfo.fromMap(map['basicInfo'] ?? {}),
      ownerInfo: OwnerInfo.fromMap(map['ownerInfo'] ?? {}),
      microchipInfo: map['microchipInfo'] != null ? MicrochipInfo.fromMap(map['microchipInfo']) : null,
      bloodTypeInfo: map['bloodTypeInfo'] != null ? BloodTypeInfo.fromMap(map['bloodTypeInfo']) : null,
      vaccinations: (map['vaccinations'] as List<dynamic>?)?.map((v) => VaccinationRecord.fromMap(v as Map<String, dynamic>)).toList() ?? [],
      consultations: (map['consultations'] as List<dynamic>?)?.map((c) => MedicalConsultationRecord.fromMap(c as Map<String, dynamic>)).toList() ?? [],
      testResults: (map['testResults'] as List<dynamic>?)?.map((t) => TestResultRecord.fromMap(t as Map<String, dynamic>)).toList() ?? [],
      surgeries: (map['surgeries'] as List<dynamic>?)?.map((s) => SurgeryRecord.fromMap(s as Map<String, dynamic>)).toList() ?? [],
      healthMonitoring: (map['healthMonitoring'] as List<dynamic>?)?.map((h) => HealthMonitoringRecord.fromMap(h as Map<String, dynamic>)).toList() ?? [],
      legalDocuments: (map['legalDocuments'] as List<dynamic>?)?.map((d) => LegalDocument.fromMap(d as Map<String, dynamic>)).toList() ?? [],
      insuranceInfo: map['insuranceInfo'] != null ? InsuranceInfo.fromMap(map['insuranceInfo']) : null,
    );
  }
}

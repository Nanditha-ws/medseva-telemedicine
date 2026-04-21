/// Medical Record Model
library;

class MedicalRecordModel {
  final String id;
  final String patientId;
  final String? doctorId;
  final String recordType;
  final String title;
  final String? description;
  final String? diagnosis;
  final List<Medication>? medications;
  final List<LabResult>? labResults;
  final VitalSigns? vitals;
  final List<Attachment>? attachments;
  final List<String>? tags;
  final String? notes;
  final String? recordDate;

  MedicalRecordModel({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.recordType,
    required this.title,
    this.description,
    this.diagnosis,
    this.medications,
    this.labResults,
    this.vitals,
    this.attachments,
    this.tags,
    this.notes,
    this.recordDate,
  });

  String get recordTypeDisplay {
    switch (recordType) {
      case 'lab_report': return 'Lab Report';
      case 'prescription': return 'Prescription';
      case 'diagnosis': return 'Diagnosis';
      case 'imaging': return 'Imaging';
      case 'discharge_summary': return 'Discharge Summary';
      case 'vaccination': return 'Vaccination';
      case 'surgical_report': return 'Surgical Report';
      default: return 'Other';
    }
  }

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'],
      recordType: json['record_type'] ?? 'other',
      title: json['title'] ?? '',
      description: json['description'],
      diagnosis: json['diagnosis'],
      medications: json['medications'] != null
          ? (json['medications'] as List).map((e) => Medication.fromJson(e)).toList()
          : null,
      labResults: json['lab_results'] != null
          ? (json['lab_results'] as List).map((e) => LabResult.fromJson(e)).toList()
          : null,
      vitals: json['vitals'] != null ? VitalSigns.fromJson(json['vitals']) : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List).map((e) => Attachment.fromJson(e)).toList()
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      notes: json['notes'],
      recordDate: json['record_date'],
    );
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String? duration;
  final String? instructions;

  Medication({required this.name, required this.dosage, required this.frequency, this.duration, this.instructions});

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'],
      instructions: json['instructions'],
    );
  }
}

class LabResult {
  final String testName;
  final String value;
  final String? unit;
  final String? referenceRange;
  final String status;

  LabResult({required this.testName, required this.value, this.unit, this.referenceRange, this.status = 'normal'});

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      testName: json['test_name'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'],
      referenceRange: json['reference_range'],
      status: json['status'] ?? 'normal',
    );
  }
}

class VitalSigns {
  final String? bloodPressure;
  final int? heartRate;
  final double? temperature;
  final double? weight;
  final double? height;
  final int? spo2;
  final double? bloodSugar;

  VitalSigns({this.bloodPressure, this.heartRate, this.temperature, this.weight, this.height, this.spo2, this.bloodSugar});

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      bloodPressure: json['blood_pressure'],
      heartRate: json['heart_rate'],
      temperature: json['temperature']?.toDouble(),
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      spo2: json['spo2'],
      bloodSugar: json['blood_sugar']?.toDouble(),
    );
  }
}

class Attachment {
  final String filename;
  final String? originalName;
  final String? fileType;
  final int? fileSize;
  final String fileUrl;

  Attachment({required this.filename, this.originalName, this.fileType, this.fileSize, required this.fileUrl});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      filename: json['filename'] ?? '',
      originalName: json['original_name'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      fileUrl: json['file_url'] ?? '',
    );
  }
}

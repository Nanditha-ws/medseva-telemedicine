/// Appointment Model
library;

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String? hospitalId;
  final String appointmentDate;
  final String appointmentTime;
  final int durationMinutes;
  final String type;
  final String status;
  final String? reason;
  final String? symptoms;
  final String? notes;
  final String? doctorNotes;
  final double? consultationFee;
  final String? paymentStatus;
  final String? cancellationReason;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? doctor;
  final Map<String, dynamic>? hospital;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.hospitalId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.durationMinutes = 30,
    this.type = 'in_person',
    this.status = 'pending',
    this.reason,
    this.symptoms,
    this.notes,
    this.doctorNotes,
    this.consultationFee,
    this.paymentStatus,
    this.cancellationReason,
    this.patient,
    this.doctor,
    this.hospital,
  });

  String get doctorName {
    if (doctor != null) {
      return '${doctor!['first_name'] ?? ''} ${doctor!['last_name'] ?? ''}';
    }
    return 'Unknown Doctor';
  }

  String get patientName {
    if (patient != null) {
      return '${patient!['first_name'] ?? ''} ${patient!['last_name'] ?? ''}';
    }
    return 'Unknown Patient';
  }

  String get hospitalName => hospital?['name'] ?? '';

  String get statusDisplay {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'no_show': return 'No Show';
      default: return status;
    }
  }

  String get typeDisplay {
    switch (type) {
      case 'in_person': return 'In Person';
      case 'video_call': return 'Video Call';
      case 'phone_call': return 'Phone Call';
      default: return type;
    }
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      hospitalId: json['hospital_id'],
      appointmentDate: json['appointment_date'] ?? '',
      appointmentTime: json['appointment_time'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 30,
      type: json['type'] ?? 'in_person',
      status: json['status'] ?? 'pending',
      reason: json['reason'],
      symptoms: json['symptoms'],
      notes: json['notes'],
      doctorNotes: json['doctor_notes'],
      consultationFee: double.tryParse(json['consultation_fee']?.toString() ?? '0'),
      paymentStatus: json['payment_status'],
      cancellationReason: json['cancellation_reason'],
      patient: json['patient'],
      doctor: json['doctor'],
      hospital: json['hospital'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'hospital_id': hospitalId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'duration_minutes': durationMinutes,
      'type': type,
      'reason': reason,
      'symptoms': symptoms,
    };
  }
}

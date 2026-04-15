/**
 * MongoDB Model: Medical Record
 * Stores unstructured medical data like reports, diagnoses, and prescriptions
 */

const mongoose = require('mongoose');

const medicalRecordSchema = new mongoose.Schema({
  patient_id: {
    type: String, // UUID from PostgreSQL
    required: true,
    index: true
  },
  doctor_id: {
    type: String,
    required: false,
    index: true
  },
  hospital_id: {
    type: String,
    required: false
  },
  record_type: {
    type: String,
    enum: ['lab_report', 'prescription', 'diagnosis', 'imaging', 'discharge_summary', 'vaccination', 'surgical_report', 'other'],
    required: true,
    index: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  diagnosis: {
    type: String,
    default: ''
  },
  // For prescriptions
  medications: [{
    name: String,
    dosage: String,
    frequency: String,
    duration: String,
    instructions: String
  }],
  // For lab reports
  lab_results: [{
    test_name: String,
    value: String,
    unit: String,
    reference_range: String,
    status: {
      type: String,
      enum: ['normal', 'abnormal', 'critical'],
      default: 'normal'
    }
  }],
  // Vital signs
  vitals: {
    blood_pressure: String,
    heart_rate: Number,
    temperature: Number,
    weight: Number,
    height: Number,
    spo2: Number,
    blood_sugar: Number
  },
  // File attachments
  attachments: [{
    filename: String,
    original_name: String,
    file_type: String,
    file_size: Number,
    file_url: String,
    uploaded_at: {
      type: Date,
      default: Date.now
    }
  }],
  // Tags for searchability
  tags: [{
    type: String
  }],
  notes: {
    type: String,
    default: ''
  },
  is_private: {
    type: Boolean,
    default: false
  },
  shared_with: [{
    type: String // User IDs who have access
  }],
  record_date: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  collection: 'medical_records'
});

// Indexes for efficient querying
medicalRecordSchema.index({ patient_id: 1, record_type: 1 });
medicalRecordSchema.index({ patient_id: 1, record_date: -1 });
medicalRecordSchema.index({ tags: 1 });
medicalRecordSchema.index({ '$**': 'text' }); // Full text search

const MedicalRecord = mongoose.model('MedicalRecord', medicalRecordSchema);

module.exports = MedicalRecord;

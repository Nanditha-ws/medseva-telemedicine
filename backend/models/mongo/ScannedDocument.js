/**
 * MongoDB Model: Scanned Document
 * Stores documents processed by OpenCV scanner
 */

const mongoose = require('mongoose');

const scannedDocumentSchema = new mongoose.Schema({
  user_id: {
    type: String,
    required: true,
    index: true
  },
  title: {
    type: String,
    required: true
  },
  document_type: {
    type: String,
    enum: ['prescription', 'lab_report', 'medical_bill', 'insurance_card', 'id_card', 'other'],
    default: 'other'
  },
  // Original image
  original_image: {
    filename: String,
    file_url: String,
    file_size: Number,
    dimensions: {
      width: Number,
      height: Number
    }
  },
  // Processed/scanned image
  processed_image: {
    filename: String,
    file_url: String,
    file_size: Number,
    dimensions: {
      width: Number,
      height: Number
    }
  },
  // Processing metadata
  processing_info: {
    edge_detection_method: {
      type: String,
      default: 'canny'
    },
    perspective_corrected: {
      type: Boolean,
      default: false
    },
    corners_detected: [{
      x: Number,
      y: Number
    }],
    processing_time_ms: Number,
    enhancement_applied: {
      type: Boolean,
      default: true
    }
  },
  // Extracted text (OCR - future enhancement)
  extracted_text: {
    type: String,
    default: ''
  },
  // Link to medical record if applicable
  medical_record_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MedicalRecord',
    default: null
  },
  tags: [{
    type: String
  }],
  notes: {
    type: String,
    default: ''
  }
}, {
  timestamps: true,
  collection: 'scanned_documents'
});

scannedDocumentSchema.index({ user_id: 1, createdAt: -1 });
scannedDocumentSchema.index({ document_type: 1 });

const ScannedDocument = mongoose.model('ScannedDocument', scannedDocumentSchema);

module.exports = ScannedDocument;

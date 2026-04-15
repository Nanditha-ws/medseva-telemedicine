/**
 * Medical Record Controller
 * Handles medical record CRUD operations using MongoDB
 */

const MedicalRecord = require('../models/mongo/MedicalRecord');

/**
 * Create a new medical record
 * POST /api/medical-records
 */
exports.createRecord = async (req, res, next) => {
  try {
    const recordData = {
      ...req.body,
      patient_id: req.body.patient_id || req.user.id
    };

    // If doctor is creating record for patient
    if (req.user.role === 'doctor') {
      recordData.doctor_id = req.user.id;
    }

    // Handle file attachments
    if (req.files && req.files.length > 0) {
      recordData.attachments = req.files.map(file => ({
        filename: file.filename,
        original_name: file.originalname,
        file_type: file.mimetype,
        file_size: file.size,
        file_url: `/uploads/${file.mimetype.startsWith('image/') ? 'images' : 'documents'}/${file.filename}`
      }));
    }

    const record = await MedicalRecord.create(recordData);

    res.status(201).json({
      status: 'success',
      message: 'Medical record created successfully',
      data: { record }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get all medical records for current user
 * GET /api/medical-records
 */
exports.getRecords = async (req, res, next) => {
  try {
    const { record_type, page = 1, limit = 20, search } = req.query;
    const skip = (page - 1) * limit;

    let query = {};

    // Patients see their own records
    if (req.user.role === 'patient') {
      query.patient_id = req.user.id;
    }
    // Doctors see records they created or shared with them
    if (req.user.role === 'doctor') {
      query.$or = [
        { doctor_id: req.user.id },
        { shared_with: req.user.id }
      ];
    }

    if (record_type) query.record_type = record_type;
    if (search) {
      query.$text = { $search: search };
    }

    const total = await MedicalRecord.countDocuments(query);
    const records = await MedicalRecord.find(query)
      .sort({ record_date: -1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit));

    res.json({
      status: 'success',
      data: {
        records,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get a single medical record
 * GET /api/medical-records/:id
 */
exports.getRecordById = async (req, res, next) => {
  try {
    const record = await MedicalRecord.findById(req.params.id);

    if (!record) {
      return res.status(404).json({
        status: 'error',
        message: 'Medical record not found'
      });
    }

    // Authorization check
    if (req.user.role === 'patient' && record.patient_id !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Access denied' });
    }

    res.json({
      status: 'success',
      data: { record }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Update a medical record
 * PUT /api/medical-records/:id
 */
exports.updateRecord = async (req, res, next) => {
  try {
    const record = await MedicalRecord.findById(req.params.id);

    if (!record) {
      return res.status(404).json({
        status: 'error',
        message: 'Medical record not found'
      });
    }

    // Handle new file uploads
    if (req.files && req.files.length > 0) {
      const newAttachments = req.files.map(file => ({
        filename: file.filename,
        original_name: file.originalname,
        file_type: file.mimetype,
        file_size: file.size,
        file_url: `/uploads/${file.mimetype.startsWith('image/') ? 'images' : 'documents'}/${file.filename}`
      }));
      req.body.attachments = [...(record.attachments || []), ...newAttachments];
    }

    const updatedRecord = await MedicalRecord.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    );

    res.json({
      status: 'success',
      message: 'Medical record updated successfully',
      data: { record: updatedRecord }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Delete a medical record
 * DELETE /api/medical-records/:id
 */
exports.deleteRecord = async (req, res, next) => {
  try {
    const record = await MedicalRecord.findById(req.params.id);

    if (!record) {
      return res.status(404).json({
        status: 'error',
        message: 'Medical record not found'
      });
    }

    if (req.user.role === 'patient' && record.patient_id !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Access denied' });
    }

    await MedicalRecord.findByIdAndDelete(req.params.id);

    res.json({
      status: 'success',
      message: 'Medical record deleted successfully'
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Share a medical record with a doctor
 * POST /api/medical-records/:id/share
 */
exports.shareRecord = async (req, res, next) => {
  try {
    const { doctor_id } = req.body;
    
    const record = await MedicalRecord.findById(req.params.id);
    if (!record) {
      return res.status(404).json({
        status: 'error',
        message: 'Medical record not found'
      });
    }

    if (record.patient_id !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Only the patient can share their records' });
    }

    if (!record.shared_with.includes(doctor_id)) {
      record.shared_with.push(doctor_id);
      await record.save();
    }

    res.json({
      status: 'success',
      message: 'Record shared successfully'
    });

  } catch (error) {
    next(error);
  }
};

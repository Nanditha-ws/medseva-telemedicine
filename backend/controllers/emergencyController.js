/**
 * Emergency Controller
 * Handles emergency access codes and quick health data sharing
 */

const { EmergencyAccess, User, MedicationReminder } = require('../models/postgres');
const MedicalRecord = require('../models/mongo/MedicalRecord');
const { v4: uuidv4 } = require('uuid');

/**
 * Generate emergency access code
 * POST /api/emergency/generate-code
 */
exports.generateAccessCode = async (req, res, next) => {
  try {
    const { share_medical_records = true, share_medications = true,
            share_allergies = true, share_emergency_contacts = true,
            expires_in_hours = 24 } = req.body;

    // Generate a short access code
    const accessCode = `EM-${uuidv4().substring(0, 8).toUpperCase()}`;

    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + expires_in_hours);

    const emergencyAccess = await EmergencyAccess.create({
      user_id: req.user.id,
      access_code: accessCode,
      share_medical_records,
      share_medications,
      share_allergies,
      share_emergency_contacts,
      expires_at: expiresAt
    });

    res.status(201).json({
      status: 'success',
      message: 'Emergency access code generated',
      data: {
        access_code: accessCode,
        expires_at: expiresAt,
        settings: {
          share_medical_records,
          share_medications,
          share_allergies,
          share_emergency_contacts
        }
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Access emergency health data using code
 * GET /api/emergency/access/:code
 */
exports.accessEmergencyData = async (req, res, next) => {
  try {
    const { code } = req.params;

    const access = await EmergencyAccess.findOne({
      where: { access_code: code, is_active: true },
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'first_name', 'last_name', 'phone', 'blood_group',
                     'date_of_birth', 'gender', 'allergies', 'chronic_conditions',
                     'emergency_contact_name', 'emergency_contact_phone']
      }]
    });

    if (!access) {
      return res.status(404).json({
        status: 'error',
        message: 'Invalid or expired emergency access code'
      });
    }

    // Check if expired
    if (access.expires_at && new Date() > access.expires_at) {
      await access.update({ is_active: false });
      return res.status(410).json({
        status: 'error',
        message: 'Emergency access code has expired'
      });
    }

    // Build response based on sharing settings
    const emergencyData = {
      patient: {
        name: `${access.user.first_name} ${access.user.last_name}`,
        phone: access.user.phone,
        blood_group: access.user.blood_group,
        date_of_birth: access.user.date_of_birth,
        gender: access.user.gender
      }
    };

    if (access.share_allergies) {
      emergencyData.allergies = access.user.allergies;
      emergencyData.chronic_conditions = access.user.chronic_conditions;
    }

    if (access.share_emergency_contacts) {
      emergencyData.emergency_contact = {
        name: access.user.emergency_contact_name,
        phone: access.user.emergency_contact_phone
      };
    }

    if (access.share_medications) {
      const medications = await MedicationReminder.findAll({
        where: { user_id: access.user.id, is_active: true },
        attributes: ['medication_name', 'dosage', 'frequency', 'instructions']
      });
      emergencyData.current_medications = medications;
    }

    if (access.share_medical_records) {
      const recentRecords = await MedicalRecord.find({
        patient_id: access.user.id
      })
        .sort({ record_date: -1 })
        .limit(5)
        .select('record_type title diagnosis record_date vitals');
      
      emergencyData.recent_records = recentRecords;
    }

    // Update access tracking
    await access.update({
      accessed_count: access.accessed_count + 1,
      last_accessed_at: new Date(),
      last_accessed_by: req.ip
    });

    res.json({
      status: 'success',
      message: 'Emergency health data retrieved',
      data: emergencyData
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get user's emergency access codes
 * GET /api/emergency/my-codes
 */
exports.getMyCodes = async (req, res, next) => {
  try {
    const codes = await EmergencyAccess.findAll({
      where: { user_id: req.user.id },
      order: [['created_at', 'DESC']]
    });

    res.json({
      status: 'success',
      data: { codes }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Deactivate emergency access code
 * DELETE /api/emergency/:id
 */
exports.deactivateCode = async (req, res, next) => {
  try {
    const code = await EmergencyAccess.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!code) {
      return res.status(404).json({
        status: 'error',
        message: 'Access code not found'
      });
    }

    await code.update({ is_active: false });

    res.json({
      status: 'success',
      message: 'Emergency access code deactivated'
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get emergency info for the user (their own quick view)
 * GET /api/emergency/my-info
 */
exports.getMyEmergencyInfo = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: ['id', 'first_name', 'last_name', 'phone', 'blood_group',
                   'date_of_birth', 'gender', 'allergies', 'chronic_conditions',
                   'emergency_contact_name', 'emergency_contact_phone']
    });

    const medications = await MedicationReminder.findAll({
      where: { user_id: req.user.id, is_active: true },
      attributes: ['medication_name', 'dosage', 'frequency', 'instructions']
    });

    res.json({
      status: 'success',
      data: {
        personal_info: user,
        current_medications: medications
      }
    });

  } catch (error) {
    next(error);
  }
};

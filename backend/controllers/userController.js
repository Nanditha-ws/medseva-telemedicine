/**
 * User Controller
 * Handles user profile management and search
 */

const { User, DoctorProfile, Hospital } = require('../models/postgres');
const { Op } = require('sequelize');

/**
 * Get user profile
 * GET /api/users/profile
 */
exports.getProfile = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password', 'refresh_token'] },
      include: [
        { model: DoctorProfile, as: 'doctorProfile' },
        { model: Hospital, as: 'hospital' }
      ]
    });

    res.json({
      status: 'success',
      data: { user }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update user profile
 * PUT /api/users/profile
 */
exports.updateProfile = async (req, res, next) => {
  try {
    const allowedFields = [
      'first_name', 'last_name', 'phone', 'date_of_birth', 'gender',
      'address', 'city', 'state', 'pincode', 'blood_group',
      'emergency_contact_name', 'emergency_contact_phone',
      'allergies', 'chronic_conditions', 'profile_image'
    ];

    const updateData = {};
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    await User.update(updateData, { where: { id: req.user.id } });

    // Update doctor profile if applicable
    if (req.user.role === 'doctor' && req.body.doctor_profile) {
      await DoctorProfile.update(req.body.doctor_profile, {
        where: { user_id: req.user.id }
      });
    }

    const updatedUser = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password', 'refresh_token'] },
      include: [
        { model: DoctorProfile, as: 'doctorProfile' },
        { model: Hospital, as: 'hospital' }
      ]
    });

    res.json({
      status: 'success',
      message: 'Profile updated successfully',
      data: { user: updatedUser }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Search doctors
 * GET /api/users/doctors
 */
exports.searchDoctors = async (req, res, next) => {
  try {
    const { specialization, city, name, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let userWhere = { role: 'doctor', is_active: true };
    let doctorWhere = {};

    if (city) userWhere.city = { [Op.iLike]: `%${city}%` };
    if (name) {
      userWhere[Op.or] = [
        { first_name: { [Op.iLike]: `%${name}%` } },
        { last_name: { [Op.iLike]: `%${name}%` } }
      ];
    }
    if (specialization) {
      doctorWhere.specialization = { [Op.iLike]: `%${specialization}%` };
    }

    const { count, rows: doctors } = await User.findAndCountAll({
      where: userWhere,
      attributes: { exclude: ['password', 'refresh_token'] },
      include: [{
        model: DoctorProfile,
        as: 'doctorProfile',
        where: doctorWhere,
        include: [{
          model: Hospital,
          as: 'hospital',
          attributes: ['id', 'name', 'address', 'city']
        }]
      }],
      order: [[{ model: DoctorProfile, as: 'doctorProfile' }, 'rating', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      status: 'success',
      data: {
        doctors,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: Math.ceil(count / limit)
        }
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get doctor by ID
 * GET /api/users/doctors/:id
 */
exports.getDoctorById = async (req, res, next) => {
  try {
    const doctor = await User.findOne({
      where: { id: req.params.id, role: 'doctor' },
      attributes: { exclude: ['password', 'refresh_token'] },
      include: [{
        model: DoctorProfile,
        as: 'doctorProfile',
        include: [{
          model: Hospital,
          as: 'hospital'
        }]
      }]
    });

    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    res.json({
      status: 'success',
      data: { doctor }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Upload profile image
 * POST /api/users/profile-image
 */
exports.uploadProfileImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        status: 'error',
        message: 'Please upload an image'
      });
    }

    const imageUrl = `/uploads/images/${req.file.filename}`;
    await User.update(
      { profile_image: imageUrl },
      { where: { id: req.user.id } }
    );

    res.json({
      status: 'success',
      message: 'Profile image updated',
      data: { profile_image: imageUrl }
    });

  } catch (error) {
    next(error);
  }
};

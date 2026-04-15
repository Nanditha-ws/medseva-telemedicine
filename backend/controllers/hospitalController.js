/**
 * Hospital Controller
 * Handles hospital search, nearby finder, and details
 */

const { Hospital, DoctorProfile, User } = require('../models/postgres');
const { Op } = require('sequelize');
const { sequelize } = require('../config/postgresql');

/**
 * Get all hospitals with filtering
 * GET /api/hospitals
 */
exports.getHospitals = async (req, res, next) => {
  try {
    const { city, state, type, emergency, ambulance, search, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = { is_active: true };

    if (city) whereClause.city = { [Op.iLike]: `%${city}%` };
    if (state) whereClause.state = { [Op.iLike]: `%${state}%` };
    if (type) whereClause.type = type;
    if (emergency === 'true') whereClause.emergency_services = true;
    if (ambulance === 'true') whereClause.ambulance_available = true;
    if (search) {
      whereClause[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { address: { [Op.iLike]: `%${search}%` } },
        sequelize.where(
          sequelize.cast(sequelize.col('specializations'), 'text'),
          { [Op.iLike]: `%${search}%` }
        )
      ];
    }

    const { count, rows: hospitals } = await Hospital.findAndCountAll({
      where: whereClause,
      order: [['rating', 'DESC'], ['name', 'ASC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      status: 'success',
      data: {
        hospitals,
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
 * Get hospital by ID with doctors
 * GET /api/hospitals/:id
 */
exports.getHospitalById = async (req, res, next) => {
  try {
    const hospital = await Hospital.findByPk(req.params.id, {
      include: [{
        model: DoctorProfile,
        as: 'doctors',
        include: [{
          model: User,
          as: 'user',
          attributes: ['id', 'first_name', 'last_name', 'phone', 'profile_image']
        }]
      }]
    });

    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Hospital not found'
      });
    }

    res.json({
      status: 'success',
      data: { hospital }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Find nearby hospitals using coordinates
 * GET /api/hospitals/nearby
 */
exports.getNearbyHospitals = async (req, res, next) => {
  try {
    const { latitude, longitude, radius = 10, emergency_only = false } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({
        status: 'error',
        message: 'Latitude and longitude are required'
      });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const rad = parseFloat(radius); // in km

    // Haversine formula for distance calculation
    const hospitals = await sequelize.query(`
      SELECT *, 
        (6371 * acos(
          cos(radians(:lat)) * cos(radians(latitude)) * 
          cos(radians(longitude) - radians(:lng)) + 
          sin(radians(:lat)) * sin(radians(latitude))
        )) AS distance
      FROM hospitals
      WHERE is_active = true
        ${emergency_only === 'true' ? 'AND emergency_services = true' : ''}
        AND latitude IS NOT NULL 
        AND longitude IS NOT NULL
      HAVING (6371 * acos(
        cos(radians(:lat)) * cos(radians(latitude)) * 
        cos(radians(longitude) - radians(:lng)) + 
        sin(radians(:lat)) * sin(radians(latitude))
      )) < :rad
      ORDER BY distance ASC
      LIMIT 20
    `, {
      replacements: { lat, lng, rad },
      type: sequelize.QueryTypes.SELECT
    });

    res.json({
      status: 'success',
      data: {
        hospitals,
        search_params: { latitude: lat, longitude: lng, radius: rad }
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Create or update hospital
 * POST /api/hospitals
 */
exports.createHospital = async (req, res, next) => {
  try {
    const hospital = await Hospital.create({
      ...req.body,
      user_id: req.user.id
    });

    res.status(201).json({
      status: 'success',
      message: 'Hospital registered successfully',
      data: { hospital }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Update hospital
 * PUT /api/hospitals/:id
 */
exports.updateHospital = async (req, res, next) => {
  try {
    const hospital = await Hospital.findByPk(req.params.id);
    
    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Hospital not found'
      });
    }

    if (hospital.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ status: 'error', message: 'Access denied' });
    }

    await hospital.update(req.body);

    res.json({
      status: 'success',
      message: 'Hospital updated successfully',
      data: { hospital }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Appointment Controller
 * Handles appointment booking, management, and retrieval
 */

const { Appointment, User, DoctorProfile, Hospital } = require('../models/postgres');
const { Op } = require('sequelize');

/**
 * Create a new appointment
 * POST /api/appointments
 */
exports.createAppointment = async (req, res, next) => {
  try {
    const { doctor_id, hospital_id, appointment_date, appointment_time,
            duration_minutes, type, reason, symptoms } = req.body;

    // Check if doctor exists
    const doctor = await User.findOne({ 
      where: { id: doctor_id, role: 'doctor' },
      include: [{ model: DoctorProfile, as: 'doctorProfile' }]
    });
    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    // Check for conflicting appointments
    const conflict = await Appointment.findOne({
      where: {
        doctor_id,
        appointment_date,
        appointment_time,
        status: { [Op.notIn]: ['cancelled', 'no_show'] }
      }
    });

    if (conflict) {
      return res.status(409).json({
        status: 'error',
        message: 'This time slot is already booked. Please choose another time.'
      });
    }

    const appointment = await Appointment.create({
      patient_id: req.user.id,
      doctor_id,
      hospital_id,
      appointment_date,
      appointment_time,
      duration_minutes: duration_minutes || 30,
      type: type || 'in_person',
      reason,
      symptoms,
      consultation_fee: doctor.doctorProfile?.consultation_fee || 0
    });

    const fullAppointment = await Appointment.findByPk(appointment.id, {
      include: [
        { model: User, as: 'patient', attributes: ['id', 'first_name', 'last_name', 'email', 'phone'] },
        { model: User, as: 'doctor', attributes: ['id', 'first_name', 'last_name', 'email', 'phone'] },
        { model: Hospital, as: 'hospital', attributes: ['id', 'name', 'address'] }
      ]
    });

    res.status(201).json({
      status: 'success',
      message: 'Appointment booked successfully',
      data: { appointment: fullAppointment }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get all appointments for current user
 * GET /api/appointments
 */
exports.getAppointments = async (req, res, next) => {
  try {
    const { status, date, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = {};
    
    // Filter by role
    if (req.user.role === 'patient') {
      whereClause.patient_id = req.user.id;
    } else if (req.user.role === 'doctor') {
      whereClause.doctor_id = req.user.id;
    }

    if (status) whereClause.status = status;
    if (date) whereClause.appointment_date = date;

    const { count, rows: appointments } = await Appointment.findAndCountAll({
      where: whereClause,
      include: [
        { model: User, as: 'patient', attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image'] },
        { model: User, as: 'doctor', attributes: ['id', 'first_name', 'last_name', 'email', 'phone', 'profile_image'] },
        { model: Hospital, as: 'hospital', attributes: ['id', 'name', 'address', 'phone'] }
      ],
      order: [['appointment_date', 'DESC'], ['appointment_time', 'ASC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      status: 'success',
      data: {
        appointments,
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
 * Get appointment by ID
 * GET /api/appointments/:id
 */
exports.getAppointmentById = async (req, res, next) => {
  try {
    const appointment = await Appointment.findByPk(req.params.id, {
      include: [
        { model: User, as: 'patient', attributes: { exclude: ['password', 'refresh_token'] } },
        { 
          model: User, as: 'doctor', 
          attributes: { exclude: ['password', 'refresh_token'] },
          include: [{ model: DoctorProfile, as: 'doctorProfile' }]
        },
        { model: Hospital, as: 'hospital' }
      ]
    });

    if (!appointment) {
      return res.status(404).json({
        status: 'error',
        message: 'Appointment not found'
      });
    }

    // Check authorization
    if (req.user.role === 'patient' && appointment.patient_id !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Access denied' });
    }
    if (req.user.role === 'doctor' && appointment.doctor_id !== req.user.id) {
      return res.status(403).json({ status: 'error', message: 'Access denied' });
    }

    res.json({
      status: 'success',
      data: { appointment }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Update appointment status
 * PUT /api/appointments/:id
 */
exports.updateAppointment = async (req, res, next) => {
  try {
    const appointment = await Appointment.findByPk(req.params.id);
    
    if (!appointment) {
      return res.status(404).json({
        status: 'error',
        message: 'Appointment not found'
      });
    }

    const { status, notes, doctor_notes, cancellation_reason } = req.body;

    const updateData = {};
    if (status) updateData.status = status;
    if (notes) updateData.notes = notes;
    if (doctor_notes) updateData.doctor_notes = doctor_notes;
    if (cancellation_reason) {
      updateData.cancellation_reason = cancellation_reason;
      updateData.cancelled_by = req.user.role;
    }

    await appointment.update(updateData);

    res.json({
      status: 'success',
      message: 'Appointment updated successfully',
      data: { appointment }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Cancel appointment
 * DELETE /api/appointments/:id
 */
exports.cancelAppointment = async (req, res, next) => {
  try {
    const appointment = await Appointment.findByPk(req.params.id);
    
    if (!appointment) {
      return res.status(404).json({
        status: 'error',
        message: 'Appointment not found'
      });
    }

    if (['completed', 'cancelled'].includes(appointment.status)) {
      return res.status(400).json({
        status: 'error',
        message: `Cannot cancel appointment with status: ${appointment.status}`
      });
    }

    await appointment.update({
      status: 'cancelled',
      cancellation_reason: req.body.reason || 'Cancelled by user',
      cancelled_by: req.user.role
    });

    res.json({
      status: 'success',
      message: 'Appointment cancelled successfully'
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get upcoming appointments
 * GET /api/appointments/upcoming
 */
exports.getUpcomingAppointments = async (req, res, next) => {
  try {
    let whereClause = {
      appointment_date: { [Op.gte]: new Date() },
      status: { [Op.in]: ['pending', 'confirmed'] }
    };

    if (req.user.role === 'patient') {
      whereClause.patient_id = req.user.id;
    } else if (req.user.role === 'doctor') {
      whereClause.doctor_id = req.user.id;
    }

    const appointments = await Appointment.findAll({
      where: whereClause,
      include: [
        { model: User, as: 'patient', attributes: ['id', 'first_name', 'last_name', 'phone', 'profile_image'] },
        { model: User, as: 'doctor', attributes: ['id', 'first_name', 'last_name', 'phone', 'profile_image'] },
        { model: Hospital, as: 'hospital', attributes: ['id', 'name'] }
      ],
      order: [['appointment_date', 'ASC'], ['appointment_time', 'ASC']],
      limit: 10
    });

    res.json({
      status: 'success',
      data: { appointments }
    });

  } catch (error) {
    next(error);
  }
};

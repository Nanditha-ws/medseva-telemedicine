/**
 * Medication Controller
 * Handles medication reminders and tracking
 */

const { MedicationReminder, MedicationLog, User } = require('../models/postgres');
const { Op } = require('sequelize');

/**
 * Create a medication reminder
 * POST /api/medications
 */
exports.createReminder = async (req, res, next) => {
  try {
    const reminder = await MedicationReminder.create({
      ...req.body,
      user_id: req.user.id
    });

    res.status(201).json({
      status: 'success',
      message: 'Medication reminder created',
      data: { reminder }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get all medication reminders
 * GET /api/medications
 */
exports.getReminders = async (req, res, next) => {
  try {
    const { active_only = 'true' } = req.query;

    let whereClause = { user_id: req.user.id };
    if (active_only === 'true') {
      whereClause.is_active = true;
    }

    const reminders = await MedicationReminder.findAll({
      where: whereClause,
      include: [
        { model: User, as: 'prescribedByDoctor', attributes: ['id', 'first_name', 'last_name'] }
      ],
      order: [['created_at', 'DESC']]
    });

    res.json({
      status: 'success',
      data: { reminders }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get medication reminder by ID
 * GET /api/medications/:id
 */
exports.getReminderById = async (req, res, next) => {
  try {
    const reminder = await MedicationReminder.findOne({
      where: { id: req.params.id, user_id: req.user.id },
      include: [
        { model: User, as: 'prescribedByDoctor', attributes: ['id', 'first_name', 'last_name'] },
        { model: MedicationLog, as: 'logs', order: [['taken_at', 'DESC']], limit: 30 }
      ]
    });

    if (!reminder) {
      return res.status(404).json({
        status: 'error',
        message: 'Medication reminder not found'
      });
    }

    res.json({
      status: 'success',
      data: { reminder }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Update medication reminder
 * PUT /api/medications/:id
 */
exports.updateReminder = async (req, res, next) => {
  try {
    const reminder = await MedicationReminder.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!reminder) {
      return res.status(404).json({
        status: 'error',
        message: 'Medication reminder not found'
      });
    }

    await reminder.update(req.body);

    res.json({
      status: 'success',
      message: 'Medication reminder updated',
      data: { reminder }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Delete medication reminder
 * DELETE /api/medications/:id
 */
exports.deleteReminder = async (req, res, next) => {
  try {
    const reminder = await MedicationReminder.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!reminder) {
      return res.status(404).json({
        status: 'error',
        message: 'Medication reminder not found'
      });
    }

    await reminder.update({ is_active: false });

    res.json({
      status: 'success',
      message: 'Medication reminder deactivated'
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Log medication taken/missed/skipped
 * POST /api/medications/:id/log
 */
exports.logMedication = async (req, res, next) => {
  try {
    const { status, scheduled_time, notes } = req.body;

    const reminder = await MedicationReminder.findOne({
      where: { id: req.params.id, user_id: req.user.id }
    });

    if (!reminder) {
      return res.status(404).json({
        status: 'error',
        message: 'Medication reminder not found'
      });
    }

    const log = await MedicationLog.create({
      reminder_id: reminder.id,
      user_id: req.user.id,
      status: status || 'taken',
      scheduled_time: scheduled_time || new Date().toTimeString().slice(0, 8),
      notes
    });

    res.status(201).json({
      status: 'success',
      message: `Medication marked as ${status || 'taken'}`,
      data: { log }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Get medication adherence report
 * GET /api/medications/:id/adherence
 */
exports.getAdherence = async (req, res, next) => {
  try {
    const { days = 30 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const logs = await MedicationLog.findAll({
      where: {
        reminder_id: req.params.id,
        user_id: req.user.id,
        taken_at: { [Op.gte]: startDate }
      },
      order: [['taken_at', 'DESC']]
    });

    const totalLogs = logs.length;
    const taken = logs.filter(l => l.status === 'taken').length;
    const missed = logs.filter(l => l.status === 'missed').length;
    const skipped = logs.filter(l => l.status === 'skipped').length;

    const adherenceRate = totalLogs > 0 ? ((taken / totalLogs) * 100).toFixed(1) : 0;

    res.json({
      status: 'success',
      data: {
        adherence: {
          rate: parseFloat(adherenceRate),
          total: totalLogs,
          taken,
          missed,
          skipped,
          period_days: parseInt(days)
        },
        logs
      }
    });

  } catch (error) {
    next(error);
  }
};

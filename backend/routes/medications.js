/**
 * Medication Routes
 * @swagger
 * /api/medications:
 *   post:
 *     tags: [Medications]
 *     summary: Create medication reminder
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [medication_name, dosage, frequency, times, start_date]
 *             properties:
 *               medication_name: { type: string }
 *               dosage: { type: string, example: "500mg" }
 *               frequency: { type: string, enum: [once_daily, twice_daily, thrice_daily, four_times_daily, weekly, as_needed] }
 *               times: { type: array, items: { type: string }, example: ["08:00", "20:00"] }
 *               start_date: { type: string, format: date }
 *               end_date: { type: string, format: date }
 *               instructions: { type: string }
 *     responses:
 *       201:
 *         description: Reminder created
 *   get:
 *     tags: [Medications]
 *     summary: Get medication reminders
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: List of reminders
 *
 * /api/medications/{id}:
 *   get:
 *     tags: [Medications]
 *     summary: Get medication details with logs
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Medication details
 *   put:
 *     tags: [Medications]
 *     summary: Update medication reminder
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Reminder updated
 *   delete:
 *     tags: [Medications]
 *     summary: Deactivate medication reminder
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Reminder deactivated
 *
 * /api/medications/{id}/log:
 *   post:
 *     tags: [Medications]
 *     summary: Log medication taken/missed
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status: { type: string, enum: [taken, missed, skipped] }
 *               scheduled_time: { type: string }
 *               notes: { type: string }
 *     responses:
 *       201:
 *         description: Medication logged
 *
 * /api/medications/{id}/adherence:
 *   get:
 *     tags: [Medications]
 *     summary: Get medication adherence report
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: query
 *         name: days
 *         schema: { type: integer, default: 30 }
 *     responses:
 *       200:
 *         description: Adherence report
 */

const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');
const { authenticate } = require('../middleware/auth');

router.post('/', authenticate, medicationController.createReminder);
router.get('/', authenticate, medicationController.getReminders);
router.get('/:id', authenticate, medicationController.getReminderById);
router.put('/:id', authenticate, medicationController.updateReminder);
router.delete('/:id', authenticate, medicationController.deleteReminder);
router.post('/:id/log', authenticate, medicationController.logMedication);
router.get('/:id/adherence', authenticate, medicationController.getAdherence);

module.exports = router;

/**
 * Appointment Routes
 * @swagger
 * /api/appointments:
 *   post:
 *     tags: [Appointments]
 *     summary: Book a new appointment
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [doctor_id, appointment_date, appointment_time]
 *             properties:
 *               doctor_id: { type: string, format: uuid }
 *               hospital_id: { type: string, format: uuid }
 *               appointment_date: { type: string, format: date }
 *               appointment_time: { type: string, example: "10:00:00" }
 *               type: { type: string, enum: [in_person, video_call, phone_call] }
 *               reason: { type: string }
 *               symptoms: { type: string }
 *     responses:
 *       201:
 *         description: Appointment booked
 *       409:
 *         description: Time slot already booked
 *   get:
 *     tags: [Appointments]
 *     summary: Get user appointments
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: query
 *         name: status
 *         schema: { type: string, enum: [pending, confirmed, completed, cancelled] }
 *       - in: query
 *         name: date
 *         schema: { type: string, format: date }
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *     responses:
 *       200:
 *         description: List of appointments
 *
 * /api/appointments/upcoming:
 *   get:
 *     tags: [Appointments]
 *     summary: Get upcoming appointments
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Upcoming appointments
 *
 * /api/appointments/{id}:
 *   get:
 *     tags: [Appointments]
 *     summary: Get appointment details
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Appointment details
 *   put:
 *     tags: [Appointments]
 *     summary: Update appointment
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Appointment updated
 *   delete:
 *     tags: [Appointments]
 *     summary: Cancel appointment
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Appointment cancelled
 */

const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const appointmentController = require('../controllers/appointmentController');
const { authenticate, authorize } = require('../middleware/auth');
const validate = require('../middleware/validate');

const appointmentValidation = [
  body('doctor_id').isUUID().withMessage('Valid doctor ID is required'),
  body('appointment_date').isDate().withMessage('Valid date is required'),
  body('appointment_time').matches(/^\d{2}:\d{2}(:\d{2})?$/).withMessage('Valid time is required (HH:MM)')
];

router.post('/', authenticate, authorize('patient'), appointmentValidation, validate, appointmentController.createAppointment);
router.get('/', authenticate, appointmentController.getAppointments);
router.get('/upcoming', authenticate, appointmentController.getUpcomingAppointments);
router.get('/:id', authenticate, appointmentController.getAppointmentById);
router.put('/:id', authenticate, appointmentController.updateAppointment);
router.delete('/:id', authenticate, appointmentController.cancelAppointment);

module.exports = router;

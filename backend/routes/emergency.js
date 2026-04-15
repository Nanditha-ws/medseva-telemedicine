/**
 * Emergency Routes
 * @swagger
 * /api/emergency/generate-code:
 *   post:
 *     tags: [Emergency]
 *     summary: Generate emergency access code
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               share_medical_records: { type: boolean, default: true }
 *               share_medications: { type: boolean, default: true }
 *               share_allergies: { type: boolean, default: true }
 *               share_emergency_contacts: { type: boolean, default: true }
 *               expires_in_hours: { type: integer, default: 24 }
 *     responses:
 *       201:
 *         description: Access code generated
 *
 * /api/emergency/access/{code}:
 *   get:
 *     tags: [Emergency]
 *     summary: Access emergency health data (no auth required)
 *     parameters:
 *       - in: path
 *         name: code
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Emergency health data
 *       404:
 *         description: Invalid or expired code
 *
 * /api/emergency/my-codes:
 *   get:
 *     tags: [Emergency]
 *     summary: Get user's emergency access codes
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: List of access codes
 *
 * /api/emergency/my-info:
 *   get:
 *     tags: [Emergency]
 *     summary: Get own emergency info
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Emergency info
 */

const express = require('express');
const router = express.Router();
const emergencyController = require('../controllers/emergencyController');
const { authenticate } = require('../middleware/auth');

router.post('/generate-code', authenticate, emergencyController.generateAccessCode);
router.get('/access/:code', emergencyController.accessEmergencyData); // Public endpoint
router.get('/my-codes', authenticate, emergencyController.getMyCodes);
router.get('/my-info', authenticate, emergencyController.getMyEmergencyInfo);
router.delete('/:id', authenticate, emergencyController.deactivateCode);

module.exports = router;

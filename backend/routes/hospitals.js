/**
 * Hospital Routes
 * @swagger
 * /api/hospitals:
 *   get:
 *     tags: [Hospitals]
 *     summary: Get hospitals with filtering
 *     parameters:
 *       - in: query
 *         name: city
 *         schema: { type: string }
 *       - in: query
 *         name: type
 *         schema: { type: string, enum: [hospital, clinic, diagnostic_center, pharmacy] }
 *       - in: query
 *         name: emergency
 *         schema: { type: string, enum: ["true", "false"] }
 *       - in: query
 *         name: ambulance
 *         schema: { type: string, enum: ["true", "false"] }
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of hospitals
 *   post:
 *     tags: [Hospitals]
 *     summary: Register a hospital
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       201:
 *         description: Hospital registered
 *
 * /api/hospitals/nearby:
 *   get:
 *     tags: [Hospitals]
 *     summary: Find nearby hospitals
 *     parameters:
 *       - in: query
 *         name: latitude
 *         required: true
 *         schema: { type: number }
 *       - in: query
 *         name: longitude
 *         required: true
 *         schema: { type: number }
 *       - in: query
 *         name: radius
 *         schema: { type: number, default: 10 }
 *       - in: query
 *         name: emergency_only
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Nearby hospitals with distance
 *
 * /api/hospitals/{id}:
 *   get:
 *     tags: [Hospitals]
 *     summary: Get hospital details
 *     responses:
 *       200:
 *         description: Hospital details with doctors
 *   put:
 *     tags: [Hospitals]
 *     summary: Update hospital
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Hospital updated
 */

const express = require('express');
const router = express.Router();
const hospitalController = require('../controllers/hospitalController');
const { authenticate, authorize } = require('../middleware/auth');

router.get('/', hospitalController.getHospitals);
router.get('/nearby', hospitalController.getNearbyHospitals);
router.get('/:id', hospitalController.getHospitalById);
router.post('/', authenticate, authorize('hospital', 'admin'), hospitalController.createHospital);
router.put('/:id', authenticate, hospitalController.updateHospital);

module.exports = router;

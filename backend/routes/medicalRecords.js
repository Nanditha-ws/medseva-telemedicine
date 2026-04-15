/**
 * Medical Record Routes
 * @swagger
 * /api/medical-records:
 *   post:
 *     tags: [Medical Records]
 *     summary: Create a medical record
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               record_type: { type: string, enum: [lab_report, prescription, diagnosis, imaging, discharge_summary, vaccination] }
 *               title: { type: string }
 *               description: { type: string }
 *               files: { type: array, items: { type: string, format: binary } }
 *     responses:
 *       201:
 *         description: Record created
 *   get:
 *     tags: [Medical Records]
 *     summary: Get medical records
 *     security: [{ bearerAuth: [] }]
 *     parameters:
 *       - in: query
 *         name: record_type
 *         schema: { type: string }
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of records
 *
 * /api/medical-records/{id}:
 *   get:
 *     tags: [Medical Records]
 *     summary: Get record details
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Record details
 *   put:
 *     tags: [Medical Records]
 *     summary: Update record
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Record updated
 *   delete:
 *     tags: [Medical Records]
 *     summary: Delete record
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Record deleted
 *
 * /api/medical-records/{id}/share:
 *   post:
 *     tags: [Medical Records]
 *     summary: Share record with doctor
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               doctor_id: { type: string }
 *     responses:
 *       200:
 *         description: Record shared
 */

const express = require('express');
const router = express.Router();
const medicalRecordController = require('../controllers/medicalRecordController');
const { authenticate } = require('../middleware/auth');
const { upload } = require('../middleware/upload');

router.post('/', authenticate, upload.array('files', 5), medicalRecordController.createRecord);
router.get('/', authenticate, medicalRecordController.getRecords);
router.get('/:id', authenticate, medicalRecordController.getRecordById);
router.put('/:id', authenticate, upload.array('files', 5), medicalRecordController.updateRecord);
router.delete('/:id', authenticate, medicalRecordController.deleteRecord);
router.post('/:id/share', authenticate, medicalRecordController.shareRecord);

module.exports = router;

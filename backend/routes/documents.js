/**
 * Document Scanning Routes
 * @swagger
 * /api/documents/scan:
 *   post:
 *     tags: [Documents]
 *     summary: Scan and process a document
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               image: { type: string, format: binary }
 *               title: { type: string }
 *               document_type: { type: string, enum: [prescription, lab_report, medical_bill, insurance_card, id_card, other] }
 *               apply_threshold: { type: string }
 *               threshold_value: { type: integer }
 *               notes: { type: string }
 *     responses:
 *       201:
 *         description: Document scanned
 *
 * /api/documents:
 *   get:
 *     tags: [Documents]
 *     summary: Get all scanned documents
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: List of documents
 *
 * /api/documents/{id}:
 *   get:
 *     tags: [Documents]
 *     summary: Get document details
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Document details
 *   delete:
 *     tags: [Documents]
 *     summary: Delete document
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Document deleted
 *
 * /api/documents/{id}/enhance:
 *   post:
 *     tags: [Documents]
 *     summary: Enhance a scanned document
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Document enhanced
 *
 * /api/documents/clean:
 *   post:
 *     tags: [Documents]
 *     summary: Generate clean digital document
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Clean document generated
 */

const express = require('express');
const router = express.Router();
const documentController = require('../controllers/documentController');
const { authenticate } = require('../middleware/auth');
const { uploadToMemory } = require('../middleware/upload');

router.post('/scan', authenticate, uploadToMemory.single('image'), documentController.scanDocument);
router.post('/clean', authenticate, uploadToMemory.single('image'), documentController.generateCleanDocument);
router.post('/:id/enhance', authenticate, uploadToMemory.single('image'), documentController.enhanceDocument);
router.get('/', authenticate, documentController.getDocuments);
router.get('/:id', authenticate, documentController.getDocumentById);
router.delete('/:id', authenticate, documentController.deleteDocument);

module.exports = router;

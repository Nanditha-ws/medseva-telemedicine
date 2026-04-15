/**
 * Education Routes
 * @swagger
 * /api/education:
 *   get:
 *     tags: [Education]
 *     summary: Get health education articles
 *     parameters:
 *       - in: query
 *         name: category
 *         schema: { type: string, enum: [diabetes, heart_disease, hypertension, asthma, cancer, mental_health, nutrition, exercise, preventive_care, maternal_health, child_health, elderly_care, general] }
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of articles
 *   post:
 *     tags: [Education]
 *     summary: Create article (doctor/admin only)
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, content, summary, category]
 *             properties:
 *               title: { type: string }
 *               content: { type: string }
 *               summary: { type: string }
 *               category: { type: string }
 *               tags: { type: array, items: { type: string } }
 *     responses:
 *       201:
 *         description: Article created
 *
 * /api/education/categories:
 *   get:
 *     tags: [Education]
 *     summary: Get categories with counts
 *     responses:
 *       200:
 *         description: Category list
 *
 * /api/education/{slug}:
 *   get:
 *     tags: [Education]
 *     summary: Get article by slug
 *     parameters:
 *       - in: path
 *         name: slug
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Article details
 *
 * /api/education/{id}/like:
 *   post:
 *     tags: [Education]
 *     summary: Like an article
 *     responses:
 *       200:
 *         description: Like count updated
 */

const express = require('express');
const router = express.Router();
const educationController = require('../controllers/educationController');
const { authenticate, authorize, optionalAuth } = require('../middleware/auth');

router.get('/', optionalAuth, educationController.getContent);
router.get('/categories', educationController.getCategories);
router.post('/', authenticate, authorize('doctor', 'admin'), educationController.createContent);
router.get('/:slug', optionalAuth, educationController.getArticle);
router.put('/:id', authenticate, authorize('doctor', 'admin'), educationController.updateContent);
router.post('/:id/like', optionalAuth, educationController.likeArticle);

module.exports = router;

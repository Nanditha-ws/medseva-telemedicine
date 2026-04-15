/**
 * User Routes
 * @swagger
 * /api/users/profile:
 *   get:
 *     tags: [Users]
 *     summary: Get current user profile
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: User profile data
 *   put:
 *     tags: [Users]
 *     summary: Update user profile
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               first_name: { type: string }
 *               last_name: { type: string }
 *               phone: { type: string }
 *               blood_group: { type: string }
 *               allergies: { type: string }
 *     responses:
 *       200:
 *         description: Profile updated
 *
 * /api/users/doctors:
 *   get:
 *     tags: [Users]
 *     summary: Search doctors
 *     parameters:
 *       - in: query
 *         name: specialization
 *         schema: { type: string }
 *       - in: query
 *         name: city
 *         schema: { type: string }
 *       - in: query
 *         name: name
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of doctors
 *
 * /api/users/doctors/{id}:
 *   get:
 *     tags: [Users]
 *     summary: Get doctor details
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Doctor details
 */

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate } = require('../middleware/auth');
const { upload } = require('../middleware/upload');

router.get('/profile', authenticate, userController.getProfile);
router.put('/profile', authenticate, userController.updateProfile);
router.get('/doctors', authenticate, userController.searchDoctors);
router.get('/doctors/:id', authenticate, userController.getDoctorById);
router.post('/profile-image', authenticate, upload.single('image'), userController.uploadProfileImage);

module.exports = router;

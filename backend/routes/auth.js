/**
 * Authentication Routes
 * @swagger
 * /api/auth/register:
 *   post:
 *     tags: [Authentication]
 *     summary: Register a new user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password, first_name, last_name, role]
 *             properties:
 *               email: { type: string, format: email }
 *               password: { type: string, minLength: 6 }
 *               role: { type: string, enum: [patient, doctor, hospital] }
 *               first_name: { type: string }
 *               last_name: { type: string }
 *               phone: { type: string }
 *               specialization: { type: string, description: "Required for doctors" }
 *               qualification: { type: string, description: "Required for doctors" }
 *               registration_number: { type: string, description: "Required for doctors" }
 *     responses:
 *       201:
 *         description: Registration successful
 *       409:
 *         description: Email already exists
 *
 * /api/auth/login:
 *   post:
 *     tags: [Authentication]
 *     summary: Login user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email: { type: string, format: email }
 *               password: { type: string }
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 *
 * /api/auth/me:
 *   get:
 *     tags: [Authentication]
 *     summary: Get current user profile
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: User profile
 *
 * /api/auth/refresh:
 *   post:
 *     tags: [Authentication]
 *     summary: Refresh access token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               refreshToken: { type: string }
 *     responses:
 *       200:
 *         description: New tokens generated
 *
 * /api/auth/logout:
 *   post:
 *     tags: [Authentication]
 *     summary: Logout user
 *     security: [{ bearerAuth: [] }]
 *     responses:
 *       200:
 *         description: Logged out successfully
 *
 * /api/auth/change-password:
 *   put:
 *     tags: [Authentication]
 *     summary: Change user password
 *     security: [{ bearerAuth: [] }]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               current_password: { type: string }
 *               new_password: { type: string, minLength: 6 }
 *     responses:
 *       200:
 *         description: Password changed
 */

const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Registration validation
const registerValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('first_name').trim().notEmpty().withMessage('First name is required'),
  body('last_name').trim().notEmpty().withMessage('Last name is required'),
  body('role').isIn(['patient', 'doctor', 'hospital']).withMessage('Invalid role')
];

// Login validation
const loginValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('password').notEmpty().withMessage('Password is required')
];

router.post('/register', registerValidation, validate, authController.register);
router.post('/login', loginValidation, validate, authController.login);
router.post('/refresh', authController.refreshToken);
router.post('/logout', authenticate, authController.logout);
router.get('/me', authenticate, authController.getMe);
router.put('/change-password', authenticate, authController.changePassword);

module.exports = router;

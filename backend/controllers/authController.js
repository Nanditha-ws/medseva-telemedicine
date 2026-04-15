/**
 * Authentication Controller
 * Handles user registration, login, and token management
 */

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { User, DoctorProfile, Hospital } = require('../models/postgres');

/**
 * Generate JWT tokens
 */
const generateTokens = (userId) => {
  const accessToken = jwt.sign(
    { id: userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  const refreshToken = jwt.sign(
    { id: userId },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
  );

  return { accessToken, refreshToken };
};

/**
 * Register a new user
 * POST /api/auth/register
 */
exports.register = async (req, res, next) => {
  try {
    const { email, password, role, first_name, last_name, phone, 
            specialization, qualification, experience_years, registration_number,
            consultation_fee, hospital_name, hospital_address, hospital_city,
            hospital_state, hospital_pincode, hospital_phone } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(409).json({
        status: 'error',
        message: 'Email already registered'
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const user = await User.create({
      email,
      password: hashedPassword,
      role: role || 'patient',
      first_name,
      last_name,
      phone
    });

    // If doctor, create doctor profile
    if (role === 'doctor') {
      await DoctorProfile.create({
        user_id: user.id,
        specialization: specialization || 'General Medicine',
        qualification: qualification || 'MBBS',
        experience_years: experience_years || 0,
        registration_number: registration_number || `DR-${Date.now()}`,
        consultation_fee: consultation_fee || 500
      });
    }

    // If hospital, create hospital record
    if (role === 'hospital') {
      await Hospital.create({
        user_id: user.id,
        name: hospital_name || `${first_name} ${last_name} Hospital`,
        address: hospital_address || '',
        city: hospital_city || '',
        state: hospital_state || '',
        pincode: hospital_pincode || '',
        phone: hospital_phone || phone || ''
      });
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id);

    // Save refresh token
    await user.update({ refresh_token: refreshToken });

    // Response
    const userResponse = {
      id: user.id,
      email: user.email,
      role: user.role,
      first_name: user.first_name,
      last_name: user.last_name,
      phone: user.phone
    };

    res.status(201).json({
      status: 'success',
      message: 'Registration successful',
      data: {
        user: userResponse,
        accessToken,
        refreshToken
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Login user
 * POST /api/auth/login
 */
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password'
      });
    }

    // Check if account is active
    if (!user.is_active) {
      return res.status(403).json({
        status: 'error',
        message: 'Account has been deactivated. Contact support.'
      });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password'
      });
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id);

    // Update last login and refresh token
    await user.update({ 
      last_login: new Date(),
      refresh_token: refreshToken
    });

    // Get additional profile data
    let profileData = {};
    if (user.role === 'doctor') {
      const doctorProfile = await DoctorProfile.findOne({ where: { user_id: user.id } });
      profileData = { doctorProfile };
    } else if (user.role === 'hospital') {
      const hospital = await Hospital.findOne({ where: { user_id: user.id } });
      profileData = { hospital };
    }

    const userResponse = {
      id: user.id,
      email: user.email,
      role: user.role,
      first_name: user.first_name,
      last_name: user.last_name,
      phone: user.phone,
      profile_image: user.profile_image,
      is_verified: user.is_verified,
      ...profileData
    };

    res.json({
      status: 'success',
      message: 'Login successful',
      data: {
        user: userResponse,
        accessToken,
        refreshToken
      }
    });

  } catch (error) {
    next(error);
  }
};

/**
 * Refresh access token
 * POST /api/auth/refresh
 */
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        status: 'error',
        message: 'Refresh token is required'
      });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Find user and check stored refresh token
    const user = await User.findByPk(decoded.id);
    if (!user || user.refresh_token !== refreshToken) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid refresh token'
      });
    }

    // Generate new tokens
    const tokens = generateTokens(user.id);
    await user.update({ refresh_token: tokens.refreshToken });

    res.json({
      status: 'success',
      data: tokens
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        status: 'error',
        message: 'Refresh token expired. Please login again.'
      });
    }
    next(error);
  }
};

/**
 * Logout user
 * POST /api/auth/logout
 */
exports.logout = async (req, res, next) => {
  try {
    await req.user.update({ refresh_token: null });
    
    res.json({
      status: 'success',
      message: 'Logged out successfully'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get current user profile
 * GET /api/auth/me
 */
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password', 'refresh_token'] },
      include: [
        { model: DoctorProfile, as: 'doctorProfile' },
        { model: Hospital, as: 'hospital' }
      ]
    });

    res.json({
      status: 'success',
      data: { user }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Change password
 * PUT /api/auth/change-password
 */
exports.changePassword = async (req, res, next) => {
  try {
    const { current_password, new_password } = req.body;

    const user = await User.findByPk(req.user.id);
    
    const isValid = await bcrypt.compare(current_password, user.password);
    if (!isValid) {
      return res.status(400).json({
        status: 'error',
        message: 'Current password is incorrect'
      });
    }

    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(new_password, salt);
    
    await user.update({ password: hashedPassword });

    res.json({
      status: 'success',
      message: 'Password changed successfully'
    });
  } catch (error) {
    next(error);
  }
};

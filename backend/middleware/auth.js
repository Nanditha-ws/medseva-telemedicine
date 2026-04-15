/**
 * Authentication Middleware
 * Verifies JWT tokens and attaches user to request
 */

const jwt = require('jsonwebtoken');
const { User } = require('../models/postgres');

/**
 * Verify JWT token and attach user to request
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. No token provided.'
      });
    }

    const token = authHeader.split(' ')[1];
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const user = await User.findByPk(decoded.id, {
      attributes: { exclude: ['password'] }
    });

    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid token. User not found.'
      });
    }

    if (!user.is_active) {
      return res.status(403).json({
        status: 'error',
        message: 'Account has been deactivated.'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        status: 'error',
        message: 'Token expired. Please login again.'
      });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid token.'
      });
    }
    next(error);
  }
};

/**
 * Role-based authorization middleware
 * @param  {...string} roles - Allowed roles (patient, doctor, hospital, admin)
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required.'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        status: 'error',
        message: `Access denied. Required role: ${roles.join(' or ')}`
      });
    }

    next();
  };
};

/**
 * Optional authentication - doesn't fail if no token
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findByPk(decoded.id, {
        attributes: { exclude: ['password'] }
      });
      if (user && user.is_active) {
        req.user = user;
      }
    }
    
    next();
  } catch (error) {
    // Token invalid but we don't fail - it's optional
    next();
  }
};

module.exports = { authenticate, authorize, optionalAuth };

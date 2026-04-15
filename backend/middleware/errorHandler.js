/**
 * Global Error Handler Middleware
 */

const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Sequelize validation error
  if (err.name === 'SequelizeValidationError') {
    const errors = err.errors.map(e => ({
      field: e.path,
      message: e.message
    }));
    return res.status(400).json({
      status: 'error',
      message: 'Validation error',
      errors
    });
  }

  // Sequelize unique constraint error
  if (err.name === 'SequelizeUniqueConstraintError') {
    const errors = err.errors.map(e => ({
      field: e.path,
      message: `${e.path} already exists`
    }));
    return res.status(409).json({
      status: 'error',
      message: 'Duplicate entry',
      errors
    });
  }

  // Mongoose validation error
  if (err.name === 'ValidationError' && err.errors) {
    const errors = Object.keys(err.errors).map(key => ({
      field: key,
      message: err.errors[key].message
    }));
    return res.status(400).json({
      status: 'error',
      message: 'Validation error',
      errors
    });
  }

  // MongoDB duplicate key error
  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern)[0];
    return res.status(409).json({
      status: 'error',
      message: `Duplicate ${field}`,
      errors: [{ field, message: `${field} already exists` }]
    });
  }

  // Multer file upload errors
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({
      status: 'error',
      message: 'File size exceeds the limit'
    });
  }

  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    return res.status(400).json({
      status: 'error',
      message: 'Unexpected file field'
    });
  }

  // Default error
  const statusCode = err.statusCode || 500;
  const message = process.env.NODE_ENV === 'production' 
    ? 'Internal server error' 
    : err.message || 'Internal server error';

  res.status(statusCode).json({
    status: 'error',
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

module.exports = errorHandler;

/**
 * MedSeva Telemedicine Application - Main Server Entry Point
 * 
 * This server initializes Express, connects to PostgreSQL and MongoDB,
 * sets up middleware, routes, and starts the HTTP server.
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const path = require('path');
const http = require('http');

// Database connections
const { connectPostgreSQL, sequelize } = require('./config/postgresql');
const { connectMongoDB } = require('./config/mongodb');

// Swagger
const { swaggerUi, swaggerSpec } = require('./config/swagger');

// Import routes
const authRoutes = require('./routes/auth');
const appointmentRoutes = require('./routes/appointments');
const medicalRecordRoutes = require('./routes/medicalRecords');
const hospitalRoutes = require('./routes/hospitals');
const medicationRoutes = require('./routes/medications');
const emergencyRoutes = require('./routes/emergency');
const documentRoutes = require('./routes/documents');
const educationRoutes = require('./routes/education');
const userRoutes = require('./routes/users');

// Error handler middleware
const errorHandler = require('./middleware/errorHandler');

const app = express();
const server = http.createServer(app);

// =============================================================
// MIDDLEWARE SETUP
// =============================================================

// Security headers
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.FRONTEND_URL || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    status: 429,
    message: 'Too many requests, please try again later.'
  }
});
app.use('/api/', limiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression
app.use(compression());

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Static files for uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// =============================================================
// API DOCUMENTATION
// =============================================================
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'MedSeva API Documentation'
}));

// =============================================================
// ROUTES
// =============================================================
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/medical-records', medicalRecordRoutes);
app.use('/api/hospitals', hospitalRoutes);
app.use('/api/medications', medicationRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/documents', documentRoutes);
app.use('/api/education', educationRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'MedSeva API Server is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'MedSeva Telemedicine API',
    version: '1.0.0',
    documentation: '/api/docs',
    health: '/api/health'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'error',
    message: `Route ${req.originalUrl} not found`
  });
});

// Global error handler
app.use(errorHandler);

// =============================================================
// SERVER INITIALIZATION
// =============================================================
const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    // Connect to PostgreSQL
    await connectPostgreSQL();
    console.log('✅ PostgreSQL connected successfully');

    // Sync PostgreSQL models
    await sequelize.sync({ alter: process.env.NODE_ENV === 'development' });
    console.log('✅ PostgreSQL models synced');

    // Connect to MongoDB
    await connectMongoDB();
    console.log('✅ MongoDB connected successfully');

    // Create uploads directory if it doesn't exist
    const fs = require('fs');
    const uploadDir = path.join(__dirname, 'uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    // Start server
    server.listen(PORT, () => {
      console.log(`
╔══════════════════════════════════════════════╗
║                                              ║
║    🏥 MedSeva API Server                     ║
║    📡 Running on port ${PORT}                    ║
║    📋 API Docs: http://localhost:${PORT}/api/docs ║
║    🔧 Environment: ${process.env.NODE_ENV}            ║
║                                              ║
╚══════════════════════════════════════════════╝
      `);
    });

  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

module.exports = { app, server };

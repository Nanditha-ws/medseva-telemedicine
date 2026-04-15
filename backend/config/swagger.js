/**
 * Swagger API Documentation Configuration
 */

const swaggerJSDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'MedSeva Telemedicine API',
    version: '1.0.0',
    description: `
## MedSeva - Telemedicine Application API

A comprehensive REST API for the MedSeva telemedicine platform supporting:
- **Multi-role authentication** (Patient, Doctor, Hospital)
- **Medical record management** with secure storage
- **Appointment booking** and scheduling
- **Medication reminders** and tracking
- **Emergency access** for quick health data sharing
- **AI-based document scanning** using OpenCV
- **Hospital/ambulance finder** with geolocation
- **Health education** content for chronic diseases

### Authentication
All protected endpoints require a JWT Bearer token in the Authorization header:
\`Authorization: Bearer <token>\`
    `,
    contact: {
      name: 'MedSeva Support',
      email: 'support@medseva.com'
    },
    license: {
      name: 'MIT',
      url: 'https://opensource.org/licenses/MIT'
    }
  },
  servers: [
    {
      url: 'http://localhost:5000',
      description: 'Development Server'
    }
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Enter your JWT token'
      }
    },
    schemas: {
      Error: {
        type: 'object',
        properties: {
          status: { type: 'string', example: 'error' },
          message: { type: 'string' },
          errors: { type: 'array', items: { type: 'object' } }
        }
      },
      Success: {
        type: 'object',
        properties: {
          status: { type: 'string', example: 'success' },
          message: { type: 'string' },
          data: { type: 'object' }
        }
      }
    }
  },
  tags: [
    { name: 'Authentication', description: 'User registration, login, and token management' },
    { name: 'Users', description: 'User profile management' },
    { name: 'Appointments', description: 'Appointment booking and management' },
    { name: 'Medical Records', description: 'Medical record storage and retrieval' },
    { name: 'Medications', description: 'Medication reminders and tracking' },
    { name: 'Emergency', description: 'Emergency health data access' },
    { name: 'Documents', description: 'Document scanning and processing' },
    { name: 'Hospitals', description: 'Hospital and ambulance finder' },
    { name: 'Education', description: 'Health education content' }
  ]
};

const options = {
  swaggerDefinition,
  apis: ['./routes/*.js', './models/**/*.js']
};

const swaggerSpec = swaggerJSDoc(options);

module.exports = { swaggerUi, swaggerSpec };

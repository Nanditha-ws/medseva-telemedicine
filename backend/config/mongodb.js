/**
 * MongoDB Configuration & Connection
 * Uses Mongoose ODM for MongoDB operations
 */

const mongoose = require('mongoose');

async function connectMongoDB() {
  try {
    const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/medseva';
    
    await mongoose.connect(uri, {
      // Mongoose 8 uses these by default, but explicit for clarity
      autoIndex: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });

    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.warn('MongoDB disconnected. Attempting to reconnect...');
    });

    return true;
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    throw error;
  }
}

module.exports = { connectMongoDB, mongoose };

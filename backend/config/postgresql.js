/**
 * PostgreSQL Configuration & Connection
 * Uses Sequelize ORM for PostgreSQL database operations
 */

const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.PG_DATABASE || 'medseva',
  process.env.PG_USER || 'postgres',
  process.env.PG_PASSWORD || 'postgres',
  {
    host: process.env.PG_HOST || 'localhost',
    port: parseInt(process.env.PG_PORT) || 5432,
    dialect: 'postgres',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
      max: 20,
      min: 5,
      acquire: 60000,
      idle: 10000
    },
    define: {
      timestamps: true,
      underscored: true,
      freezeTableName: true
    }
  }
);

async function connectPostgreSQL() {
  try {
    await sequelize.authenticate();
    return true;
  } catch (error) {
    console.error('❌ PostgreSQL connection error:', error.message);
    throw error;
  }
}

module.exports = { sequelize, connectPostgreSQL };

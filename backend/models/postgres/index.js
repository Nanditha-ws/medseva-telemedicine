/**
 * PostgreSQL Models Index
 * Defines all Sequelize models and their relationships
 */

const { sequelize } = require('../../config/postgresql');
const { DataTypes } = require('sequelize');

// =============================================================
// USER MODEL
// =============================================================
const User = sequelize.define('users', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true,
    validate: { isEmail: true }
  },
  password: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  role: {
    type: DataTypes.ENUM('patient', 'doctor', 'hospital', 'admin'),
    allowNull: false,
    defaultValue: 'patient'
  },
  first_name: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  last_name: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: true
  },
  date_of_birth: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  gender: {
    type: DataTypes.ENUM('male', 'female', 'other'),
    allowNull: true
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  city: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  state: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  pincode: {
    type: DataTypes.STRING(10),
    allowNull: true
  },
  profile_image: {
    type: DataTypes.STRING(500),
    allowNull: true
  },
  blood_group: {
    type: DataTypes.ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    allowNull: true
  },
  emergency_contact_name: {
    type: DataTypes.STRING(200),
    allowNull: true
  },
  emergency_contact_phone: {
    type: DataTypes.STRING(20),
    allowNull: true
  },
  allergies: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  chronic_conditions: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  is_verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  last_login: {
    type: DataTypes.DATE,
    allowNull: true
  },
  refresh_token: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  indexes: [
    { fields: ['email'] },
    { fields: ['role'] },
    { fields: ['phone'] },
    { fields: ['city', 'state'] }
  ]
});

// =============================================================
// DOCTOR PROFILE MODEL
// =============================================================
const DoctorProfile = sequelize.define('doctor_profiles', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  specialization: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  qualification: {
    type: DataTypes.STRING(500),
    allowNull: false
  },
  experience_years: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0
  },
  registration_number: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true
  },
  consultation_fee: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    defaultValue: 0
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  languages: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: ['English']
  },
  available_days: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  },
  available_from: {
    type: DataTypes.TIME,
    allowNull: true,
    defaultValue: '09:00:00'
  },
  available_to: {
    type: DataTypes.TIME,
    allowNull: true,
    defaultValue: '17:00:00'
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  rating: {
    type: DataTypes.DECIMAL(2, 1),
    defaultValue: 0,
    validate: { min: 0, max: 5 }
  },
  total_reviews: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  hospital_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: { model: 'hospitals', key: 'id' }
  }
}, {
  indexes: [
    { fields: ['user_id'] },
    { fields: ['specialization'] },
    { fields: ['hospital_id'] },
    { fields: ['is_available'] }
  ]
});

// =============================================================
// HOSPITAL MODEL
// =============================================================
const Hospital = sequelize.define('hospitals', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: { model: 'users', key: 'id' }
  },
  name: {
    type: DataTypes.STRING(300),
    allowNull: false
  },
  type: {
    type: DataTypes.ENUM('hospital', 'clinic', 'diagnostic_center', 'pharmacy'),
    defaultValue: 'hospital'
  },
  registration_number: {
    type: DataTypes.STRING(100),
    allowNull: true,
    unique: true
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  city: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  state: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  pincode: {
    type: DataTypes.STRING(10),
    allowNull: false
  },
  phone: {
    type: DataTypes.STRING(20),
    allowNull: false
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  website: {
    type: DataTypes.STRING(500),
    allowNull: true
  },
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true
  },
  specializations: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: []
  },
  facilities: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: []
  },
  emergency_services: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  ambulance_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  ambulance_phone: {
    type: DataTypes.STRING(20),
    allowNull: true
  },
  operating_hours: {
    type: DataTypes.JSONB,
    defaultValue: { open: '00:00', close: '23:59', is24Hours: true }
  },
  rating: {
    type: DataTypes.DECIMAL(2, 1),
    defaultValue: 0
  },
  total_reviews: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  image_url: {
    type: DataTypes.STRING(500),
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  is_verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  indexes: [
    { fields: ['city', 'state'] },
    { fields: ['latitude', 'longitude'] },
    { fields: ['emergency_services'] },
    { fields: ['ambulance_available'] },
    { fields: ['type'] },
    { fields: ['is_active'] }
  ]
});

// =============================================================
// APPOINTMENT MODEL
// =============================================================
const Appointment = sequelize.define('appointments', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  patient_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  doctor_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  hospital_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: { model: 'hospitals', key: 'id' }
  },
  appointment_date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  appointment_time: {
    type: DataTypes.TIME,
    allowNull: false
  },
  duration_minutes: {
    type: DataTypes.INTEGER,
    defaultValue: 30
  },
  type: {
    type: DataTypes.ENUM('in_person', 'video_call', 'phone_call'),
    defaultValue: 'in_person'
  },
  status: {
    type: DataTypes.ENUM('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'),
    defaultValue: 'pending'
  },
  reason: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  symptoms: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  doctor_notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  prescription_id: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  consultation_fee: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'refunded'),
    defaultValue: 'pending'
  },
  cancellation_reason: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  cancelled_by: {
    type: DataTypes.ENUM('patient', 'doctor', 'system'),
    allowNull: true
  }
}, {
  indexes: [
    { fields: ['patient_id'] },
    { fields: ['doctor_id'] },
    { fields: ['appointment_date'] },
    { fields: ['status'] },
    { fields: ['patient_id', 'status'] },
    { fields: ['doctor_id', 'appointment_date'] }
  ]
});

// =============================================================
// MEDICATION REMINDER MODEL
// =============================================================
const MedicationReminder = sequelize.define('medication_reminders', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  medication_name: {
    type: DataTypes.STRING(200),
    allowNull: false
  },
  dosage: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  frequency: {
    type: DataTypes.ENUM('once_daily', 'twice_daily', 'thrice_daily', 'four_times_daily', 'weekly', 'as_needed'),
    allowNull: false
  },
  times: {
    type: DataTypes.ARRAY(DataTypes.TIME),
    allowNull: false
  },
  start_date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  end_date: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  instructions: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  prescribed_by: {
    type: DataTypes.UUID,
    allowNull: true,
    references: { model: 'users', key: 'id' }
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  refill_reminder: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  refill_date: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  side_effects: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  indexes: [
    { fields: ['user_id'] },
    { fields: ['is_active'] },
    { fields: ['user_id', 'is_active'] }
  ]
});

// =============================================================
// MEDICATION LOG (tracking adherence)
// =============================================================
const MedicationLog = sequelize.define('medication_logs', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  reminder_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'medication_reminders', key: 'id' }
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  taken_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  },
  scheduled_time: {
    type: DataTypes.TIME,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('taken', 'missed', 'skipped'),
    defaultValue: 'taken'
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  indexes: [
    { fields: ['reminder_id'] },
    { fields: ['user_id', 'taken_at'] }
  ]
});

// =============================================================
// EMERGENCY ACCESS MODEL
// =============================================================
const EmergencyAccess = sequelize.define('emergency_access', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' }
  },
  access_code: {
    type: DataTypes.STRING(20),
    allowNull: false,
    unique: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  share_medical_records: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  share_medications: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  share_allergies: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  share_emergency_contacts: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  accessed_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  last_accessed_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  last_accessed_by: {
    type: DataTypes.STRING(100),
    allowNull: true
  }
}, {
  indexes: [
    { fields: ['user_id'] },
    { fields: ['access_code'], unique: true },
    { fields: ['is_active'] }
  ]
});

// =============================================================
// RELATIONSHIPS
// =============================================================

// User <-> DoctorProfile
User.hasOne(DoctorProfile, { foreignKey: 'user_id', as: 'doctorProfile' });
DoctorProfile.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// User <-> Hospital
User.hasOne(Hospital, { foreignKey: 'user_id', as: 'hospital' });
Hospital.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// Doctor <-> Hospital
Hospital.hasMany(DoctorProfile, { foreignKey: 'hospital_id', as: 'doctors' });
DoctorProfile.belongsTo(Hospital, { foreignKey: 'hospital_id', as: 'hospital' });

// Appointments
User.hasMany(Appointment, { foreignKey: 'patient_id', as: 'patientAppointments' });
User.hasMany(Appointment, { foreignKey: 'doctor_id', as: 'doctorAppointments' });
Appointment.belongsTo(User, { foreignKey: 'patient_id', as: 'patient' });
Appointment.belongsTo(User, { foreignKey: 'doctor_id', as: 'doctor' });
Appointment.belongsTo(Hospital, { foreignKey: 'hospital_id', as: 'hospital' });

// Medication Reminders
User.hasMany(MedicationReminder, { foreignKey: 'user_id', as: 'medications' });
MedicationReminder.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
MedicationReminder.belongsTo(User, { foreignKey: 'prescribed_by', as: 'prescribedByDoctor' });

// Medication Logs
MedicationReminder.hasMany(MedicationLog, { foreignKey: 'reminder_id', as: 'logs' });
MedicationLog.belongsTo(MedicationReminder, { foreignKey: 'reminder_id', as: 'reminder' });
User.hasMany(MedicationLog, { foreignKey: 'user_id', as: 'medicationLogs' });
MedicationLog.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// Emergency Access
User.hasMany(EmergencyAccess, { foreignKey: 'user_id', as: 'emergencyAccess' });
EmergencyAccess.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

module.exports = {
  User,
  DoctorProfile,
  Hospital,
  Appointment,
  MedicationReminder,
  MedicationLog,
  EmergencyAccess
};

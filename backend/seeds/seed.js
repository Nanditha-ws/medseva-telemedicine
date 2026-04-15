/**
 * Database Seed Script
 * Populates the database with sample data for development
 */

require('dotenv').config();
const bcrypt = require('bcryptjs');
const { connectPostgreSQL, sequelize } = require('../config/postgresql');
const { connectMongoDB } = require('../config/mongodb');
const { User, DoctorProfile, Hospital, Appointment, MedicationReminder } = require('../models/postgres');
const MedicalRecord = require('../models/mongo/MedicalRecord');
const EducationContent = require('../models/mongo/EducationContent');

async function seed() {
  try {
    await connectPostgreSQL();
    await connectMongoDB();
    await sequelize.sync({ force: true });
    console.log('✅ Database synced');

    const password = await bcrypt.hash('password123', 12);

    // Create Users
    const patient1 = await User.create({
      email: 'patient@medseva.com', password, role: 'patient',
      first_name: 'Rajesh', last_name: 'Kumar', phone: '+91-9876543210',
      date_of_birth: '1990-05-15', gender: 'male', blood_group: 'B+',
      city: 'Mumbai', state: 'Maharashtra', pincode: '400001',
      allergies: 'Penicillin, Dust', chronic_conditions: 'Mild Asthma',
      emergency_contact_name: 'Priya Kumar', emergency_contact_phone: '+91-9876543211',
      is_verified: true
    });

    const patient2 = await User.create({
      email: 'anita@medseva.com', password, role: 'patient',
      first_name: 'Anita', last_name: 'Sharma', phone: '+91-9876543212',
      date_of_birth: '1985-08-22', gender: 'female', blood_group: 'O+',
      city: 'Delhi', state: 'Delhi', pincode: '110001',
      is_verified: true
    });

    const doctor1 = await User.create({
      email: 'doctor@medseva.com', password, role: 'doctor',
      first_name: 'Dr. Arun', last_name: 'Patel', phone: '+91-9876543213',
      date_of_birth: '1978-03-10', gender: 'male', city: 'Mumbai',
      state: 'Maharashtra', is_verified: true
    });

    const doctor2 = await User.create({
      email: 'meera@medseva.com', password, role: 'doctor',
      first_name: 'Dr. Meera', last_name: 'Gupta', phone: '+91-9876543214',
      date_of_birth: '1982-11-05', gender: 'female', city: 'Delhi',
      state: 'Delhi', is_verified: true
    });

    const hospitalUser = await User.create({
      email: 'hospital@medseva.com', password, role: 'hospital',
      first_name: 'Admin', last_name: 'LifeCare', phone: '+91-9876543215',
      is_verified: true
    });

    // Create Hospitals
    const hospital1 = await Hospital.create({
      user_id: hospitalUser.id, name: 'LifeCare Multi-Specialty Hospital',
      type: 'hospital', registration_number: 'HOSP-MH-2020-001',
      description: 'A leading multi-specialty hospital with state-of-the-art facilities',
      address: '123 Health Street, Andheri West', city: 'Mumbai',
      state: 'Maharashtra', pincode: '400058', phone: '+91-22-12345678',
      email: 'info@lifecare.com', latitude: 19.1364, longitude: 72.8296,
      specializations: ['Cardiology', 'Neurology', 'Orthopedics', 'Pediatrics', 'General Medicine'],
      facilities: ['ICU', 'OT', 'Pharmacy', 'Lab', 'Radiology', 'Ambulance'],
      emergency_services: true, ambulance_available: true,
      ambulance_phone: '+91-22-12345679', rating: 4.5, is_verified: true
    });

    const hospital2 = await Hospital.create({
      name: 'City Care Clinic', type: 'clinic',
      address: '45 Wellness Road, Connaught Place', city: 'Delhi',
      state: 'Delhi', pincode: '110001', phone: '+91-11-98765432',
      latitude: 28.6315, longitude: 77.2167,
      specializations: ['General Medicine', 'Dermatology', 'ENT'],
      facilities: ['Pharmacy', 'Lab'], emergency_services: false,
      ambulance_available: false, rating: 4.2, is_verified: true
    });

    // Create Doctor Profiles
    await DoctorProfile.create({
      user_id: doctor1.id, specialization: 'Cardiology',
      qualification: 'MBBS, MD (Cardiology), DM', experience_years: 15,
      registration_number: 'MH-DOC-2009-4521', consultation_fee: 1500,
      bio: 'Senior Cardiologist with 15+ years of experience in interventional cardiology.',
      languages: ['English', 'Hindi', 'Marathi'],
      available_days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      available_from: '09:00:00', available_to: '17:00:00',
      is_available: true, rating: 4.8, total_reviews: 124, hospital_id: hospital1.id
    });

    await DoctorProfile.create({
      user_id: doctor2.id, specialization: 'General Medicine',
      qualification: 'MBBS, MD (Internal Medicine)', experience_years: 10,
      registration_number: 'DL-DOC-2014-7832', consultation_fee: 800,
      bio: 'Experienced physician specializing in preventive healthcare and chronic disease management.',
      languages: ['English', 'Hindi'],
      available_days: ['Monday', 'Wednesday', 'Friday', 'Saturday'],
      available_from: '10:00:00', available_to: '18:00:00',
      is_available: true, rating: 4.6, total_reviews: 89, hospital_id: hospital2.id
    });

    // Create Appointments
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const nextWeek = new Date();
    nextWeek.setDate(nextWeek.getDate() + 7);

    await Appointment.create({
      patient_id: patient1.id, doctor_id: doctor1.id, hospital_id: hospital1.id,
      appointment_date: tomorrow.toISOString().split('T')[0],
      appointment_time: '10:00:00', type: 'in_person',
      reason: 'Regular heart checkup', symptoms: 'Mild chest discomfort',
      status: 'confirmed', consultation_fee: 1500
    });

    await Appointment.create({
      patient_id: patient2.id, doctor_id: doctor2.id, hospital_id: hospital2.id,
      appointment_date: nextWeek.toISOString().split('T')[0],
      appointment_time: '14:00:00', type: 'video_call',
      reason: 'Follow-up consultation', status: 'pending', consultation_fee: 800
    });

    // Create Medication Reminders
    await MedicationReminder.create({
      user_id: patient1.id, medication_name: 'Metoprolol', dosage: '50mg',
      frequency: 'twice_daily', times: ['08:00:00', '20:00:00'],
      start_date: '2024-01-01', instructions: 'Take with food',
      prescribed_by: doctor1.id, is_active: true
    });

    await MedicationReminder.create({
      user_id: patient1.id, medication_name: 'Aspirin', dosage: '75mg',
      frequency: 'once_daily', times: ['09:00:00'],
      start_date: '2024-01-01', instructions: 'Take after breakfast',
      prescribed_by: doctor1.id, is_active: true
    });

    // Seed MongoDB - Medical Records
    await MedicalRecord.deleteMany({});
    await MedicalRecord.create({
      patient_id: patient1.id, doctor_id: doctor1.id,
      record_type: 'lab_report', title: 'Complete Blood Count (CBC)',
      description: 'Routine blood test', diagnosis: 'Normal',
      lab_results: [
        { test_name: 'Hemoglobin', value: '14.5', unit: 'g/dL', reference_range: '13.5-17.5', status: 'normal' },
        { test_name: 'WBC Count', value: '7200', unit: '/μL', reference_range: '4500-11000', status: 'normal' },
        { test_name: 'Platelet Count', value: '250000', unit: '/μL', reference_range: '150000-400000', status: 'normal' }
      ],
      vitals: { blood_pressure: '120/80', heart_rate: 72, temperature: 98.6, weight: 75, height: 175 },
      tags: ['blood-test', 'routine', 'cbc']
    });

    await MedicalRecord.create({
      patient_id: patient1.id, doctor_id: doctor1.id,
      record_type: 'prescription', title: 'Cardiology Prescription - Jan 2024',
      description: 'Regular medication prescription',
      medications: [
        { name: 'Metoprolol', dosage: '50mg', frequency: 'Twice daily', duration: '3 months', instructions: 'Take with food' },
        { name: 'Aspirin', dosage: '75mg', frequency: 'Once daily', duration: '6 months', instructions: 'Take after breakfast' }
      ],
      tags: ['prescription', 'cardiology']
    });

    // Seed Education Content
    await EducationContent.deleteMany({});
    const articles = [
      {
        title: 'Understanding Diabetes: A Comprehensive Guide',
        slug: 'understanding-diabetes-comprehensive-guide',
        content: `# Understanding Diabetes\n\nDiabetes is a chronic condition that affects how your body processes blood sugar (glucose). There are several types:\n\n## Type 1 Diabetes\nAn autoimmune condition where the body attacks insulin-producing cells.\n\n## Type 2 Diabetes\nThe most common form, where the body becomes resistant to insulin or doesn't produce enough.\n\n## Management Tips\n- Monitor blood sugar regularly\n- Maintain a healthy diet\n- Exercise regularly\n- Take medications as prescribed\n- Regular check-ups with your doctor\n\n## Warning Signs\n- Increased thirst\n- Frequent urination\n- Unexplained weight loss\n- Fatigue\n- Blurred vision`,
        summary: 'Learn about different types of diabetes, their symptoms, and effective management strategies.',
        category: 'diabetes',
        tags: ['diabetes', 'blood-sugar', 'insulin', 'chronic-disease'],
        author: { name: 'Dr. Arun Patel', credentials: 'MD, Endocrinology' },
        reading_time_minutes: 8, difficulty_level: 'beginner'
      },
      {
        title: 'Heart Health: Prevention and Care',
        slug: 'heart-health-prevention-care',
        content: `# Heart Health Guide\n\nCardiovascular disease is the leading cause of death worldwide. Here's how to protect your heart.\n\n## Risk Factors\n- High blood pressure\n- High cholesterol\n- Smoking\n- Obesity\n- Sedentary lifestyle\n\n## Prevention\n1. **Exercise regularly** - At least 150 minutes of moderate activity per week\n2. **Eat heart-healthy** - Mediterranean diet rich in fruits, vegetables, whole grains\n3. **Manage stress** - Practice meditation or yoga\n4. **Quit smoking** - Single most impactful change\n5. **Monitor BP** - Regular check-ups\n\n## When to Seek Help\n- Chest pain or discomfort\n- Shortness of breath\n- Dizziness or lightheadedness\n- Rapid or irregular heartbeat`,
        summary: 'Essential guide to maintaining heart health through prevention, diet, and lifestyle changes.',
        category: 'heart_disease',
        tags: ['heart', 'cardiology', 'prevention', 'exercise'],
        author: { name: 'Dr. Arun Patel', credentials: 'MBBS, MD Cardiology' },
        reading_time_minutes: 6, difficulty_level: 'beginner'
      },
      {
        title: 'Managing Hypertension Naturally',
        slug: 'managing-hypertension-naturally',
        content: `# Managing Hypertension\n\nHigh blood pressure often has no symptoms but can lead to serious health problems.\n\n## What is Normal BP?\n- Normal: Less than 120/80 mmHg\n- Elevated: 120-129/<80 mmHg\n- Stage 1: 130-139/80-89 mmHg\n- Stage 2: 140+/90+ mmHg\n\n## Natural Management\n- Reduce sodium intake\n- DASH diet\n- Regular physical activity\n- Limit alcohol\n- Reduce stress\n- Maintain healthy weight`,
        summary: 'Learn natural ways to manage and control high blood pressure effectively.',
        category: 'hypertension',
        tags: ['hypertension', 'blood-pressure', 'natural-remedies'],
        author: { name: 'Dr. Meera Gupta', credentials: 'MBBS, MD Internal Medicine' },
        reading_time_minutes: 5, difficulty_level: 'beginner'
      },
      {
        title: 'Mental Health Awareness: Breaking the Stigma',
        slug: 'mental-health-awareness-breaking-stigma',
        content: `# Mental Health Matters\n\nMental health is just as important as physical health.\n\n## Common Conditions\n- Depression\n- Anxiety disorders\n- PTSD\n- Bipolar disorder\n\n## Self-Care Strategies\n1. Practice mindfulness\n2. Stay connected with loved ones\n3. Get adequate sleep\n4. Exercise regularly\n5. Seek professional help when needed\n\n## When to Get Help\nIf symptoms persist for more than two weeks or interfere with daily life, consult a mental health professional.`,
        summary: 'Understanding mental health conditions and the importance of seeking help.',
        category: 'mental_health',
        tags: ['mental-health', 'depression', 'anxiety', 'self-care'],
        author: { name: 'Dr. Meera Gupta', credentials: 'MBBS, MD Psychiatry' },
        reading_time_minutes: 7, difficulty_level: 'beginner'
      },
      {
        title: 'Nutrition for Better Health',
        slug: 'nutrition-for-better-health',
        content: `# Nutrition Guide\n\nGood nutrition is the foundation of good health.\n\n## Balanced Diet\n- 50% fruits and vegetables\n- 25% whole grains\n- 25% lean protein\n\n## Superfoods\n- Turmeric\n- Green leafy vegetables\n- Berries\n- Nuts and seeds\n- Fish\n\n## Hydration\nDrink at least 8 glasses of water daily.`,
        summary: 'A practical guide to nutrition for maintaining optimal health.',
        category: 'nutrition',
        tags: ['nutrition', 'diet', 'superfoods', 'healthy-eating'],
        author: { name: 'Dr. Meera Gupta', credentials: 'MBBS, Nutrition Specialist' },
        reading_time_minutes: 5, difficulty_level: 'beginner'
      }
    ];

    await EducationContent.insertMany(articles);

    console.log('✅ Seed data inserted successfully');
    console.log('\n📧 Test Accounts:');
    console.log('   Patient: patient@medseva.com / password123');
    console.log('   Doctor:  doctor@medseva.com  / password123');
    console.log('   Hospital: hospital@medseva.com / password123');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  }
}

seed();

# MedSeva - Telemedicine Mobile Application

<div align="center">

🏥 **MedSeva** - Your Health, Our Priority

A full-stack cross-platform telemedicine application built with Flutter, Node.js, PostgreSQL, MongoDB, and OpenCV.

</div>

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Test Accounts](#test-accounts)

---

## 🏗️ Architecture Overview

```
┌──────────────────┐        ┌──────────────────────────┐
│   Flutter App    │  REST  │   Node.js + Express.js   │
│   (Android/iOS)  │◄──────►│      API Server          │
└──────────────────┘  API   └──────────┬───────────────┘
                                       │
                        ┌──────────────┼──────────────┐
                        │              │              │
                   ┌────▼─────┐  ┌─────▼─────┐ ┌─────▼──────┐
                   │PostgreSQL│  │  MongoDB   │ │   OpenCV   │
                   │(Users,   │  │(Records,   │ │(Document   │
                   │Appts)    │  │Prescripts) │ │ Scanning)  │
                   └──────────┘  └───────────┘  └────────────┘
```

## 🛠️ Tech Stack

| Layer      | Technology                                   |
|------------|----------------------------------------------|
| Frontend   | Flutter (Dart), Provider, GoRouter, Dio       |
| Backend    | Node.js, Express.js, JWT, Multer              |
| Database   | PostgreSQL (Sequelize), MongoDB (Mongoose)     |
| CV/Imaging | Sharp (OpenCV-compatible image processing)     |
| API Docs   | Swagger/OpenAPI 3.0                            |

## ✨ Features

### 🔐 Authentication
- Multi-role signup/login (Patient, Doctor, Hospital)
- JWT access + refresh tokens
- Role-based authorization

### 📁 Medical Records
- CRUD operations with file attachments
- Lab reports, prescriptions, diagnoses, imaging
- Record sharing between patients and doctors
- Full-text search

### ⏰ Medication Reminders
- Create reminders with multiple daily times
- Track adherence (taken/missed/skipped)
- Adherence rate reporting

### 📅 Appointments
- Book with doctor selection
- In-person, video call, phone call types
- Status management (pending → confirmed → completed)
- Conflict detection

### 🚑 Emergency Access
- Generate time-limited access codes
- Configurable data sharing settings
- No-auth access for emergency responders
- Access tracking

### 📍 Hospital Finder
- Search by city, type, specialization
- Emergency & ambulance filters
- Nearby search using Haversine formula
- Hospital details with doctor listings

### 📄 Document Scanner (OpenCV)
- Camera & gallery image capture
- Edge detection (Laplacian kernel convolution)
- Perspective correction & auto-trim
- Image enhancement & thresholding
- Clean document generation (A4/Letter)

### 📚 Health Education
- Articles categorized by chronic disease
- Full-text search
- View & like tracking
- Doctor-authored content

---

## 📂 Project Structure

```
medseva/
├── backend/
│   ├── server.js                 # Express entry point
│   ├── package.json
│   ├── .env / .env.example
│   ├── config/
│   │   ├── postgresql.js         # Sequelize connection
│   │   ├── mongodb.js            # Mongoose connection
│   │   └── swagger.js            # Swagger docs config
│   ├── middleware/
│   │   ├── auth.js               # JWT auth + RBAC
│   │   ├── errorHandler.js       # Global error handler
│   │   ├── upload.js             # Multer file uploads
│   │   └── validate.js           # Express-validator
│   ├── models/
│   │   ├── postgres/index.js     # All Sequelize models
│   │   └── mongo/
│   │       ├── MedicalRecord.js
│   │       ├── ScannedDocument.js
│   │       └── EducationContent.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── appointmentController.js
│   │   ├── medicalRecordController.js
│   │   ├── hospitalController.js
│   │   ├── medicationController.js
│   │   ├── emergencyController.js
│   │   ├── documentController.js
│   │   ├── educationController.js
│   │   └── userController.js
│   ├── routes/
│   │   ├── auth.js, users.js, appointments.js
│   │   ├── medicalRecords.js, hospitals.js
│   │   ├── medications.js, emergency.js
│   │   ├── documents.js, education.js
│   ├── services/
│   │   └── opencv/documentScanner.js
│   └── seeds/seed.js
│
├── frontend/
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   │   ├── app_theme.dart    # Design system
│   │   │   ├── api_config.dart   # API endpoints
│   │   │   └── routes.dart       # GoRouter config
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   ├── appointment.dart
│   │   │   ├── medical_record.dart
│   │   │   └── medication_reminder.dart
│   │   ├── services/
│   │   │   └── api_service.dart  # Dio HTTP client
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── appointment_provider.dart
│   │   │   ├── medication_provider.dart
│   │   │   └── theme_provider.dart
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── auth/ (login, signup, role_selection)
│   │   │   ├── home/home_screen.dart
│   │   │   ├── appointments/ (list, book)
│   │   │   ├── medical_records/ (list, detail)
│   │   │   ├── medications/ (list, add)
│   │   │   ├── emergency/
│   │   │   ├── hospitals/ (finder, detail)
│   │   │   ├── document_scanner/
│   │   │   ├── education/ (list, article)
│   │   │   └── profile/
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       └── custom_text_field.dart
│   └── assets/
│
└── docs/
    └── README.md
```

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

| Tool          | Version    | Download                                    |
|---------------|------------|---------------------------------------------|
| Node.js       | ≥ 18.x     | https://nodejs.org                          |
| PostgreSQL    | ≥ 14.x     | https://postgresql.org/download             |
| MongoDB       | ≥ 6.x      | https://mongodb.com/try/download            |
| Flutter SDK   | ≥ 3.10     | https://flutter.dev/docs/get-started/install |
| Android Studio| Latest     | https://developer.android.com/studio        |
| Git           | Latest     | https://git-scm.com                         |

---

## 🚀 Setup Instructions

### Step 1: Clone the Repository

```bash
cd medseva
```

### Step 2: Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Configure environment variables
# Edit .env file with your database credentials
cp .env.example .env

# Create PostgreSQL database
psql -U postgres -c "CREATE DATABASE medseva;"

# Start MongoDB (if not already running)
mongod --dbpath /data/db

# Seed the database with sample data
npm run seed

# Start the development server
npm run dev
```

The API server will start on **http://localhost:5000**

### Step 3: Verify Backend

```bash
# Health check
curl http://localhost:5000/api/health

# Open Swagger docs in browser
open http://localhost:5000/api/docs
```

### Step 4: Flutter Frontend Setup

```bash
# Navigate to frontend
cd ../frontend

# Get Flutter dependencies
flutter pub get

# Create asset directories
mkdir -p assets/images assets/icons assets/animations assets/fonts

# Run on Android emulator
flutter run

# Or on iOS simulator
flutter run -d ios

# Or on Chrome (web)
flutter run -d chrome
```

### Step 5: Connect Frontend to Backend

For **Android Emulator**, the API base URL uses `10.0.2.2` (already configured in `api_config.dart`).

For **iOS Simulator**, change to `localhost`:
```dart
// In lib/config/api_config.dart
static const String baseUrl = 'http://localhost:5000';
```

For **Physical Device**, use your machine's local IP:
```dart
static const String baseUrl = 'http://192.168.x.x:5000';
```

---

## 📡 API Documentation

### Base URL: `http://localhost:5000/api`

### Interactive Docs: `http://localhost:5000/api/docs` (Swagger UI)

### Key Endpoints

| Method | Endpoint                      | Auth | Description                    |
|--------|-------------------------------|------|--------------------------------|
| POST   | /auth/register                | No   | Register new user              |
| POST   | /auth/login                   | No   | Login                          |
| GET    | /auth/me                      | Yes  | Get current user               |
| POST   | /auth/refresh                 | No   | Refresh token                  |
| GET    | /users/profile                | Yes  | Get user profile               |
| PUT    | /users/profile                | Yes  | Update profile                 |
| GET    | /users/doctors                | Yes  | Search doctors                 |
| POST   | /appointments                 | Yes  | Book appointment               |
| GET    | /appointments                 | Yes  | List appointments              |
| GET    | /appointments/upcoming        | Yes  | Upcoming appointments          |
| POST   | /medical-records              | Yes  | Create medical record          |
| GET    | /medical-records              | Yes  | List medical records           |
| POST   | /medical-records/:id/share    | Yes  | Share with doctor              |
| GET    | /hospitals                    | No   | Search hospitals               |
| GET    | /hospitals/nearby             | No   | Find nearby hospitals          |
| POST   | /medications                  | Yes  | Create medication reminder     |
| POST   | /medications/:id/log          | Yes  | Log medication taken/missed    |
| GET    | /medications/:id/adherence    | Yes  | Get adherence report           |
| POST   | /emergency/generate-code      | Yes  | Generate emergency access code |
| GET    | /emergency/access/:code       | No   | Access emergency data          |
| POST   | /documents/scan               | Yes  | Scan document (file upload)    |
| GET    | /education                    | No   | Get health education articles  |

---

## 🗄️ Database Schema

### PostgreSQL (Structured Data)
- **users** - All user accounts with role-based fields
- **doctor_profiles** - Doctor specializations, fees, availability
- **hospitals** - Hospital details with geolocation
- **appointments** - Booking records with status tracking
- **medication_reminders** - Medication schedules
- **medication_logs** - Adherence tracking
- **emergency_access** - Access codes with sharing settings

### MongoDB (Unstructured Data)
- **medical_records** - Lab reports, prescriptions, vitals, attachments
- **scanned_documents** - Processed document images with metadata
- **education_content** - Health articles with categories and engagement

---

## 🔑 Test Accounts

| Role     | Email                   | Password     |
|----------|-------------------------|--------------|
| Patient  | patient@medseva.com     | password123  |
| Doctor   | doctor@medseva.com      | password123  |
| Hospital | hospital@medseva.com    | password123  |

---

## 📝 License

This project is licensed under the MIT License.

---

<div align="center">

**Built with ❤️ for healthcare accessibility**

🏥 MedSeva - Telemedicine for Everyone

</div>

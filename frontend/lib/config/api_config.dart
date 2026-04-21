/// API Configuration
/// Centralized API endpoints and configuration
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Base URL - checks platform dynamically
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    } else {
      return 'http://localhost:5000';
    }
  }

  static const String apiPrefix = '/api';

  // Auth endpoints
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String refreshToken = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';
  static const String me = '$apiPrefix/auth/me';
  static const String changePassword = '$apiPrefix/auth/change-password';

  // User endpoints
  static const String profile = '$apiPrefix/users/profile';
  static const String profileImage = '$apiPrefix/users/profile-image';
  static const String doctors = '$apiPrefix/users/doctors';

  // Appointment endpoints
  static const String appointments = '$apiPrefix/appointments';
  static const String upcomingAppointments = '$apiPrefix/appointments/upcoming';

  // Medical Record endpoints
  static const String medicalRecords = '$apiPrefix/medical-records';

  // Hospital endpoints
  static const String hospitals = '$apiPrefix/hospitals';
  static const String nearbyHospitals = '$apiPrefix/hospitals/nearby';

  // Medication endpoints
  static const String medications = '$apiPrefix/medications';

  // Emergency endpoints
  static const String emergencyGenerateCode = '$apiPrefix/emergency/generate-code';
  static const String emergencyAccess = '$apiPrefix/emergency/access';
  static const String emergencyMyCodes = '$apiPrefix/emergency/my-codes';
  static const String emergencyMyInfo = '$apiPrefix/emergency/my-info';

  // Document endpoints
  static const String documentScan = '$apiPrefix/documents/scan';
  static const String documents = '$apiPrefix/documents';
  static const String documentClean = '$apiPrefix/documents/clean';

  // Education endpoints
  static const String education = '$apiPrefix/education';
  static const String educationCategories = '$apiPrefix/education/categories';

  // Health check
  static const String health = '$apiPrefix/health';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

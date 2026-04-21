/// App Router Configuration using GoRouter
/// Handles all navigation and routing
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/appointments/appointment_list_screen.dart';
import '../screens/appointments/book_appointment_screen.dart';
import '../screens/medical_records/records_screen.dart';
import '../screens/medical_records/record_detail_screen.dart';
import '../screens/medications/medication_list_screen.dart';
import '../screens/medications/add_medication_screen.dart';
import '../screens/emergency/emergency_screen.dart';
import '../screens/hospitals/hospital_finder_screen.dart';
import '../screens/hospitals/hospital_detail_screen.dart';
import '../screens/document_scanner/scanner_screen.dart';
import '../screens/education/education_screen.dart';
import '../screens/education/article_detail_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Appointments
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => const AppointmentListScreen(),
      ),
      GoRoute(
        path: '/book-appointment',
        name: 'book-appointment',
        builder: (context, state) => const BookAppointmentScreen(),
      ),

      // Medical Records
      GoRoute(
        path: '/medical-records',
        name: 'medical-records',
        builder: (context, state) => const RecordsScreen(),
      ),
      GoRoute(
        path: '/medical-records/:id',
        name: 'record-detail',
        builder: (context, state) => RecordDetailScreen(
          recordId: state.pathParameters['id']!,
        ),
      ),

      // Medications
      GoRoute(
        path: '/medications',
        name: 'medications',
        builder: (context, state) => const MedicationListScreen(),
      ),
      GoRoute(
        path: '/add-medication',
        name: 'add-medication',
        builder: (context, state) => const AddMedicationScreen(),
      ),

      // Emergency
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),

      // Hospitals
      GoRoute(
        path: '/hospitals',
        name: 'hospitals',
        builder: (context, state) => const HospitalFinderScreen(),
      ),
      GoRoute(
        path: '/hospitals/:id',
        name: 'hospital-detail',
        builder: (context, state) => HospitalDetailScreen(
          hospitalId: state.pathParameters['id']!,
        ),
      ),

      // Document Scanner
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const ScannerScreen(),
      ),

      // Education
      GoRoute(
        path: '/education',
        name: 'education',
        builder: (context, state) => const EducationScreen(),
      ),
      GoRoute(
        path: '/education/:slug',
        name: 'article-detail',
        builder: (context, state) => ArticleDetailScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(state.uri.toString(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

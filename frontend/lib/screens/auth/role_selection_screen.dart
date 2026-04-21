/// Role Selection Screen - Choose user type before signup
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join MedSeva')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('I am a...', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Select your role to get started', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 40),
            _RoleCard(
              icon: Icons.person_rounded,
              title: 'Patient',
              subtitle: 'Book appointments, manage records, get reminders',
              color: AppTheme.accentBlue,
              gradient: const LinearGradient(colors: [Color(0xFF4E9AF1), Color(0xFF7CB9F8)]),
              onTap: () => context.push('/signup', extra: 'patient'),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              icon: Icons.medical_services_rounded,
              title: 'Doctor',
              subtitle: 'Manage appointments, create prescriptions',
              color: AppTheme.accentGreen,
              gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF81C784)]),
              onTap: () => context.push('/signup', extra: 'doctor'),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              icon: Icons.local_hospital_rounded,
              title: 'Hospital',
              subtitle: 'Register hospital, manage staff & services',
              color: AppTheme.accentPurple,
              gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)]),
              onTap: () => context.push('/signup', extra: 'hospital'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          color: color.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

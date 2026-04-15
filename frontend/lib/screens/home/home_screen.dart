/// Home Screen - Main dashboard with role-based content
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/medication_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
    appointmentProvider.fetchUpcoming();
    medicationProvider.fetchReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _DashboardTab(),
            _AppointmentsTab(),
            _RecordsTab(),
            _ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Appointments'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_rounded), label: 'Records'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

/// Dashboard Tab
class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,', style: Theme.of(context).textTheme.bodyLarge),
                    Text(
                      user?.firstName ?? 'User',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    user?.firstName.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Emergency Banner
          GestureDetector(
            onTap: () => context.push('/emergency'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.emergencyGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentRed.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Emergency Access', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Quick share your health data', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Grid
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              _QuickActionCard(icon: Icons.calendar_month_rounded, label: 'Book\nAppointment', color: AppTheme.accentBlue, onTap: () => context.push('/book-appointment')),
              _QuickActionCard(icon: Icons.local_hospital_rounded, label: 'Find\nHospital', color: AppTheme.accentGreen, onTap: () => context.push('/hospitals')),
              _QuickActionCard(icon: Icons.document_scanner_rounded, label: 'Scan\nDocument', color: AppTheme.accentPurple, onTap: () => context.push('/scanner')),
              _QuickActionCard(icon: Icons.medication_rounded, label: 'Medication\nReminders', color: AppTheme.accentOrange, onTap: () => context.push('/medications')),
              _QuickActionCard(icon: Icons.menu_book_rounded, label: 'Health\nEducation', color: Color(0xFF26A69A), onTap: () => context.push('/education')),
              _QuickActionCard(icon: Icons.folder_shared_rounded, label: 'Medical\nRecords', color: Color(0xFFEC407A), onTap: () => context.push('/medical-records')),
            ],
          ),
          const SizedBox(height: 24),

          // Upcoming Appointments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Appointments', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => context.push('/appointments'),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Consumer<AppointmentProvider>(
            builder: (context, provider, child) {
              if (provider.upcoming.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.cardDecoration(context),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today, size: 48, color: AppTheme.lightText),
                        const SizedBox(height: 12),
                        Text('No upcoming appointments', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => context.push('/book-appointment'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Book Now'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: provider.upcoming.take(3).map((apt) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration(context),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(apt.appointmentDate.split('-').last, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.accentBlue)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(apt.doctorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('${apt.appointmentTime.substring(0, 5)} • ${apt.typeDisplay}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: apt.status == 'confirmed' ? AppTheme.accentGreen.withOpacity(0.1) : AppTheme.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          apt.statusDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: apt.status == 'confirmed' ? AppTheme.accentGreen : AppTheme.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // Medication Reminders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Medications', style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: () => context.push('/medications'), child: const Text('See All')),
            ],
          ),
          const SizedBox(height: 8),

          Consumer<MedicationProvider>(
            builder: (context, provider, child) {
              if (provider.reminders.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecoration(context),
                  child: Center(
                    child: Text('No active medications', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                );
              }
              return Column(
                children: provider.reminders.take(3).map((med) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.cardDecoration(context),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.medication, color: AppTheme.accentOrange, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.medicationName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${med.dosage} • ${med.frequencyDisplay}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Quick Action Card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

/// Stub tabs for bottom nav
class _AppointmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Loading...'));
  }
}

class _RecordsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Loading...'));
  }
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Loading...'));
  }
}

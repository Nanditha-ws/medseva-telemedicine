/// Profile Screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        body: Center(child: ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Login'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${user.role[0].toUpperCase()}${user.role.substring(1)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info cards
            Container(
              decoration: AppTheme.cardDecoration(context),
              child: Column(
                children: [
                  _ProfileItem(Icons.phone, 'Phone', user.phone ?? 'Not set'),
                  const Divider(height: 1, indent: 56),
                  _ProfileItem(Icons.calendar_today, 'Date of Birth', user.dateOfBirth ?? 'Not set'),
                  const Divider(height: 1, indent: 56),
                  _ProfileItem(Icons.bloodtype, 'Blood Group', user.bloodGroup ?? 'Not set'),
                  const Divider(height: 1, indent: 56),
                  _ProfileItem(Icons.location_on, 'City', '${user.city ?? ''} ${user.state ?? ''}'.trim().isEmpty ? 'Not set' : '${user.city}, ${user.state}'),
                  if (user.allergies != null) ...[
                    const Divider(height: 1, indent: 56),
                    _ProfileItem(Icons.warning_amber, 'Allergies', user.allergies!),
                  ],
                  if (user.chronicConditions != null) ...[
                    const Divider(height: 1, indent: 56),
                    _ProfileItem(Icons.medical_information, 'Conditions', user.chronicConditions!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doctor-specific info
            if (user.doctorProfile != null) ...[
              Container(
                decoration: AppTheme.cardDecoration(context),
                child: Column(
                  children: [
                    _ProfileItem(Icons.medical_services, 'Specialization', user.doctorProfile!.specialization),
                    const Divider(height: 1, indent: 56),
                    _ProfileItem(Icons.school, 'Qualification', user.doctorProfile!.qualification),
                    const Divider(height: 1, indent: 56),
                    _ProfileItem(Icons.work, 'Experience', '${user.doctorProfile!.experienceYears} years'),
                    const Divider(height: 1, indent: 56),
                    _ProfileItem(Icons.currency_rupee, 'Fee', '₹${user.doctorProfile!.consultationFee}'),
                    const Divider(height: 1, indent: 56),
                    _ProfileItem(Icons.star, 'Rating', '${user.doctorProfile!.rating} (${user.doctorProfile!.totalReviews} reviews)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Settings
            Container(
              decoration: AppTheme.cardDecoration(context),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode, color: AppTheme.accentPurple),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: theme.isDark,
                      onChanged: (_) => theme.toggleTheme(),
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Icon(Icons.notifications_outlined, color: AppTheme.accentOrange),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Icon(Icons.security, color: AppTheme.accentBlue),
                    title: const Text('Privacy & Security'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: AppTheme.accentGreen),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            CustomButton(
              text: 'Logout',
              isFullWidth: true,
              isOutlined: true,
              color: AppTheme.accentRed,
              icon: Icons.logout,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
                        onPressed: () {
                          Navigator.pop(ctx);
                          auth.logout();
                          context.go('/login');
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            Text('MedSeva v1.0.0', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _ProfileItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.lightText)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}

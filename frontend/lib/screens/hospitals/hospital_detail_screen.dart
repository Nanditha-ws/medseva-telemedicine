/// Hospital Detail Screen
library;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class HospitalDetailScreen extends StatefulWidget {
  final String hospitalId;
  const HospitalDetailScreen({super.key, required this.hospitalId});
  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  Map<String, dynamic>? _hospital;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHospital();
  }

  Future<void> _fetchHospital() async {
    final response = await ApiService().get('${ApiConfig.hospitals}/${widget.hospitalId}');
    if (response.isSuccess && mounted) {
      setState(() { _hospital = response.data['data']['hospital']; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final h = _hospital!;

    return Scaffold(
      appBar: AppBar(title: Text(h['name'] ?? '')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text('${h['address']}, ${h['city']}, ${h['state']}', style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (h['rating'] != null) ...[
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text('${h['rating']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text((h['type'] ?? 'hospital').toString().replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact buttons
            Row(
              children: [
                Expanded(child: _ActionButton(Icons.phone, 'Call', AppTheme.accentGreen, () => launchUrl(Uri.parse('tel:${h['phone']}')))),
                const SizedBox(width: 12),
                if (h['emergency_services'] == true)
                  Expanded(child: _ActionButton(Icons.emergency, 'Emergency', AppTheme.accentRed, () => launchUrl(Uri.parse('tel:${h['ambulance_phone'] ?? h['phone']}')))),
                if (h['email'] != null) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _ActionButton(Icons.email, 'Email', AppTheme.accentBlue, () => launchUrl(Uri.parse('mailto:${h['email']}')))),
                ],
              ],
            ),
            const SizedBox(height: 24),

            if (h['description'] != null) ...[
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(h['description'], style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
            ],

            // Specializations
            if (h['specializations'] != null && (h['specializations'] as List).isNotEmpty) ...[
              Text('Specializations', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: (h['specializations'] as List).map((s) => Chip(
                  avatar: Icon(Icons.medical_services, size: 16, color: AppTheme.primaryColor),
                  label: Text(s.toString()),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Facilities
            if (h['facilities'] != null && (h['facilities'] as List).isNotEmpty) ...[
              Text('Facilities', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: (h['facilities'] as List).map((f) => Chip(
                  avatar: Icon(Icons.check_circle, size: 16, color: AppTheme.accentGreen),
                  label: Text(f.toString()),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Doctors
            if (h['doctors'] != null && (h['doctors'] as List).isNotEmpty) ...[
              Text('Doctors', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...(h['doctors'] as List).map((doc) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.cardDecoration(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text('${doc['user']?['first_name']?[0] ?? 'D'}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${doc['user']?['first_name'] ?? ''} ${doc['user']?['last_name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${doc['specialization']} • ${doc['experience_years']} yrs exp', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text('₹${doc['consultation_fee'] ?? 0}', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _ActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

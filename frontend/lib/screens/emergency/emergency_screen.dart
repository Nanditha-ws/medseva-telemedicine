/// Emergency Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../widgets/custom_button.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _emergencyInfo;
  List<dynamic> _codes = [];
  bool _isLoading = true;
  bool _isGenerating = false;

  // Sharing settings
  bool _shareMedicalRecords = true;
  bool _shareMedications = true;
  bool _shareAllergies = true;
  bool _shareEmergencyContacts = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final infoResponse = await _api.get(ApiConfig.emergencyMyInfo);
    final codesResponse = await _api.get(ApiConfig.emergencyMyCodes);

    if (mounted) {
      setState(() {
        if (infoResponse.isSuccess) _emergencyInfo = infoResponse.data['data'];
        if (codesResponse.isSuccess) _codes = codesResponse.data['data']['codes'] ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _generateCode() async {
    setState(() => _isGenerating = true);
    final response = await _api.post(ApiConfig.emergencyGenerateCode, data: {
      'share_medical_records': _shareMedicalRecords,
      'share_medications': _shareMedications,
      'share_allergies': _shareAllergies,
      'share_emergency_contacts': _shareEmergencyContacts,
      'expires_in_hours': 24,
    });

    if (response.isSuccess && mounted) {
      final code = response.data['data']['access_code'];
      _showCodeDialog(code);
      _loadData();
    }
    setState(() => _isGenerating = false);
  }

  void _showCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: AppTheme.accentRed),
            const SizedBox(width: 8),
            const Text('Emergency Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with emergency responders:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
              ),
              child: Text(code, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.accentRed, letterSpacing: 2)),
            ),
            const SizedBox(height: 12),
            Text('Valid for 24 hours', style: TextStyle(color: AppTheme.lightText, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!')));
              Navigator.pop(ctx);
            },
            child: const Text('Copy Code'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: const Text('Emergency')), body: const Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Access')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.emergencyGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emergency_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text('Emergency Health Data', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Generate a code to share your health information with emergency responders',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // My Emergency Info
            if (_emergencyInfo != null) ...[
              Text('My Emergency Info', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(Icons.bloodtype, 'Blood Group', _emergencyInfo!['personal_info']?['blood_group'] ?? 'Not set'),
                    _InfoRow(Icons.warning_amber, 'Allergies', _emergencyInfo!['personal_info']?['allergies'] ?? 'None'),
                    _InfoRow(Icons.medical_information, 'Conditions', _emergencyInfo!['personal_info']?['chronic_conditions'] ?? 'None'),
                    _InfoRow(Icons.contact_phone, 'Emergency Contact',
                      '${_emergencyInfo!['personal_info']?['emergency_contact_name'] ?? 'Not set'} - ${_emergencyInfo!['personal_info']?['emergency_contact_phone'] ?? ''}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Sharing Settings
            Text('Sharing Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: AppTheme.cardDecoration(context),
              child: Column(
                children: [
                  SwitchListTile(title: const Text('Medical Records'), value: _shareMedicalRecords,
                    onChanged: (v) => setState(() => _shareMedicalRecords = v), activeColor: AppTheme.primaryColor),
                  SwitchListTile(title: const Text('Current Medications'), value: _shareMedications,
                    onChanged: (v) => setState(() => _shareMedications = v), activeColor: AppTheme.primaryColor),
                  SwitchListTile(title: const Text('Allergies & Conditions'), value: _shareAllergies,
                    onChanged: (v) => setState(() => _shareAllergies = v), activeColor: AppTheme.primaryColor),
                  SwitchListTile(title: const Text('Emergency Contacts'), value: _shareEmergencyContacts,
                    onChanged: (v) => setState(() => _shareEmergencyContacts = v), activeColor: AppTheme.primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            CustomButton(
              text: 'Generate Emergency Code',
              isLoading: _isGenerating,
              onPressed: _generateCode,
              isFullWidth: true,
              color: AppTheme.accentRed,
              icon: Icons.qr_code,
            ),
            const SizedBox(height: 24),

            // Active codes
            if (_codes.isNotEmpty) ...[
              Text('Active Codes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._codes.where((c) => c['is_active'] == true).map((code) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.cardDecoration(context),
                child: Row(
                  children: [
                    Icon(Icons.vpn_key, color: AppTheme.accentRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(code['access_code'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1)),
                          Text('Used ${code['accessed_count'] ?? 0} times', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code['access_code']));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                      },
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _InfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppTheme.lightText)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Record Detail Screen
library;
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/medical_record.dart';

class RecordDetailScreen extends StatefulWidget {
  final String recordId;
  const RecordDetailScreen({super.key, required this.recordId});
  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  MedicalRecordModel? _record;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    final response = await ApiService().get('${ApiConfig.medicalRecords}/${widget.recordId}');
    if (response.isSuccess && mounted) {
      setState(() {
        _record = MedicalRecordModel.fromJson(response.data['data']['record']);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final record = _record!;

    return Scaffold(
      appBar: AppBar(title: Text(record.recordTypeDisplay)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.title, style: Theme.of(context).textTheme.headlineMedium),
            if (record.diagnosis != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('Diagnosis: ${record.diagnosis}', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 20),
            if (record.description != null) Text(record.description!, style: Theme.of(context).textTheme.bodyLarge),

            // Vitals
            if (record.vitals != null) ...[
              const SizedBox(height: 24),
              Text('Vital Signs', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: [
                  if (record.vitals!.bloodPressure != null) _VitalCard('Blood Pressure', record.vitals!.bloodPressure!, Icons.favorite, AppTheme.accentRed),
                  if (record.vitals!.heartRate != null) _VitalCard('Heart Rate', '${record.vitals!.heartRate} bpm', Icons.monitor_heart, AppTheme.accentPurple),
                  if (record.vitals!.temperature != null) _VitalCard('Temperature', '${record.vitals!.temperature}°F', Icons.thermostat, AppTheme.accentOrange),
                  if (record.vitals!.spo2 != null) _VitalCard('SpO2', '${record.vitals!.spo2}%', Icons.air, AppTheme.accentBlue),
                  if (record.vitals!.weight != null) _VitalCard('Weight', '${record.vitals!.weight} kg', Icons.monitor_weight, AppTheme.accentGreen),
                ],
              ),
            ],

            // Lab Results
            if (record.labResults != null && record.labResults!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Lab Results', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...record.labResults!.map((lab) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.cardDecoration(context),
                child: Row(
                  children: [
                    Expanded(child: Text(lab.testName, style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text('${lab.value} ${lab.unit ?? ''}', style: TextStyle(fontWeight: FontWeight.w600, color: lab.status == 'normal' ? AppTheme.accentGreen : AppTheme.accentRed)),
                    if (lab.referenceRange != null) Text(' (${lab.referenceRange})', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              )),
            ],

            // Medications
            if (record.medications != null && record.medications!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Prescribed Medications', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...record.medications!.map((med) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.cardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${med.dosage} • ${med.frequency}', style: Theme.of(context).textTheme.bodySmall),
                    if (med.instructions != null) Text(med.instructions!, style: TextStyle(fontSize: 12, color: AppTheme.accentBlue)),
                  ],
                ),
              )),
            ],

            // Tags
            if (record.tags != null && record.tags!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: record.tags!.map((tag) => Chip(label: Text('#$tag', style: const TextStyle(fontSize: 12)))).toList(),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _VitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 150, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

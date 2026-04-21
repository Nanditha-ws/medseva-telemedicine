/// Medical Records Screen
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/medical_record.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _api = ApiService();
  List<MedicalRecordModel> _records = [];
  bool _isLoading = true;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    final params = <String, dynamic>{};
    if (_selectedType != null) params['record_type'] = _selectedType;
    
    final response = await _api.get(ApiConfig.medicalRecords, queryParams: params);
    if (response.isSuccess && mounted) {
      final list = response.data['data']['records'] as List;
      _records = list.map((e) => MedicalRecordModel.fromJson(e)).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Records')),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip('All', null),
                _FilterChip('Lab Reports', 'lab_report'),
                _FilterChip('Prescriptions', 'prescription'),
                _FilterChip('Diagnosis', 'diagnosis'),
                _FilterChip('Imaging', 'imaging'),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: AppTheme.lightText),
                        const SizedBox(height: 16),
                        Text('No records found', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return GestureDetector(
                        onTap: () => context.push('/medical-records/${record.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration(context),
                          child: Row(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(record.recordType).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getTypeIcon(record.recordType), color: _getTypeColor(record.recordType)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(record.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(record.recordTypeDisplay, style: Theme.of(context).textTheme.bodySmall),
                                    if (record.diagnosis != null && record.diagnosis!.isNotEmpty)
                                      Text('Diagnosis: ${record.diagnosis}', style: TextStyle(fontSize: 12, color: AppTheme.accentGreen)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: AppTheme.lightText),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _FilterChip(String label, String? type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.15),
        onSelected: (_) {
          setState(() => _selectedType = type);
          _fetchRecords();
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'lab_report': return AppTheme.accentBlue;
      case 'prescription': return AppTheme.accentGreen;
      case 'diagnosis': return AppTheme.accentPurple;
      case 'imaging': return AppTheme.accentOrange;
      default: return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'lab_report': return Icons.science;
      case 'prescription': return Icons.description;
      case 'diagnosis': return Icons.medical_information;
      case 'imaging': return Icons.image;
      default: return Icons.folder;
    }
  }
}

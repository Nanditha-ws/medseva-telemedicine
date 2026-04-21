/// Add Medication Screen
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});
  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _frequency = 'once_daily';
  List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;

  final _frequencies = {
    'once_daily': 'Once Daily',
    'twice_daily': 'Twice Daily',
    'thrice_daily': 'Thrice Daily',
    'four_times_daily': '4 Times Daily',
    'weekly': 'Weekly',
    'as_needed': 'As Needed',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _updateTimesCount() {
    int count;
    switch (_frequency) {
      case 'once_daily': count = 1; break;
      case 'twice_daily': count = 2; break;
      case 'thrice_daily': count = 3; break;
      case 'four_times_daily': count = 4; break;
      default: count = 1;
    }
    setState(() {
      while (_times.length < count) {
        _times.add(TimeOfDay(hour: 8 + _times.length * 6, minute: 0));
      }
      if (_times.length > count) _times = _times.sublist(0, count);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<MedicationProvider>(context, listen: false);
    final success = await provider.addReminder({
      'medication_name': _nameController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'frequency': _frequency,
      'times': _times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00').toList(),
      'start_date': '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
      if (_endDate != null) 'end_date': '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
      'instructions': _instructionsController.text.trim(),
    });

    setState(() => _isLoading = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Medication added! ✓'), backgroundColor: AppTheme.accentGreen),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Medication Name',
                hint: 'e.g., Metoprolol',
                prefixIcon: Icons.medication_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dosageController,
                label: 'Dosage',
                hint: 'e.g., 50mg',
                prefixIcon: Icons.science_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              Text('Frequency', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _frequencies.entries.map((e) {
                  final isSelected = _frequency == e.key;
                  return ChoiceChip(
                    label: Text(e.value),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.mediumText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => _frequency = e.key);
                      _updateTimesCount();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              Text('Reminder Times', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ...List.generate(_times.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: _times[i]);
                    if (time != null) setState(() => _times[i] = time);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text('Dose ${i + 1}: ${_times[i].format(context)}', style: const TextStyle(fontSize: 15)),
                        const Spacer(),
                        Icon(Icons.edit, size: 16, color: AppTheme.lightText),
                      ],
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                        if (date != null) setState(() => _startDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Date', prefixIcon: Icon(Icons.calendar_today, size: 18)),
                        child: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2030));
                        if (date != null) setState(() => _endDate = date);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End Date (optional)', prefixIcon: Icon(Icons.calendar_today, size: 18)),
                        child: Text(_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'No end date'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _instructionsController,
                label: 'Instructions',
                hint: 'e.g., Take with food',
                prefixIcon: Icons.info_outline,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Add Medication',
                isLoading: _isLoading,
                onPressed: _save,
                isFullWidth: true,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

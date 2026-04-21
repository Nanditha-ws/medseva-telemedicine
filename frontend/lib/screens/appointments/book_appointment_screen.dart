/// Book Appointment Screen
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/appointment_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});
  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _api = ApiService();
  List<dynamic> _doctors = [];
  String? _selectedDoctorId;
  String _selectedType = 'in_person';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final _reasonController = TextEditingController();
  final _symptomsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    final response = await _api.get(ApiConfig.doctors);
    if (response.isSuccess && mounted) {
      setState(() => _doctors = response.data['data']['doctors'] ?? []);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await provider.bookAppointment({
      'doctor_id': _selectedDoctorId,
      'appointment_date': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      'appointment_time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
      'type': _selectedType,
      'reason': _reasonController.text,
      'symptoms': _symptomsController.text,
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Appointment booked!'), backgroundColor: AppTheme.accentGreen),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Doctor', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            if (_doctors.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...(_doctors.map((doc) {
                final profile = doc['doctorProfile'];
                final isSelected = doc['id'] == _selectedDoctorId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDoctorId = doc['id']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor, width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Text('${doc['first_name']?[0] ?? ''}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${doc['first_name']} ${doc['last_name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (profile != null)
                                Text('${profile['specialization']} • ₹${profile['consultation_fee']}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        if (isSelected) Icon(Icons.check_circle, color: AppTheme.primaryColor),
                      ],
                    ),
                  ),
                );
              })),

            const SizedBox(height: 24),
            Text('Appointment Type', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _TypeChip('In Person', 'in_person', Icons.person),
                const SizedBox(width: 10),
                _TypeChip('Video Call', 'video_call', Icons.videocam),
                const SizedBox(width: 10),
                _TypeChip('Phone', 'phone_call', Icons.phone),
              ].map((chip) => Expanded(child: chip)).toList(),
            ),

            const SizedBox(height: 24),
            Text('Date & Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: AppTheme.borderColor), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _selectedTime);
                      if (time != null) setState(() => _selectedTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: AppTheme.borderColor), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            CustomTextField(controller: _reasonController, label: 'Reason for Visit', prefixIcon: Icons.note_outlined, maxLines: 2),
            const SizedBox(height: 16),
            CustomTextField(controller: _symptomsController, label: 'Symptoms (optional)', prefixIcon: Icons.healing_outlined, maxLines: 2),
            const SizedBox(height: 32),

            CustomButton(text: 'Book Appointment', isLoading: _isLoading, onPressed: _bookAppointment, isFullWidth: true, icon: Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }

  Widget _TypeChip(String label, String value, IconData icon) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () => setState(() => _selectedType = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.lightText, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primaryColor : AppTheme.lightText)),
          ],
        ),
      ),
    );
  }
}

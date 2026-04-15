/// Medication Provider
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/medication_reminder.dart';

class MedicationProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<MedicationReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<MedicationReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReminders() async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _api.get(ApiConfig.medications);
    if (response.isSuccess) {
      final list = response.data['data']['reminders'] as List;
      _reminders = list.map((e) => MedicationReminderModel.fromJson(e)).toList();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReminder(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.medications, data: data);
    if (response.isSuccess) {
      await fetchReminders();
      return true;
    }
    _error = response.message;
    return false;
  }

  Future<bool> logMedication(String id, String status) async {
    final response = await _api.post('${ApiConfig.medications}/$id/log', data: {'status': status});
    return response.isSuccess;
  }

  Future<bool> deleteReminder(String id) async {
    final response = await _api.delete('${ApiConfig.medications}/$id');
    if (response.isSuccess) {
      await fetchReminders();
      return true;
    }
    return false;
  }
}

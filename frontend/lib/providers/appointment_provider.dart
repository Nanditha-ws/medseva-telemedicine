/// Appointment Provider
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/appointment.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _upcoming = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get upcoming => _upcoming;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAppointments({String? status}) async {
    _isLoading = true;
    notifyListeners();
    
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    
    final response = await _api.get(ApiConfig.appointments, queryParams: params);
    if (response.isSuccess) {
      final list = response.data['data']['appointments'] as List;
      _appointments = list.map((e) => AppointmentModel.fromJson(e)).toList();
    } else {
      _error = response.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUpcoming() async {
    final response = await _api.get(ApiConfig.upcomingAppointments);
    if (response.isSuccess) {
      final list = response.data['data']['appointments'] as List;
      _upcoming = list.map((e) => AppointmentModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<bool> bookAppointment(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _api.post(ApiConfig.appointments, data: data);
    _isLoading = false;
    
    if (response.isSuccess) {
      await fetchAppointments();
      await fetchUpcoming();
      notifyListeners();
      return true;
    }
    _error = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> cancelAppointment(String id, String reason) async {
    final response = await _api.delete('${ApiConfig.appointments}/$id', data: {'reason': reason});
    if (response.isSuccess) {
      await fetchAppointments();
      return true;
    }
    return false;
  }
}

/// Theme Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

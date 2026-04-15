/// Authentication Provider
/// Manages user authentication state

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/user.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _checkAuth();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuth() async {
    final hasToken = await _api.hasToken();
    if (hasToken) {
      await fetchUser();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final response = await _api.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });

    if (response.isSuccess) {
      final data = response.data['data'];
      await _api.saveTokens(data['accessToken'], data['refreshToken']);
      _user = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      
      // Save role locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', _user!.role);
      await prefs.setString('user_name', _user!.fullName);
      
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register(Map<String, dynamic> userData) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final response = await _api.post(ApiConfig.register, data: userData);

    if (response.isSuccess) {
      final data = response.data['data'];
      await _api.saveTokens(data['accessToken'], data['refreshToken']);
      _user = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Fetch current user profile
  Future<void> fetchUser() async {
    try {
      final response = await _api.get(ApiConfig.me);
      if (response.isSuccess) {
        _user = UserModel.fromJson(response.data['data']['user']);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.profile, data: data);
    if (response.isSuccess) {
      _user = UserModel.fromJson(response.data['data']['user']);
      notifyListeners();
      return true;
    }
    _error = response.message;
    return false;
  }

  /// Logout
  Future<void> logout() async {
    await _api.post(ApiConfig.logout);
    await _api.clearTokens();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

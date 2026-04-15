/// API Service - Central HTTP client for all API calls
/// Uses Dio with interceptors for auth token management

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attach auth token
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        // Handle 401 - try refresh token
        if (error.response?.statusCode == 401) {
          try {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request
              final token = await _storage.read(key: 'access_token');
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            // Refresh failed - need to re-login
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// Refresh the access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
      )).post(ApiConfig.refreshToken, data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _storage.write(key: 'access_token', value: data['accessToken']);
        await _storage.write(key: 'refresh_token', value: data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Save authentication tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  /// Check if user has valid token
  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // ═══════════════════════════════════════════════════════
  // HTTP METHODS
  // ═══════════════════════════════════════════════════════

  /// GET request
  Future<ApiResponse> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// POST request
  Future<ApiResponse> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// PUT request
  Future<ApiResponse> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE request
  Future<ApiResponse> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Upload file with multipart form data
  Future<ApiResponse> uploadFile(String path, File file, {
    String fieldName = 'image',
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        ...?extraFields,
      });

      final response = await _dio.post(path, data: formData);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Handle Dio errors
  ApiResponse _handleError(DioException e) {
    String message = 'An error occurred';

    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Server took too long to respond.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'No internet connection.';
    }

    return ApiResponse.error(message, e.response?.statusCode);
  }
}

/// Standardized API Response wrapper
class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? message;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      message: data is Map ? data['message'] : null,
    );
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

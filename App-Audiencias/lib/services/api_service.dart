import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/audiencia.dart';

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/$'), '');
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://localhost:8000/api';
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers({bool includeJsonContentType = true}) {
    final headers = <String, String>{};

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: _headers(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          setAuthToken(data['token'] as String?);
        }
        return data;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': false,
        'message': data['message'] ?? 'Error al iniciar sesión'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setAuthToken(null);
        return data;
      }
      return {
        'success': false,
        'message': 'Error al cerrar sesión'
      };
    } catch (e) {
      return {
        'success': true, // Aunque haya error, permitimos cerrar sesión
        'message': 'Error de conexión: $e'
      };
    }
  }

  Future<List<Audiencia>> getAudiencias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/audiencias/'),
        headers: _headers(includeJsonContentType: false),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<Audiencia> audiencias = [];
          for (var item in data['audiencias']) {
            audiencias.add(Audiencia.fromMap(item));
          }
          return audiencias;
        }
      }
    } catch (e) {
      debugPrint('Error fetching audiencias: $e');
    }
    return [];
  }

  Future<bool> createAudiencia(Audiencia audiencia) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/audiencias/'),
        headers: _headers(),
        body: jsonEncode(audiencia.toMap()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      debugPrint(
        'Error creating audiencia: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      debugPrint('Error creating audiencia: $e');
    }
    return false;
  }

  Future<bool> updateAudiencia(Audiencia audiencia) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/audiencias/${audiencia.id}/'),
        headers: _headers(),
        body: jsonEncode(audiencia.toMap()),
      );

      if (response.statusCode == 200) {
        return true;
      }
      debugPrint(
        'Error updating audiencia: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      debugPrint('Error updating audiencia: $e');
    }
    return false;
  }

  Future<bool> deleteAudiencia(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/audiencias/$id/'),
        headers: _headers(includeJsonContentType: false),
      );

      if (response.statusCode == 200) {
        return true;
      }
      debugPrint(
        'Error deleting audiencia: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      debugPrint('Error deleting audiencia: $e');
    }
    return false;
  }
}

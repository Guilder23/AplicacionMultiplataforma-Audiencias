import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audiencia.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Para emulador Android
  static const String baseUrl = 'http://localhost:8000/api'; // Para iOS o web

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {
        'success': false,
        'message': 'Error al iniciar sesión'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }

  Future<List<Audiencia>> getAudiencias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/audiencias/'));

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
      print('Error fetching audiencias: $e');
    }
    return [];
  }

  Future<bool> createAudiencia(Audiencia audiencia) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/audiencias/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(audiencia.toMap()),
      );

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print('Error creating audiencia: $e');
    }
    return false;
  }

  Future<bool> updateAudiencia(Audiencia audiencia) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/audiencias/${audiencia.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(audiencia.toMap()),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error updating audiencia: $e');
    }
    return false;
  }

  Future<bool> deleteAudiencia(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/audiencias/$id/'),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error deleting audiencia: $e');
    }
    return false;
  }
}
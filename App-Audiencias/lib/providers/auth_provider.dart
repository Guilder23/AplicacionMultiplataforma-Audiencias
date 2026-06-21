import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _username;
  String? _firstName;
  String? _lastName;
  String? _email;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String get displayName => _firstName?.isNotEmpty == true ? '$_firstName $_lastName' : _username ?? 'Usuario';
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null) {
      _isAuthenticated = true;
      _username = username;
      _firstName = prefs.getString('firstName');
      _lastName = prefs.getString('lastName');
      _email = prefs.getString('email');
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);
      if (response['success'] == true) {
        _isAuthenticated = true;
        _username = username;
        _firstName = response['user']['first_name'];
        _lastName = response['user']['last_name'];
        _email = response['user']['email'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('firstName', _firstName ?? '');
        await prefs.setString('lastName', _lastName ?? '');
        await prefs.setString('email', _email ?? '');
        return true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    // Intentar cerrar sesión en el backend
    await _apiService.logout();
    
    // Siempre cerrar sesión localmente
    _isAuthenticated = false;
    _username = null;
    _firstName = null;
    _lastName = null;
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('email');
    notifyListeners();
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3000'; // Cambia por tu URL del backend

  // Claves para SharedPreferences
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  // Registrar nuevo usuario
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['access_token'], data['user']);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error en el registro'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Login de usuario
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔍 FLUTTER LOGIN - Enviando request a: $baseUrl/auth/login');
      print('🔍 FLUTTER LOGIN - Email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('🔍 FLUTTER LOGIN - Status Code: ${response.statusCode}');
      print('🔍 FLUTTER LOGIN - Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ FLUTTER LOGIN - Data parsed correctamente');
        print('🔍 FLUTTER LOGIN - Access Token: ${data['access_token']?.substring(0, 20)}...');
        
        await _saveAuthData(data['access_token'], data['user']);
        print('✅ FLUTTER LOGIN - Datos guardados en SharedPreferences');
        
        return {'success': true, 'data': data};
      } else {
        print('❌ FLUTTER LOGIN - Error status code: ${response.statusCode}');
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Credenciales inválidas'};
      }
    } catch (e) {
      print('💥 FLUTTER LOGIN ERROR: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Guardar token y datos de usuario
  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obtener datos de usuario guardados
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout - limpiar datos guardados
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Obtener headers con autorización para requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
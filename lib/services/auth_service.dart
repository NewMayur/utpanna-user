import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  static const String _baseUrl = Constants.apiUrl;
  static const String _tokenKey = 'auth_token';

  Future<String> login(String username, String password) async {
    print("Sending login request...");
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    print("Received response with status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['access_token'] != null) {
        final token = data['access_token'] as String;
        await _saveToken(token);
        return token;
      } else {
        throw Exception('Access token is null in the response');
      }
    } else {
      throw Exception('Failed to login. Status code: ${response.statusCode}');
    }
  }

  Future<String> register(String username, String password) async {
    print("Sending registration request...");
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    print("Received response with status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> logout() async {
    await _deleteToken();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}